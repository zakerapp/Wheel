//
//  WHLNetwork.m
//  Wheel
//
//  Created by zaker_sink on 13-5-29.
//  Copyright (c) 2013年 Wang JunXin. All rights reserved.
//

#import <arpa/inet.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <ifaddrs.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netdb.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <netdb.h>
#include <resolv.h>
#import "Reachability.h"
#import "WHLNetwork.h"

NSString *const WHLNetworkStatusChangedNotification = @"WHLNetworkStatusChangedNotification";
NSString *const WHLCellularNetworkTypeChangedNotification = @"WHLCellularNetworkTypeChangedNotification";

@implementation WHLNetworkProxy

- (NSString *)httpProxyString
{
    if (self.httpHost && self.httpPort) {
        return [NSString stringWithFormat:@"%@:%td", self.httpHost, self.httpPort.integerValue];
    }

    if (self.httpHost) {
        return self.httpHost;
    }

    return nil;
}

@end

@implementation WHLNetworkWiFiInfo
@end

@interface WHLNetwork ()

@property (nonatomic) Reachability *reachability;

@end

@implementation WHLNetwork

// 此方法还会有闪退的问题，暂时不能用：如url:http://182.20.23.3
+ (NSString *)IPAddressInURLString:(NSString *)urlString
{
    if (!(urlString.length > 0)) {
        return @"";
    }

    NSString *hostName = [self hostNameInURLString:urlString];

    if (!(hostName.length > 0)) {
        return @"";
    }

    return [self IPAddressInHostName:hostName];
}

+ (NSString *)hostNameInURLString:(NSString *)urlString
{
    static NSString *regexHostName = @"^http(?:s)?:\\/\\/([^\\/]+)";

    NSError *error  = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexHostName
                                                                           options:0
                                                                             error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];

    if (match && [match numberOfRanges] > 1) {
        NSRange matchRange = [match rangeAtIndex:1];
        return [urlString substringWithRange:matchRange];
    } else {
        return nil;
    }
}

+ (NSString *)IPAddressInHostName:(NSString *)hostName
{
    const char *szname = [hostName UTF8String];
    struct hostent *phot;

    @try {
        phot = gethostbyname(szname);
    } @catch (NSException *e) {
        return nil;
    }

    if (phot == NULL) {
        return nil;
    }

    struct in_addr ip_addr;
    memcpy(&ip_addr, phot->h_addr_list[0], 4); /// h_addr_list[0]里4个字节,每个字节8位，此处为一个数组，一个域名对应多个ip地址或者本地时一个机器有多个网卡

    char ip[20] = { 0 };
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));

    NSString *strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}

+ (uint32_t)dataTraffic
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return 0;
    }

    uint32_t iBytes     = 0;
    uint32_t oBytes     = 0;
    uint32_t allFlow    = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow   = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow   = 0;
    struct IF_DATA_TIMEVAL time;

    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family) continue;

        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING)) continue;

        if (ifa->ifa_data == 0) continue;

        // Not a loopback device.
        // network flow
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;

            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
            time = if_data->ifi_lastchange;
        }

        //wifi flow
        if (!strcmp(ifa->ifa_name, "en0")) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;

            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow    = wifiIBytes + wifiOBytes;
        }

        //3G and gprs flow
        if (!strcmp(ifa->ifa_name, "pdp_ip0")) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;

            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow    = wwanIBytes + wwanOBytes;
        }
    }
    freeifaddrs(ifa_list);
    return allFlow;
}

+ (void)clearCookiesOfDomain:(NSString *)domain
{
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookiesArr = [cookies cookiesForURL:
                           [NSURL URLWithString:domain]];
    for (NSHTTPCookie *cookie in cookiesArr) {
        [cookies deleteCookie:cookie];
    }
}

+ (WHLNetwork *)sharedNetwork
{
    static WHLNetwork *sharedNetwork;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetwork = [[self alloc] init];
    });
    return sharedNetwork;
}

- (void)dealloc
{
    [_reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)initialize
{
    [self sharedNetwork]; // 初始化单例
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reachability = [Reachability reachabilityForInternetConnection];
        [_reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioTechnologyChanged:) name:CTRadioAccessTechnologyDidChangeNotification object:nil];
    }
    return self;
}

- (void)reachabilityChanged:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WHLNetworkStatusChangedNotification object:nil];
}

- (void)radioTechnologyChanged:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WHLCellularNetworkTypeChangedNotification object:nil];
}

+ (WHLNetworkStatus)networkStatus
{
    NetworkStatus status = [self sharedNetwork].reachability.currentReachabilityStatus;

    switch (status) {
        case NotReachable:
            return WHLNetworkNotReachable;
            break;

        case ReachableViaWiFi:
            return WHLNetworkReachableViaWiFi;
            break;

        case ReachableViaWWAN:
            return WHLNetworkReachableViaCellular;

        default:
            break;
    }

    return WHLNetworkReachableViaWiFi; // 不可识别的网络状态，判断为wifi
}

