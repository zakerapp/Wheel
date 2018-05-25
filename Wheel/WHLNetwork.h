//
//  WHLNetwork.h
//  Wheel
//
//  Created by zaker_sink on 13-5-29.
//  Copyright (c) 2013年 Wang JunXin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const WHLNetworkStatusChangedNotification;
extern NSString *const WHLCellularNetworkTypeChangedNotification;

typedef NS_ENUM (NSInteger, WHLNetworkStatus) {
    WHLNetworkNotReachable,
    WHLNetworkReachableViaCellular,
    WHLNetworkReachableViaWiFi
};

typedef NS_ENUM (NSInteger, WHLCellularNetworkType) {
    WHLCellularNetworkTypeUnknown,
    WHLCellularNetworkType2G,
    WHLCellularNetworkType3G,
    WHLCellularNetworkType4G
};

@interface WHLNetworkProxy : NSObject

@property (nonatomic, strong) NSString *httpHost;

@property (nonatomic, strong) NSNumber *httpPort;

@property (nonatomic, strong) NSString *pacURL;

- (NSString *)httpProxyString;

@end

@interface WHLNetworkWiFiInfo : NSObject

@property (nonatomic, strong) NSString *SSID;

@property (nonatomic, strong) NSData *SSIDData;

@property (nonatomic, strong) NSString *BSSID;

@end

/**
 解决状态栏loading不停的问题
 */
@interface WHLNetwork : NSObject

+ (NSString *)IPAddressInURLString:(NSString *)urlString;
+ (NSString *)hostNameInURLString:(NSString *)urlString;
+ (NSString *)IPAddressInHostName:(NSString *)hostName;

+ (uint32_t)dataTraffic;

+ (void)clearCookiesOfDomain:(NSString *)domain;

+ (NSString *)carrierName;

+ (WHLNetworkStatus)networkStatus;

+ (WHLCellularNetworkType)cellularNetworkType;

+ (BOOL)isReachable;
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaCellular;

+ (WHLNetworkProxy *)systemHTTPProxy;

+ (WHLNetworkWiFiInfo *)systemWiFiInfo;

+ (NSArray<NSString *> *)DNSAddresses;

@end
