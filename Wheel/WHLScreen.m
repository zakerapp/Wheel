//
//  WHLScreen.m
//  Wheel
//
//  Created by Steven Mok on 14-1-26.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import "WHLScreen.h"

CGFloat WHLOnePixelToPoint(void)
{
    static CGFloat onePixelWidth = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        onePixelWidth = 1.f / [UIScreen mainScreen].scale;
    });

    return onePixelWidth;
}

CGFloat WHLPixelToPoint(CGFloat pixel)
{
    return pixel / [UIScreen mainScreen].scale;
}

@implementation UIScreen (WHLAdditions)

- (WHLScreenPhysicalSize)whl_physicalSize
{
    CGSize size = self.bounds.size;

    if (size.width > size.height) {
        CGFloat temp = size.height;
        size.height = size.width;
        size.width = temp;
    }

    if (CGSizeEqualToSize(size, CGSizeMake(375, 667))) {
        return WHLScreenPhysicalSize_4_7_inch;
    }

    if (CGSizeEqualToSize(size, CGSizeMake(414, 736))) {
        return WHLScreenPhysicalSize_5_5_inch;
    }

    if (CGSizeEqualToSize(size, CGSizeMake(375, 812))) {
        return WHLScreenPhysicalSize_5_8_inch;
    }

    if (CGSizeEqualToSize(size, CGSizeMake(320, 480))) {
        return WHLScreenPhysicalSize_3_5_inch;
    }

    if (CGSizeEqualToSize(size, CGSizeMake(320, 568))) {
        return WHLScreenPhysicalSize_4_0_inch;
    }

    return WHLScreenPhysicalSizeUnknown; // 无法识别的屏幕尺寸
}

- (BOOL)whl_isRetinaDisplay
{
    return self.scale > 1;
}

+ (BOOL)whl_isIPhoneX
{
    static BOOL isIPhoneX;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isIPhoneX = ([[UIScreen mainScreen] whl_physicalSize] == WHLScreenPhysicalSize_5_8_inch);
    });
    return isIPhoneX;
}

- (CGFloat)whl_width
{
    return self.bounds.size.width;
}

- (CGFloat)whl_height
{
    return self.bounds.size.height;
}

@end
