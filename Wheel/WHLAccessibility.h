//
//  WHLAccessibility.h
//  Wheel
//
//  Created by Steven Mok on 13-10-10.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (WHLAccessibility)

#if !TARGET_OS_WATCH

/**
 计算字符串显示完全所需要的尺寸

 @param font 字体
 @return 字符串显示完全所需要的尺寸
 */
- (CGSize)whl_sizeWithFont:(UIFont *)font;

/**
 计算字符串在限制尺寸情况下显示完全所需要的尺寸

 @param font 字体
 @param size 限制尺寸
 @param lineBreakMode 文字截断方式
 @return 字符串在限制尺寸情况下显示完全所需要的尺寸
 */
- (CGSize)whl_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 绘制文本

 @param rect 绘制区域
 @param font 字体
 @param foregroundColor 文本颜色
 */
- (void)whl_drawInRect:(CGRect)rect withFont:(UIFont *)font foregroundColor:(UIColor *)foregroundColor;

/**
 绘制文本

 @param rect 绘制区域
 @param font 字体
 @param foregroundColor 文本颜色
 @param lineBreakMode 文字截断方式
 @param alignment 对齐方式
 */
- (void)whl_drawInRect:(CGRect)rect withFont:(UIFont *)font foregroundColor:(UIColor *)foregroundColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment;

#endif

@end

