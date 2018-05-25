//
//  WHLView.h
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern void WHLQuickConstraint(id view1, NSLayoutAttribute attr1, NSLayoutRelation relation, __nullable id view2, NSLayoutAttribute attr2, CGFloat multiplier, CGFloat constant, UIView *addToView);

extern void WHLQuickConstraintConstant(id view1, NSLayoutAttribute attr1, NSLayoutRelation relation, CGFloat constant);

@interface UIView (WHLAdditions)

- (void)whl_setOrigin:(CGPoint)origin;

- (void)whl_setSize:(CGSize)size;

- (void)whl_addBorderWithColor:(UIColor *)color;

- (void)whl_addBorderWithColor:(UIColor *)color width:(CGFloat)width;

- (void)whl_sizeToFitSize:(CGSize)size;

- (nullable UITableViewCell *)whl_parentTableViewCell;

- (nullable UIImage *)whl_snapshotImage;

@end

@interface UIResponder (WHLAdditions)

- (nullable UIViewController *)whl_nextResponsableViewController;

@end

NS_ASSUME_NONNULL_END