+ (WHLCellularNetworkType)cellularNetworkType
{
    /*
     技术分类
     ------- 2G ---------
     GPRS
     Edge
     ------- 3G ---------
     WCDMA
     HSDPA
     HSUPA
     CDMA1x
     CDMAEVDORev0
     CDMAEVDORevA
     CDMAEVDORevB
     eHRPD
     ------- 4G ---------
     LTE
     */
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentTech = networkInfo.currentRadioAccessTechnology;

    NSArray *techFor2G = @[CTRadioAccessTechnologyGPRS,
                           CTRadioAccessTechnologyEdge];
    if ([techFor2G containsObject:currentTech]) {
        return WHLCellularNetworkType2G;
    }

    NSArray *techFor3G = @[CTRadioAccessTechnologyWCDMA,
                           CTRadioAccessTechnologyHSDPA,
                           CTRadioAccessTechnologyHSUPA,
                           CTRadioAccessTechnologyCDMA1x,
                           CTRadioAccessTechnologyCDMAEVDORev0,
                           CTRadioAccessTechnologyCDMAEVDORevA,
                           CTRadioAccessTechnologyCDMAEVDORevB,
                           CTRadioAccessTechnologyeHRPD];
    if ([techFor3G containsObject:currentTech]) {
        return WHLCellularNetworkType3G;
    }

    NSArray *techFor4G = @[CTRadioAccessTechnologyLTE];
    if ([techFor4G containsObject:currentTech]) {
        return WHLCellularNetworkType4G;
    }

    return WHLCellularNetworkTypeUnknown;
}

+ (BOOL)isReachable
{
    return [self networkStatus] != WHLNetworkNotReachable;
}

+ (BOOL)isReachableViaWiFi
{
    return [self networkStatus] == WHLNetworkReachableViaWiFi;
}

+ (BOOL)isReachableViaCellular
{
    return [self networkStatus] == WHLNetworkReachableViaCellular;
}

+ (NSString *)carrierName
{
    CTTelephonyNetworkInfo *netWorkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = netWorkInfo.subscriberCellularProvider;
    return [carrier carrierName];
}

+ (WHLNetworkProxy *)systemHTTPProxy
{
    NSDictionary *proxySetting = (__bridge_transfer NSDictionary *)CFNetworkCopySystemProxySettings();

    NSNumber *proxyEnabled = proxySetting[(__bridge NSString *)kCFNetworkProxiesHTTPEnable];
    if ([proxyEnabled boolValue]) {
        NSString *host = proxySetting[(__bridge NSString *)kCFNetworkProxiesHTTPProxy];
        NSNumber *port = proxySetting[(__bridge NSString *)kCFNetworkProxiesHTTPPort];

        WHLNetworkProxy *proxy = [[WHLNetworkProxy alloc] init];
        proxy.httpHost = host;
        proxy.httpPort = port;
        return proxy;
    }

    NSNumber *pacEnabled = proxySetting[(__bridge NSString *)kCFNetworkProxiesProxyAutoConfigEnable];
    if ([pacEnabled boolValue]) {
        NSString *url = proxySetting[(__bridge NSString *)kCFNetworkProxiesProxyAutoConfigURLString];
        if (url.length > 0) {
            WHLNetworkProxy *proxy = [[WHLNetworkProxy alloc] init];
            proxy.pacURL = url;
            return proxy;
        }
    }

    return nil;
}

+ (WHLNetworkWiFiInfo *)systemWiFiInfo
{
    NSArray *interfaces = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    //    NSLog(@"Supported interfaces: %@", interfaces);
    for (NSString *interface in interfaces) {
        NSDictionary *interfaceInfo = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface);
        //        NSLog(@"%@ => %@", interface, info);
        if (interfaceInfo) {
            NSString *ssid = interfaceInfo[(__bridge NSString *)kCNNetworkInfoKeySSID];
            NSData *ssidData = interfaceInfo[(__bridge NSString *)kCNNetworkInfoKeySSIDData];
            NSString *bssid = interfaceInfo[(__bridge NSString *)kCNNetworkInfoKeyBSSID];

            WHLNetworkWiFiInfo *wifiInfo = [[WHLNetworkWiFiInfo alloc] init];
            wifiInfo.SSID = ssid;
            wifiInfo.SSIDData = ssidData;
            wifiInfo.BSSID = bssid;
            return wifiInfo;
        }
    }
    return nil;
}

+ (NSArray<NSString *> *)DNSAddresses
{
    res_state state = malloc(sizeof(struct __res_state));

    if (EXIT_SUCCESS != res_ninit(state)) {
        free(state);
        return nil;
    }

    NSMutableArray *addresses = [[NSMutableArray alloc] init];

    union res_sockaddr_union servers[NI_MAXSERV];

    int serversFound = res_9_getservers(state, servers, NI_MAXSERV);

    char hostBuffer[NI_MAXHOST];
    for (int i = 0; i < serversFound; i++) {
        union res_sockaddr_union s = servers[i];
        if (s.sin.sin_len > 0) {
            if (EXIT_SUCCESS == getnameinfo((struct sockaddr *)&s.sin,  // Pointer to your struct sockaddr
                                            (socklen_t)s.sin.sin_len,   // Size of this struct
                                            (char *)&hostBuffer,        // Pointer to hostname string
                                            sizeof(hostBuffer),         // Size of this string
                                            nil,                        // Pointer to service name string
                                            0,                          // Size of this string
                                            NI_NUMERICHOST)) {          // Flags given
                [addresses addObject:[NSString stringWithUTF8String:hostBuffer]];
            }
        }
    }

    res_ndestroy(state);
    free(state);

    return addresses;
}

@end
