//
//  WHLColor.m
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLColor.h"
#import "WHLGeometry.h"

const CGFloat WHLPerceivedBrightnessInvalid = -1.f;

#if !TARGET_OS_WATCH
static UIColor * WHLGetFirstLineCompositionColorMaster(UIView *view, UIImage *image);

UIColor * WHLGetFirstLineCompositionColorWithView(UIView *view)
{
    return WHLGetFirstLineCompositionColorMaster(view, nil);
}

UIColor * WHLGetFirstLineCompositionColorWithImage(UIImage *image)
{
    return WHLGetFirstLineCompositionColorMaster(nil, image);
}

UIColor * WHLGetFirstLineCompositionColorMaster(UIView *view, UIImage *image)
{
    // First get the image into your data buffer
    NSUInteger width = 0;
    NSUInteger height = 0;

    if (view) {
        width = view.frame.size.width;
        height = view.frame.size.height;
    } else if (image) {
        width = CGImageGetWidth(image.CGImage);
        height = CGImageGetHeight(image.CGImage);
    } else {
        return nil;
    }

    if (height < 1) {
        return nil; // 像素不够
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = WHLByteAlignForCoreAnimation(bytesPerPixel * width);
    unsigned char *rawData = (unsigned char *)calloc(height * bytesPerRow, sizeof(unsigned char));
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextSaveGState(context);
    if (view) {
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1.0, -1.0);
        [view.layer renderInContext:context];
    } else if (image) {
        CGImageRef imageRef = [image CGImage];
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    }
    CGContextRestoreGState(context);

    CGContextRelease(context);

    UIColor *color = nil;

    // Now your rawData contains the image data in the RGBA8888 pixel format.
    if (width > 0) {
        NSUInteger red = 0;
        NSUInteger green = 0;
        NSUInteger blue = 0;
        NSUInteger alpha = 0;

        NSUInteger byteIndex = 0;
        for (NSUInteger i = 0; i < width; ++i) {
            red   += rawData[byteIndex];
            green += rawData[byteIndex + 1];
            blue  += rawData[byteIndex + 2];
            alpha += rawData[byteIndex + 3];
            byteIndex += bytesPerPixel;
        }

        CGFloat fred = red / width / 255.0;
        CGFloat fgreen = green / width / 255.0;
        CGFloat fblue = blue / width / 255.0;
        CGFloat falpha = alpha / width / 255.0;

        color = [UIColor colorWithRed:fred green:fgreen blue:fblue alpha:falpha];
    } else {
        color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0]; // 透明白色
    }

    free(rawData);

    return color;
}

#endif

@implementation UIColor (WHLAdditions)

+ (UIColor *)whl_colorWithRGBString:(NSString *)string
{
    return [[self class] whl_colorWithRGBString:string alpha:1.0f];
}

+ (UIColor *)whl_colorWithRGBString:(NSString *)string alpha:(CGFloat)alpha
{
    if (!string || [string length] < 6) {
        return nil;
    }

    const char *cStr = [string cStringUsingEncoding:NSASCIIStringEncoding];
    long hex;
    if ([string length] <= 6) {
        hex = strtol(cStr, NULL, 16);
    } else {
        hex = strtol(cStr + 1, NULL, 16);
    }
    return [self whl_colorWithRGBHex:(NSUInteger)hex alpha:alpha];
}

+ (UIColor *)whl_colorWithRGBHex:(NSUInteger)hex
{
    return [self whl_colorWithRGBHex:hex alpha:1.0f];
}

+ (UIColor *)whl_colorWithRGBHex:(NSUInteger)hex alpha:(CGFloat)alpha
{
    unsigned char red = (hex >> 16) & 0xFF;
    unsigned char green = (hex >> 8) & 0xFF;
    unsigned char blue = hex & 0xFF;

    return [UIColor colorWithRed:(CGFloat)red / 255.0f
                           green:(CGFloat)green / 255.0f
                            blue:(CGFloat)blue / 255.0f
                           alpha:alpha];
}

- (NSString *)whl_RGBStringRepresentation
{
    return [self whl_RGBStringRepresentationWitAlpha:NO];
}

- (NSString *)whl_RGBStringRepresentationWitAlpha:(BOOL)alphaFlag
{
    size_t componentCount = CGColorGetNumberOfComponents(self.CGColor);

    if (componentCount != 4) {
        return @"#000000"; // return black color if color is not in RGB color space
    }

    const CGFloat *components = CGColorGetComponents(self.CGColor);

    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    CGFloat alpha = components[3];

    NSString *colorString;

    if (alphaFlag) {
        colorString = [NSString stringWithFormat:@"#%.2X%.2X%.2X %.2f", (unsigned int)(red * 255.f), (unsigned int)(green * 255.f), (unsigned int)(blue * 255.f), alpha];
    } else {
        colorString = [NSString stringWithFormat:@"#%.2X%.2X%.2X", (unsigned int)(red * 255.f), (unsigned int)(green * 255.f), (unsigned int)(blue * 255.f)];
    }

    return colorString;
}

- (UIColor *)whl_colorWithAlpha:(CGFloat)alpha
{
    CGColorRef cgcolor = CGColorCreateCopyWithAlpha(self.CGColor, alpha);
    UIColor *result = [UIColor colorWithCGColor:cgcolor];
    CGColorRelease(cgcolor);
    return result;
}

- (UIColor *)whl_colorByInterpolatingWith:(UIColor *)color factor:(CGFloat)factor
{
    factor = MIN(MAX(factor, 0.0), 1.0);

    const CGFloat *startComponent = CGColorGetComponents(self.CGColor);
    const CGFloat *endComponent = CGColorGetComponents(color.CGColor);

    float startAlpha = CGColorGetAlpha(self.CGColor);
    float endAlpha = CGColorGetAlpha(color.CGColor);

    float r = startComponent[0] + (endComponent[0] - startComponent[0]) * factor;
    float g = startComponent[1] + (endComponent[1] - startComponent[1]) * factor;
    float b = startComponent[2] + (endComponent[2] - startComponent[2]) * factor;
    float a = startAlpha + (endAlpha - startAlpha) * factor;

    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (CGFloat)whl_perceivedBrightness
{
    CGFloat r, g, b, a;

    [self getRed:&r green:&g blue:&b alpha:&a];

    CGFloat brightness = WHLPerceivedBrightnessInvalid;
    if (a > 0.01) { // 不透明度大于0.01即算是不透明
        brightness = 0.2126 * r + 0.7152 * g + 0.0722 * b; // ITU-R BT.709
    }

    return brightness;
}

- (BOOL)whl_prefersLightContent
{
    CGFloat brightness = [self whl_perceivedBrightness];
    if (brightness == WHLPerceivedBrightnessInvalid) {
        return NO;
    }
    return brightness < 0.8;
}

@end
