//
//  WHLApplication.m
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLAccessibility.h"
#import "WHLApplication.h"

@implementation WHLApplication

+ (NSString *)version
{
    static NSString *version = nil;

    if (!version) {
        version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }

    return version;
}

+ (NSString *)buildVersion
{
    static NSString *buildVersion = nil;

    if (!buildVersion) {
        buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    }

    return buildVersion;
}

+ (CGRect)applicationBounds
{
    CGRect bounds = [self applicationFrame];
    bounds.origin.y = 0;
    return bounds;
}

+ (CGRect)applicationFrame
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    return frame;
}

@end
