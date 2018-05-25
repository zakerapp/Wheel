//
//  WHLLayoutConstraint.m
//  Wheel
//
//  Created by Steven Mok on 14-9-23.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import "WHLLayoutConstraint.h"

void WHLLayoutApplyConstraint(CGRect *outRect, CGRect inRect, WHLLayoutConstraint *constraint, WHLLayoutAttributeMask *appliedMask);
void WHLLayoutApplyConstraintsv(CGRect *outRect, CGRect inRect, va_list args);

@implementation WHLLayoutConstraint

+ (instancetype)constraintWithAttrOut:(WHLLayoutAttribute)attrOut attrIn:(WHLLayoutAttribute)attrIn multiplier:(CGFloat)multiplier constant:(CGFloat)constant
{
    WHLLayoutConstraint *constraint = [[WHLLayoutConstraint alloc] init];
    constraint.attrOut = attrOut;
    constraint.attrIn = attrIn;
    constraint.multiplier = multiplier;
    constraint.constant = constant;
    return constraint;
}

- (BOOL)isSize
{
    switch (self.attrOut) {
        case WHLLayoutAttributeWidth:
        case WHLLayoutAttributeHeight:
            return YES;
            break;
            
        default:
            break;
    }
    return NO;
}

- (BOOL)isLeading
{
    switch (self.attrOut) {
        case WHLLayoutAttributeLeft:
        case WHLLayoutAttributeTop:
            return YES;
            break;
            
        default:
            break;
    }
    return NO;
}

+ (instancetype)constraintAsAlignCenterX:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeCenterX attrIn:WHLLayoutAttributeCenterX multiplier:1 constant:constant];
}

+ (instancetype)constraintAsAlignCenterY:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeCenterY attrIn:WHLLayoutAttributeCenterY multiplier:1 constant:constant];
}

+ (instancetype)constraintAsAlignLeft:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeLeft attrIn:WHLLayoutAttributeLeft multiplier:1 constant:constant];
}

+ (instancetype)constraintAsAlignRight:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeRight attrIn:WHLLayoutAttributeRight multiplier:1 constant:constant];
}

+ (instancetype)constraintAsAlignTop:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeTop attrIn:WHLLayoutAttributeTop multiplier:1 constant:constant];
}

+ (instancetype)constraintAsAlignBottom:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeBottom attrIn:WHLLayoutAttributeBottom multiplier:1 constant:constant];
}

+ (instancetype)constraintAsPinLeft:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeRight attrIn:WHLLayoutAttributeLeft multiplier:1 constant:constant];
}

+ (instancetype)constraintAsPinRight:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeLeft attrIn:WHLLayoutAttributeRight multiplier:1 constant:constant];
}

+ (instancetype)constraintAsPinTop:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeBottom attrIn:WHLLayoutAttributeTop multiplier:1 constant:constant];
}

+ (instancetype)constraintAsPinBottom:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeTop attrIn:WHLLayoutAttributeBottom multiplier:1 constant:constant];
}

+ (instancetype)constraintAsWidth:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeWidth attrIn:WHLLayoutAttributeNone multiplier:1 constant:constant];
}

+ (instancetype)constraintAsHeight:(CGFloat)constant
{
    return [self constraintWithAttrOut:WHLLayoutAttributeHeight attrIn:WHLLayoutAttributeNone multiplier:1 constant:constant];
}

@end

void WHLLayoutApplyConstraintsv(CGRect *outRect, CGRect inRect, va_list args)
{
    NSMutableArray *sizeConstraints = [[NSMutableArray alloc] init];
    NSMutableArray *leadingConstraints = [[NSMutableArray alloc] init];
    NSMutableArray *trailingConstraints = [[NSMutableArray alloc] init];
    
    while (YES) {
        WHLLayoutConstraint *arg = va_arg(args, WHLLayoutConstraint *);
        
        if (arg == nil) {
            break;
        }
        
        if ([arg isSize]) {
            [sizeConstraints addObject:arg];
        } else if ([arg isLeading]) {
            [leadingConstraints addObject:arg];
        } else {
            [trailingConstraints addObject:arg];
        }
    }
    
    WHLLayoutAttributeMask appliedMask = 0;
    
    for (WHLLayoutConstraint *constraint in sizeConstraints) {
        WHLLayoutApplyConstraint(outRect, inRect, constraint, &appliedMask);
    }
    
    for (WHLLayoutConstraint *constraint in leadingConstraints) {
        WHLLayoutApplyConstraint(outRect, inRect, constraint, &appliedMask);
    }
    
    for (WHLLayoutConstraint *constraint in trailingConstraints) {
        WHLLayoutApplyConstraint(outRect, inRect, constraint, &appliedMask);
    }
}

