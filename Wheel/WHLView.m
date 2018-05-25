//
//  WHLView.m
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WHLDevice.h"
#import "WHLView.h"

void WHLQuickConstraint(id view1, NSLayoutAttribute attr1, NSLayoutRelation relation, __nullable id view2, NSLayoutAttribute attr2, CGFloat multiplier, CGFloat constant, UIView *addToView)
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:constant];
    [addToView addConstraint:constraint];
}

void WHLQuickConstraintConstant(id view1, NSLayoutAttribute attr1, NSLayoutRelation relation, CGFloat constant)
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:constant];
    [view1 addConstraint:constraint];
}

@implementation UIView (WHLAdditions)

- (void)whl_setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)whl_setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)whl_addBorderWithColor:(UIColor *)color
{
    [self whl_addBorderWithColor:color width:1.f];
}

- (void)whl_addBorderWithColor:(UIColor *)color width:(CGFloat)width
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (void)whl_sizeToFitSize:(CGSize)size
{
    CGSize toSize = [self sizeThatFits:size];
    CGRect bounds = self.bounds;
    bounds.size = toSize;
    self.bounds = bounds;
}

- (UITableViewCell *)whl_parentTableViewCell
{
    id superview = self.superview;
    if (superview) {
        if ([superview isKindOfClass:[UITableViewCell class]]) {
            return superview;
        } else {
            return [superview whl_parentTableViewCell];
        }
    }
    return nil;
}

- (UIImage *)whl_snapshotImage
{
    CGRect rect = self.bounds;

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);

    CGContextRef context = UIGraphicsGetCurrentContext();

    [self.layer renderInContext:context];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

@end

@implementation UIResponder (WHLAdditions)

- (UIViewController *)whl_nextResponsableViewController
{
    id responder = [self nextResponder];

    if ([responder isKindOfClass:[UIViewController class]]) {
        return responder;
    }

    if ([responder isKindOfClass:[UIResponder class]]) {
        return [responder whl_nextResponsableViewController];
    }

    return nil;
}

@end
