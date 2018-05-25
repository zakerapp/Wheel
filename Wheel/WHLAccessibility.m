//
//  WHLAccessibility.m
//  Wheel
//
//  Created by Steven Mok on 13-10-10.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLAccessibility.h"

#if !TARGET_OS_WATCH
#import <CoreText/CoreText.h>
#endif

@implementation NSString (WHLAccessibility)

#if !TARGET_OS_WATCH

- (CGSize)whl_sizeWithFont:(UIFont *)font
{
    return [self whl_sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 1) lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)whl_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];

    if (font) {
        attributes[NSFontAttributeName] = font;
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;

    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}

- (void)whl_drawInRect:(CGRect)rect withFont:(UIFont *)font foregroundColor:(UIColor *)foregroundColor
{
    [self whl_drawInRect:rect withFont:font foregroundColor:foregroundColor lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
}

- (void)whl_drawInRect:(CGRect)rect withFont:(UIFont *)font foregroundColor:(UIColor *)foregroundColor lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];

    if (font) {
        attributes[NSFontAttributeName] = font;
    }

    if (foregroundColor) {
        attributes[NSForegroundColorAttributeName] = foregroundColor;
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = alignment;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;

    [self drawInRect:rect withAttributes:attributes];
}

#endif

@end
