//
//  WHLGeometry.h
//  Wheel
//
//  Created by Steven Mok on 13-10-10.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>
#import "WHLDefines.h"

typedef struct {
    CGPoint start;
    CGPoint end;
} WHLLine;

typedef struct {
    CGFloat horizontal;
    CGFloat vertical;
} WHLOffset;

// *INDENT-OFF*
typedef NS_OPTIONS (NSUInteger, WHLRectEdge) {
    WHLRectEdgeNone   = 0,
    WHLRectEdgeTop    = 1 << 0,
    WHLRectEdgeLeft   = 1 << 1,
    WHLRectEdgeBottom = 1 << 2,
    WHLRectEdgeRight  = 1 << 3,
    WHLRectEdgeAll    = WHLRectEdgeTop | WHLRectEdgeLeft | WHLRectEdgeBottom | WHLRectEdgeRight
};
// *INDENT-ON*

WHL_EXTERN const WHLOffset WHLOffsetZero;

WHL_EXTERN const WHLLine WHLLineZero;

WHL_EXTERN CGRect WHLRectHorizontalFlip(CGRect rect, CGFloat flippingHeight);

WHL_EXTERN CGRect WHLRectIntegralFloor(CGRect rect);

WHL_EXTERN CGRect WHLRectIntegralCeil(CGRect rect);

WHL_EXTERN CGPoint WHLRectGetCenter(CGRect rect);

WHL_EXTERN CGRect WHLRectDivideGetSlice(CGRect rect, CGFloat amount, CGRectEdge edge);

WHL_EXTERN CGRect WHLRectDivideGetReminder(CGRect rect, CGFloat amount, CGRectEdge edge);

/**
 Inset a rect with the edge insets.
 @param rect Rect to inset.
 @param edgeInsets Positive value means shrink (becoming smaller).
 @returns New rect after inset.
 */
WHL_EXTERN CGRect WHLRectInsetEdges(CGRect rect, UIEdgeInsets edgeInsets);

WHL_EXTERN WHLRectEdge WHLRectDirectionToRect(CGRect rect1, CGRect rect2);

WHL_EXTERN CGRect WHLRectBounceForMovingToRect(CGRect rect1, CGRect rect2);

WHL_EXTERN CGSize WHLSizeCeil(CGSize size);

WHL_EXTERN CGSize WHLSizeFloor(CGSize size);

/**
 计算size1适应size2的时候该变成什么size
 @param size1 原始的size
 @param size2 要适应的size
 @returns size1等比例缩放后的size
 */
WHL_EXTERN CGSize WHLSizeAspectFitSize(CGSize size1, CGSize size2);

WHL_EXTERN BOOL WHLOffsetEqualToOffset(WHLOffset offset1, WHLOffset offset2);

WHL_INLINE WHLLine WHLLineMake(CGPoint start, CGPoint end)
{
    WHLLine line;
    line.start = start; line.end = end;
    return line;
}

WHL_INLINE WHLOffset WHLOffsetMake(CGFloat horizontal, CGFloat vertical)
{
    WHLOffset offset;
    offset.horizontal = horizontal; offset.vertical = vertical;
    return offset;
}

/**
 Make a new rect with a rect's center and a size.

 @param rect Use this rect's center as new rect's center.
 @param size New rect's size.
 @returns A new rect.
 */
WHL_INLINE CGRect WHLRectMakeWithRectAndSize(CGRect rect, CGSize size)
{
    return CGRectMake(rect.origin.x + (rect.size.width - size.width) / 2, rect.origin.y + (rect.size.height - size.height) / 2, size.width, size.height);
}

WHL_INLINE size_t WHLByteAlign(size_t width, size_t alignment)
{
    return ((width + (alignment - 1)) / alignment) * alignment;
}

WHL_INLINE size_t WHLByteAlignForCoreAnimation(size_t bytesPerRow)
{
    return WHLByteAlign(bytesPerRow, 64);
}
