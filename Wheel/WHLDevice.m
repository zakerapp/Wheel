//
//  WHLDevice.m
//  Wheel
//
//  Created by zaker zaker on 12-3-29.
//  Copyright (c) 2012年 ZAKER. All rights reserved.
//

#import <AdSupport/AdSupport.h>
#import <mach/mach.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/sysctl.h>
#import "MCSMKeychainItem.h"
#import "WHLDevice.h"
#import "WHLError.h"

#define MAC_USER_DEFAULTS_KEY  @"_mac"
#define UDID_USER_DEFAULTS_KEY @"_udid"

#if !TARGET_OS_WATCH

@interface UIDevice ()

- (void)setOrientation:(long long)arg1;

@end

@implementation UIDevice (WHLAdditions)

- (BOOL)whl_syncUDID
{
    // 如果两个UDID不一样，要更新一下keychain的UDID
    NSString *appUDID = [[NSUserDefaults standardUserDefaults] stringForKey:UDID_USER_DEFAULTS_KEY];
    NSString *keychainUDID = [MCSMApplicationUUIDKeychainItem applicationUUID];
    if (appUDID.length > 0 && ![appUDID isEqualToString:keychainUDID]) {
        [MCSMApplicationUUIDKeychainItem setApplicationUUIDKeychainItemWithUUID:appUDID];
        return YES;
    }
    return NO;
}

- (NSString *)whl_UDID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *udid = [userDefaults stringForKey:UDID_USER_DEFAULTS_KEY];

    if (!(udid.length > 0)) {
        udid = [MCSMApplicationUUIDKeychainItem applicationUUID];

        if (!(udid.length > 0)) {
            udid = [self whl_IDFA];

            if (!(udid.length > 0)) {
                WHLException(@"无法生成UDID");
            }
        }

        if ((udid.length > 0)) {
            NSLog(@"UDID 变更为 %@", udid);
            [userDefaults setObject:udid forKey:UDID_USER_DEFAULTS_KEY];
            [userDefaults synchronize];
        }
    }

    return udid;
}

- (NSString *)whl_IDFA
{
    // 用以广告跟踪
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSUUID *uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        return [uuid UUIDString];
    }
    return nil;
}

- (NSString *)whl_MACAddress
{
    NSString *tMAC = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:MAC_USER_DEFAULTS_KEY] == nil) {
        tMAC =  [self macaddress];
        [defaults setObject:tMAC forKey:MAC_USER_DEFAULTS_KEY];
        [defaults synchronize];
    } else {
        tMAC = [defaults objectForKey:MAC_USER_DEFAULTS_KEY];
    }

    return tMAC;
}

- (NSString *)macaddress
{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;

    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }

    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }

    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    free(buf);

    return outstring;
}

- (NSString *)whl_freeMemoryString
{
    return [NSString stringWithFormat:@"%ld MB", (long)[self whl_freeMemoryInteger]];
}

- (NSInteger)whl_freeMemoryInteger
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);

    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
    }

    /* Stats in bytes */
    //    natural_t mem_used = (vm_stat.active_count +
    //                          vm_stat.inactive_count +
    //                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = (natural_t)(vm_stat.free_count * pagesize);
    //    natural_t mem_total = mem_used + mem_free;

    return ((mem_free) / 1024.0) / 1024.0;
}

- (CGAffineTransform)whl_transformForCurrentOrientation
{
    return [self whl_transformForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGAffineTransform)whl_transformForOrientation:(UIInterfaceOrientation)orientation
{
    CGAffineTransform result = CGAffineTransformIdentity;

    CGFloat pi = (CGFloat)M_PI;
    if (orientation == UIInterfaceOrientationPortrait) {
        result = CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        result = CGAffineTransformMakeRotation(pi * (90.f) / 180.0f);
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        result = CGAffineTransformMakeRotation(pi * (-90.f) / 180.0f);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        result = CGAffineTransformMakeRotation(pi);
    }

    return result;
}

- (void)whl_attempToSetOrientation:(UIDeviceOrientation)newOrientation
{
    if ([self respondsToSelector:@selector(setOrientation:)]) {
        [[UIDevice currentDevice] setOrientation:newOrientation];
    }
}

+ (BOOL)whl_isJailbroken
{
    static BOOL jailbroken = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *jailbrokenPathAry = [NSArray arrayWithObjects:
                                      @"/Applications/Cydia.app",
                                      @"/Applications/limera1n.app",
                                      @"/Applications/greenpois0n.app",
                                      @"/Applications/blackra1n.app",
                                      @"/Applications/blacksn0w.app",
                                      @"/Applications/redsn0w.app",
                                      @"/Applications/Absinthe.app",
                                      @"/private/var/lib/apt/",
                                      @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                                      @"/etc/apt",
                                      nil];

        for (NSString *jailbrokenPath in jailbrokenPathAry) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:jailbrokenPath]) {
                jailbroken = YES;
                break;
            }
        }
    });

    return jailbroken;
}

@end

#endif
