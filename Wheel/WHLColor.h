//
//  WHLColor.h
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat WHLPerceivedBrightnessInvalid;

#if !TARGET_OS_WATCH
extern UIColor * WHLGetFirstLineCompositionColorWithView(UIView *view);
extern UIColor * WHLGetFirstLineCompositionColorWithImage(UIImage *image);
#endif

@interface UIColor (WHLAdditions)

/**
 用十六进制数生成对应的 UIColor

 @param hex 十六进制数
 @return 对应的 UIColor
 */
+ (UIColor *)whl_colorWithRGBHex:(NSUInteger)hex;

/**
 用十六进制数生成对应的 UIColor

 @param hex 十六进制数
 @param alpha 透明度
 @return 对应的 UIColor
 */
+ (UIColor *)whl_colorWithRGBHex:(NSUInteger)hex alpha:(CGFloat)alpha;

/**
 用字符串生成对应的 UIColor

 @param string 字符串
 @return 对应的 UIColor
 */
+ (UIColor *)whl_colorWithRGBString:(NSString *)string;

/**
 用字符串生成对应的 UIColor

 @param string 字符串
 @param alpha 透明度
 @return 对应的 UIColor
 */
+ (UIColor *)whl_colorWithRGBString:(NSString *)string alpha:(CGFloat)alpha;

/**
 将 UIColor 转换成对应的字符串

 @return 对应的字符串
 */
- (NSString *)whl_RGBStringRepresentation;

/**
 将 UIColor 转换成对应的字符串

 @param alphaFlag 是否显示透明度
 @return 对应的字符串
 */
- (NSString *)whl_RGBStringRepresentationWitAlpha:(BOOL)alphaFlag;

/**
 将 UIColor 加上透明度值生成新的 UIColor

 @param alpha 透明度
 @return 加上透明度值后的 UIColor
 */
- (UIColor *)whl_colorWithAlpha:(CGFloat)alpha;

/**
 将当前的 UIColor 与目标的 UIColor 进行插值运算，得到新的 UIColor，可用于实现渐变颜色效果

 @param color 目标颜色
 @param factor 插值因子，代表当前颜色往目标颜色靠近的程度
 @return 进行插值运算后得到的新的 UIColor
 */
- (UIColor *)whl_colorByInterpolatingWith:(UIColor *)color factor:(CGFloat)factor;

/**
 获取 UIColor 的亮度

 @return 亮度值
 */
- (CGFloat)whl_perceivedBrightness;

/**
 判断 UIColor 是否属于浅色，亮度值小于 0.8 则返回 YES

 @return UIColor 是否属于浅色
 */
- (BOOL)whl_prefersLightContent;

@end
