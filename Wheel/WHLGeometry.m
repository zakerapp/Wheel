//
//  WHLGeometry.m
//  Wheel
//
//  Created by Steven Mok on 13-10-10.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLGeometry.h"

const WHLOffset WHLOffsetZero = { 0, 0 };

const WHLLine WHLLineZero = { { 0, 0 }, { 0, 0 } };

BOOL WHLOffsetEqualToOffset(WHLOffset offset1, WHLOffset offset2)
{
    if (offset1.horizontal == offset2.horizontal
        && offset1.vertical == offset2.vertical) {
        return YES;
    }

    return NO;
}

CGRect WHLRectHorizontalFlip(CGRect rect, CGFloat flippingHeight)
{
    CGFloat newOriginY = flippingHeight - CGRectGetMaxY(rect);

    CGRect final = rect;
    final.origin.y = newOriginY;

    return final;
}

CGRect WHLRectIntegralFloor(CGRect rect)
{
    return CGRectMake(floorf(rect.origin.x), floorf(rect.origin.y), floorf(rect.size.width), floorf(rect.size.height));
}

CGRect WHLRectIntegralCeil(CGRect rect)
{
    return CGRectMake(ceilf(rect.origin.x), ceilf(rect.origin.y), ceilf(rect.size.width), ceilf(rect.size.height));
}

CGPoint WHLRectGetCenter(CGRect rect)
{
    return CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
}

CGRect WHLRectDivideGetReminder(CGRect rect, CGFloat amount, CGRectEdge edge)
{
    CGRect remainder, slice;
    CGRectDivide(rect, &slice, &remainder, amount, edge);
    return remainder;
}

CGRect WHLRectDivideGetSlice(CGRect rect, CGFloat amount, CGRectEdge edge)
{
    CGRect remainder, slice;
    CGRectDivide(rect, &slice, &remainder, amount, edge);
    return slice;
}

CGRect WHLRectInsetEdges(CGRect rect, UIEdgeInsets edgeInsets)
{
    rect.origin.x += edgeInsets.left;
    rect.size.width -= edgeInsets.left + edgeInsets.right;

    rect.origin.y += edgeInsets.top;
    rect.size.height -= edgeInsets.top + edgeInsets.bottom;

    if (rect.size.width < 0) {
        rect.size.width = 0;
    }

    if (rect.size.height < 0) {
        rect.size.height = 0;
    }

    return rect;
}

WHLRectEdge WHLRectDirectionToRect(CGRect rect1, CGRect rect2)
{
    WHLRectEdge direction = WHLRectEdgeNone;

    if (CGRectGetMinX(rect1) < CGRectGetMinX(rect2)) {
        direction |= WHLRectEdgeLeft;
    }

    if (CGRectGetMaxX(rect1) > CGRectGetMaxX(rect2)) {
        direction |= WHLRectEdgeRight;
    }

    if (CGRectGetMinY(rect1) < CGRectGetMinY(rect2)) {
        direction |= WHLRectEdgeTop;
    }

    if (CGRectGetMaxY(rect1) > CGRectGetMaxY(rect2)) {
        direction |= WHLRectEdgeBottom;
    }

    if ((direction & WHLRectEdgeLeft) && (direction & WHLRectEdgeRight)) {
        direction &= ~(WHLRectEdgeLeft | WHLRectEdgeRight);
    }

    if ((direction & WHLRectEdgeTop) && (direction & WHLRectEdgeBottom)) {
        direction &= ~(WHLRectEdgeTop | WHLRectEdgeBottom);
    }

    return direction;
}

CGFloat WHLRectOffsetForDistance(CGFloat distance)
{
    return MIN(20.f, distance / 10.f);
}

CGFloat WHLRectInsetForLengthDifference(CGFloat difference)
{
    return MIN(20.f, difference / 10.f);
}

CGRect WHLRectBounceForMovingToRect(CGRect rect1, CGRect rect2)
{
    WHLRectEdge direction = WHLRectDirectionToRect(rect1, rect2);

    WHLOffset translation = WHLOffsetZero;
    WHLOffset scale = WHLOffsetZero;

    if (direction & WHLRectEdgeLeft) {
        CGFloat distance = CGRectGetMinX(rect2) - CGRectGetMinX(rect1);
        translation.horizontal += WHLRectOffsetForDistance(distance);
    }

    if (direction & WHLRectEdgeRight) {
        CGFloat distance = CGRectGetMaxX(rect1) - CGRectGetMaxX(rect2);
        translation.horizontal -= WHLRectOffsetForDistance(distance);
    }

    if (direction & WHLRectEdgeTop) {
        CGFloat distance = CGRectGetMinY(rect2) - CGRectGetMinY(rect1);
        translation.vertical += WHLRectOffsetForDistance(distance);
    }

    if (direction & WHLRectEdgeBottom) {
        CGFloat distance = CGRectGetMaxY(rect1) - CGRectGetMaxY(rect2);
        translation.vertical -= WHLRectOffsetForDistance(distance);
    }

    if (rect2.size.width > rect1.size.width) {
        scale.horizontal = WHLRectInsetForLengthDifference(rect2.size.width - rect1.size.width);
    }

    if (rect2.size.height > rect1.size.height) {
        scale.vertical = WHLRectInsetForLengthDifference(rect2.size.height - rect1.size.height);
    }

    CGRect result = rect2;
    result = CGRectInset(result, -scale.horizontal, -scale.vertical);
    result = CGRectOffset(result, translation.horizontal, translation.vertical);

    return result;
}

CGSize WHLSizeCeil(CGSize size)
{
    return CGSizeMake(ceilf(size.width), ceilf(size.height));
}

CGSize WHLSizeFloor(CGSize size)
{
    return CGSizeMake(floorf(size.width), floorf(size.height));
}

CGSize WHLSizeAspectFitSize(CGSize size1, CGSize size2)
{
    CGFloat scale = MIN(size2.width / size1.width, size2.height / size1.height);
    return CGSizeMake(size1.width * scale, size1.height * scale);
}