void WHLLayoutApplyConstraints(CGRect *outRect, CGRect inRect, ...)
{
    va_list args;
    va_start(args, inRect);
    WHLLayoutApplyConstraintsv(outRect, inRect, args);
    va_end(args);
}

CGRect WHLLayoutRectApplyConstraints(CGRect rect, ...)
{
    CGRect result = rect;
    va_list args;
    va_start(args, rect);
    WHLLayoutApplyConstraintsv(&result, rect, args);
    va_end(args);
    return result;
}

CGFloat WHLLayoutGetValueForAttribute(CGRect rect, WHLLayoutAttribute attr)
{
    switch (attr) {
        case WHLLayoutAttributeLeft:
            return CGRectGetMinX(rect);
            break;
            
        case WHLLayoutAttributeRight:
            return CGRectGetMaxX(rect);
            break;
            
        case WHLLayoutAttributeTop:
            return CGRectGetMinY(rect);
            break;
            
        case WHLLayoutAttributeBottom:
            return CGRectGetMaxY(rect);
            break;
            
        case WHLLayoutAttributeWidth:
            return CGRectGetWidth(rect);
            break;
            
        case WHLLayoutAttributeHeight:
            return CGRectGetHeight(rect);
            break;
            
        case WHLLayoutAttributeCenterX:
            return CGRectGetMidX(rect);
            break;
            
        case WHLLayoutAttributeCenterY:
            return CGRectGetMidY(rect);
            break;
            
        default:
            break;
    }
    
    return 0;
}

void WHLLayoutApplyConstraint(CGRect *outRect, CGRect inRect, WHLLayoutConstraint *constraint, WHLLayoutAttributeMask *appliedMask)
{
    if (!outRect) {
        return;
    }
    
    CGFloat newValue = WHLLayoutGetValueForAttribute(inRect, constraint.attrIn) * constraint.multiplier + constraint.constant;
    
    switch (constraint.attrOut) {
        case WHLLayoutAttributeLeft:
            (*outRect).origin.x = newValue;
            *appliedMask |= WHLLayoutAttributeMaskLeft;
            break;
            
        case WHLLayoutAttributeRight:
            if ((*appliedMask & WHLLayoutAttributeMaskLeft) != 0 && (*appliedMask & WHLLayoutAttributeMaskWidth) == 0) {
                // 有左侧距离的约束，不可以改变X。没有宽度的约束，可以改变宽度。所以改变宽度。
                (*outRect).size.width = newValue - CGRectGetMinX(*outRect);
            } else if ((*appliedMask & WHLLayoutAttributeMaskLeft) == 0 && (*appliedMask & WHLLayoutAttributeMaskWidth) != 0) {
                // 没有左侧距离的约束，可以改变X。有宽度的约束，不可以改变宽度。所以改变X。
                (*outRect).origin.x = newValue - CGRectGetWidth(*outRect);
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Invalid Constraint." userInfo:nil];
            }
            
            *appliedMask |= WHLLayoutAttributeMaskRight;
            break;
            
        case WHLLayoutAttributeTop:
            (*outRect).origin.y = newValue;
            *appliedMask |= WHLLayoutAttributeMaskTop;
            break;
            
        case WHLLayoutAttributeBottom:
            if ((*appliedMask & WHLLayoutAttributeMaskTop) != 0 && (*appliedMask & WHLLayoutAttributeMaskHeight) == 0) {
                // 有顶部距离的约束，不可以改变Y。没有高度的约束，可以改变高度。所以改变高度。
                (*outRect).size.height = newValue - CGRectGetMinY(*outRect);
            } else if ((*appliedMask & WHLLayoutAttributeMaskTop) == 0 && (*appliedMask & WHLLayoutAttributeMaskHeight) != 0) {
                // 没有顶部距离的约束，可以改变Y。有高度的约束，不可以改变高度。所以改变Y。
                (*outRect).origin.y = newValue - CGRectGetHeight(*outRect);
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Invalid Constraint." userInfo:nil];
            }
            *appliedMask |= WHLLayoutAttributeMaskBottom;
            break;
            
        case WHLLayoutAttributeWidth:
            (*outRect).size.width = newValue;
            *appliedMask |= WHLLayoutAttributeMaskWidth;
            break;
            
        case WHLLayoutAttributeHeight:
            (*outRect).size.height = newValue;
            *appliedMask |= WHLLayoutAttributeMaskHeight;
            break;
            
        case WHLLayoutAttributeCenterX:
            (*outRect).origin.x = newValue - CGRectGetWidth(*outRect) / 2;
            *appliedMask |= WHLLayoutAttributeMaskCenterX;
            break;
            
        case WHLLayoutAttributeCenterY:
            (*outRect).origin.y = newValue - CGRectGetHeight(*outRect) / 2;
            *appliedMask |= WHLLayoutAttributeMaskCenterY;
            break;
            
        case WHLLayoutAttributeNone:
            break;
    }
}

