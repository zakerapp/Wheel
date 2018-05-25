//
//  WHLLayoutConstraint.h
//  Wheel
//
//  Created by Steven Mok on 14-9-23.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLDefines.h"

typedef NS_ENUM (NSInteger, WHLLayoutAttribute) {
    WHLLayoutAttributeNone = 0,
    WHLLayoutAttributeLeft,
    WHLLayoutAttributeRight,
    WHLLayoutAttributeTop,
    WHLLayoutAttributeBottom,
    WHLLayoutAttributeWidth,
    WHLLayoutAttributeHeight,
    WHLLayoutAttributeCenterX,
    WHLLayoutAttributeCenterY,
};

typedef NS_OPTIONS (NSInteger, WHLLayoutAttributeMask) {
    WHLLayoutAttributeMaskLeft = (1 << WHLLayoutAttributeLeft),
    WHLLayoutAttributeMaskRight = (1 << WHLLayoutAttributeRight),
    WHLLayoutAttributeMaskTop = (1 << WHLLayoutAttributeTop),
    WHLLayoutAttributeMaskBottom = (1 << WHLLayoutAttributeBottom),
    WHLLayoutAttributeMaskWidth = (1 << WHLLayoutAttributeWidth),
    WHLLayoutAttributeMaskHeight = (1 << WHLLayoutAttributeHeight),
    WHLLayoutAttributeMaskCenterX = (1 << WHLLayoutAttributeCenterX),
    WHLLayoutAttributeMaskCenterY = (1 << WHLLayoutAttributeCenterY),
};

WHL_EXTERN void WHLLayoutApplyConstraints(CGRect *outRect, CGRect inRect, ...) NS_REQUIRES_NIL_TERMINATION;

WHL_EXTERN CGRect WHLLayoutRectApplyConstraints(CGRect rect, ...) NS_REQUIRES_NIL_TERMINATION;

@interface WHLLayoutConstraint : NSObject

@property (nonatomic) WHLLayoutAttribute attrOut;

@property (nonatomic) WHLLayoutAttribute attrIn;

@property (nonatomic) CGFloat multiplier;

@property (nonatomic) CGFloat constant;

// attrOut = attrIn * multiplier + constant, if WHLLayoutAttributeNone, attrOut = constant
+ (instancetype)constraintWithAttrOut:(WHLLayoutAttribute)attrOut attrIn:(WHLLayoutAttribute)attrIn multiplier:(CGFloat)multiplier constant:(CGFloat)constant;

// Convinience
+ (instancetype)constraintAsAlignCenterX:(CGFloat)constant;

+ (instancetype)constraintAsAlignCenterY:(CGFloat)constant;

+ (instancetype)constraintAsAlignLeft:(CGFloat)constant;

+ (instancetype)constraintAsAlignRight:(CGFloat)constant;

+ (instancetype)constraintAsAlignTop:(CGFloat)constant;

+ (instancetype)constraintAsAlignBottom:(CGFloat)constant;

+ (instancetype)constraintAsPinLeft:(CGFloat)constant;

+ (instancetype)constraintAsPinRight:(CGFloat)constant;

+ (instancetype)constraintAsPinTop:(CGFloat)constant;

+ (instancetype)constraintAsPinBottom:(CGFloat)constant;

+ (instancetype)constraintAsWidth:(CGFloat)constant;

+ (instancetype)constraintAsHeight:(CGFloat)constant;

@end

