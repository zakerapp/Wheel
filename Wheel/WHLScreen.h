//
//  WHLScreen.h
//  Wheel
//
//  Created by Steven Mok on 14-1-26.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLDefines.h"

#define WHL_IPHONEX_TOP_INSET    44.0
#define WHL_IPHONEX_BOTTOM_INSET 34.0

typedef NS_ENUM (NSInteger, WHLScreenPhysicalSize) {
    WHLScreenPhysicalSizeUnknown   = -1,
    WHLScreenPhysicalSize_3_5_inch = 0, // iPhone 4, 或者是在 iPad 上运行 iPhone App
    WHLScreenPhysicalSize_4_0_inch = 1, // iPhone 5, 或者是 iPhone 6 使用放大模式
    WHLScreenPhysicalSize_4_7_inch = 2, // iPhone 6, 或者是 iPhone 6 Plus 使用放大模式
    WHLScreenPhysicalSize_5_5_inch = 3, // iPhone 6 Plus
    WHLScreenPhysicalSize_5_8_inch = 4, // iPhone X
};

WHL_EXTERN CGFloat WHLOnePixelToPoint(void);

WHL_EXTERN CGFloat WHLPixelToPoint(CGFloat pixel);

@interface UIScreen (WHLAdditions)

- (BOOL)whl_isRetinaDisplay;

- (WHLScreenPhysicalSize)whl_physicalSize;

+ (BOOL)whl_isIPhoneX;

- (CGFloat)whl_width;

- (CGFloat)whl_height;

@end
