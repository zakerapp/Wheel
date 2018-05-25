//
//  WHLDevice.h
//  Wheel
//
//  Created by zaker zaker on 12-3-29.
//  Copyright (c) 2012年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>

static inline NSOperatingSystemVersion WHLOSVersionMake(NSInteger majorVersion, NSInteger minorVersion, NSInteger patchVersion)
{
    NSOperatingSystemVersion version;
    version.majorVersion = majorVersion;
    version.minorVersion = minorVersion;
    version.patchVersion = patchVersion;
    return version;
}

#define WHLOSVersionAtLeast(major, minor, patch) [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:WHLOSVersionMake(major, minor, patch)]

#if !TARGET_OS_WATCH

@interface UIDevice (WHLAdditions)

/**
 同步当前 UDID 到 keychain
 @returns 如果有修改 Keychain，返回 YES，否则返回 NO。
 */
- (BOOL)whl_syncUDID;

/**
 获取 UDID
 */
- (NSString *)whl_UDID;

- (NSString *)whl_IDFA;

/**
 获取 Mac 地址 MD5 的方法
 */
- (NSString *)whl_MACAddress;

- (NSString *)whl_freeMemoryString;

- (NSInteger)whl_freeMemoryInteger;

- (CGAffineTransform)whl_transformForCurrentOrientation;

- (CGAffineTransform)whl_transformForOrientation:(UIInterfaceOrientation)orientation;

- (void)whl_attempToSetOrientation:(UIDeviceOrientation)newOrientation;

+ (BOOL)whl_isJailbroken;

@end

#endif
