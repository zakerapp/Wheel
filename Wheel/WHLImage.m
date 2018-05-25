//
//  WHLImage.m
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLImage.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "WHLAccessibility.h"
#import "WHLCache.h"
#import "WHLColor.h"
#import "WHLDevice.h"
#import "WHLError.h"
#import "WHLGeometry.h"

#ifndef BYTE_SIZE
#define BYTE_SIZE        8 // byte size in bits
#endif

static BOOL WHLImageDisplaysFaceFrame = NO;
static BOOL WHLImageFaceDetectionDisabled = NO;

#define ALGORITHM_OFFSET 8

// *INDENT-OFF*
typedef NS_OPTIONS (NSUInteger, WHLImageCroppingOptions) {
    WHLImageCroppingOptionNone                = 0,
    WHLImageCroppingOptionAddCroppingShadow   = 1 << 0,
    WHLImageCroppingOptionAlphaChannel        = 1 << 1,

    WHLImageCroppingOptionAlgorithmCenter     = 0 << ALGORITHM_OFFSET,
    WHLImageCroppingOptionAlgorithmTop        = 1 << ALGORITHM_OFFSET,
    WHLImageCroppingOptionAlgorithmPortrait   = 2 << ALGORITHM_OFFSET,
    WHLImageCroppingOptionAlgorithmDetectFace = 3 << ALGORITHM_OFFSET
};
// *INDENT-ON*

enum : NSInteger {
    WHLImageCroppingOptionAlgorithmMask = 0xF << ALGORITHM_OFFSET
};

@interface WHLImageManager : NSObject

@property (nonatomic) WHLCache *imageCache;

@property (nonatomic) NSLock *detectorLock;

@property (nonatomic) CIDetector *detector;

@property (nonatomic) CIContext *detectorContext;

@end

@implementation WHLImageManager

+ (WHLImageManager *)sharedImageManager
{
    static WHLImageManager *sharedImageManager;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedImageManager = [[WHLImageManager alloc] init];
    });

    return sharedImageManager;
}

- (id)init
{
    self = [super init];

    if (self) {
        _detectorLock = [[NSLock alloc] init];
    }

    return self;
}

- (WHLCache *)imageCache
{
    if (!_imageCache) {
        _imageCache = [[WHLCache alloc] init];
        _imageCache.countLimit = 100;
    }
    return _imageCache;
}

- (CIContext *)detectorContext
{
    if (!_detectorContext) {
        UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
        if (appState == UIApplicationStateActive) {
            _detectorContext = [CIContext contextWithOptions:nil];
        }
    }

    return _detectorContext;
}

- (CIDetector *)detector
{
    if (!_detector) {
        if (self.detectorContext) {
            NSDictionary *options = @{ CIDetectorAccuracy: CIDetectorAccuracyLow };
            _detector = [CIDetector detectorOfType:CIDetectorTypeFace context:self.detectorContext options:options];
        }
    }

    return _detector;
}

- (NSArray *)featuresInImage:(UIImage *)uiimage
{
    CIImage *ciimage = uiimage.CIImage;
    if (!ciimage) {
        ciimage = [CIImage imageWithCGImage:uiimage.CGImage];
    }

    if (!ciimage) {
        return nil;
    }

    NSArray *features = nil;

    [_detectorLock lock];
    if (self.detector) {
        features = [self.detector featuresInImage:ciimage];
    }
    [_detectorLock unlock];

    return features;
}

@end

@implementation UIImage (WHLAdditions)

+ (UIImage *)whl_imageNamed:(NSString *)name
{
    if (!(name.length > 0)) {
        return nil;
    }

    UIImage *result = [[WHLImageManager sharedImageManager].imageCache objectForKey:name];
    if (!result) {
        result = [self imageNamed:name];
        [[WHLImageManager sharedImageManager].imageCache setObject:result forKey:name];
    }

    return result;
}

+ (UIImage *)whl_imageNamed:(NSString *)name tintColor:(UIColor *)tintColor
{
    return [[self imageNamed:name] imageWithTintColor:tintColor];
}

+ (UIImage *)whl_imageWithColor:(UIColor *)color
                         opaque:(BOOL)opaque
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2, 2), opaque, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(context, CGRectMake(0, 0, 2, 2));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)whl_imageByCroppingToRect:(CGRect)rect opaque:(BOOL)opaque
{
    return [self whl_imageByCroppingToRect:rect tintColor:nil opaque:opaque];
}

- (UIImage *)whl_imageByCroppingToRect:(CGRect)rect tintColor:(UIColor *)tintColor opaque:(BOOL)opaque
{
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, 0);

    CGSize drawingSize = self.size;
    CGFloat offsetMinX = -CGRectGetMinX(rect);
    CGFloat offsetMinY = -CGRectGetMinY(rect);
    CGRect drawingRect = CGRectMake(offsetMinX, offsetMinY, drawingSize.width, drawingSize.height);

    if (tintColor) {
        [tintColor setFill];
        UIRectFill(drawingRect);
        [self drawInRect:drawingRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    } else {
        [self drawInRect:drawingRect blendMode:kCGBlendModeNormal alpha:1.0f];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)whl_imageThatZoomOutToFitSize:(CGSize)size
{
    if (self.size.width <= size.width && self.size.height <= size.height) {
        return [[UIImage alloc] initWithCGImage:self.CGImage];
    }

    return [self whl_imageThatScaleAndCropToFitSize:size];
}

/**
 根据 receiver 的图片内容，返回一个新的大小为 \c toFitSize 的图片。

 @param toFitSize 目标大小，会将 receiver 拉伸或缩小以撑满 toFitSize，但是不会变形
 @param options 选项
 @returns 裁剪好的大小为 toFitSize 的图片。
 */
- (UIImage *)whl_imageThatScaleAndCropToFitSize:(CGSize)toFitSize
                                        options:(WHLImageCroppingOptions)options
{
    // 这里加上自动释放池是为了防止系统内存泄露，不要随便删除。
    // 虽然理论上应该不用加，不过实际上加了后内存泄露就好了一点。
    @autoreleasepool {
        if (self.CGImage == nil) {
            return self;
        }

        CGSize imageOriginalSize = self.size;

        if (imageOriginalSize.width <= 0 || imageOriginalSize.height <= 0) {
            return self;
        }

        // scale 一般是小于 1 的，即代表缩小。这里取 MAX，意思是尽量用最大的尺寸去适应 toFitSize
        CGFloat imageZoomScale = MAX(toFitSize.width / imageOriginalSize.width, toFitSize.height / imageOriginalSize.height);

        CGFloat pixelScale = [UIScreen mainScreen].scale;

        // 图片缩小后的大小，需注意的是 toFitSize 的比例跟 imageScaledSize 的比例不一定一致。
        CGSize imageScaledSize = CGSizeMake(imageOriginalSize.width * imageZoomScale, imageOriginalSize.height * imageZoomScale);

        BOOL drawsAlphaChannel = (options & WHLImageCroppingOptionAlphaChannel);

        // Always use a device RGB color space for simplicity and predictability what will be going on.
        CGColorSpaceRef colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB();
        // Early return on failure!
        if (!colorSpaceDeviceRGBRef) {
            NSLog(@"Failed to `CGColorSpaceCreateDeviceRGB` for image %@", self);
            return self;
        }

        // Even when the image doesn't have transparency, we have to add the extra channel because Quartz doesn't support other pixel formats than 32 bpp/8 bpc for RGB:
        // kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst, kCGImageAlphaPremultipliedLast
        // (source: docs "Quartz 2D Programming Guide > Graphics Contexts > Table 2-1 Pixel formats supported for bitmap graphics contexts")
        size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpaceDeviceRGBRef) + 1; // 4: RGB + A

        // "In iOS 4.0 and later, and OS X v10.6 and later, you can pass NULL if you want Quartz to allocate memory for the bitmap." (source: docs)
        void *data = NULL;
        size_t bitmapWidth = toFitSize.width * pixelScale;
        size_t bitmapHeight = toFitSize.height * pixelScale;
        size_t bitsPerComponent = CHAR_BIT;

        size_t bitsPerPixel = (bitsPerComponent * numberOfComponents);
        size_t bytesPerPixel = (bitsPerPixel / BYTE_SIZE);
        size_t bytesPerRow = WHLByteAlignForCoreAnimation(bytesPerPixel * bitmapWidth);

        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;

        if (drawsAlphaChannel) {
            CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
            // If the alpha info doesn't match to one of the supported formats (see above), pick a reasonable supported one.
            // "For bitmaps created in iOS 3.2 and later, the drawing environment uses the premultiplied ARGB format to store the bitmap data." (source: docs)
            if (alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaOnly) {
                alphaInfo = kCGImageAlphaNoneSkipFirst;
            } else if (alphaInfo == kCGImageAlphaFirst) {
                alphaInfo = kCGImageAlphaPremultipliedFirst;
            } else if (alphaInfo == kCGImageAlphaLast) {
                alphaInfo = kCGImageAlphaPremultipliedLast;
            }
            // "The constants for specifying the alpha channel information are declared with the `CGImageAlphaInfo` type but can be passed to this parameter safely." (source: docs)
            bitmapInfo |= alphaInfo;
        } else {
            bitmapInfo |= kCGImageAlphaNoneSkipFirst;
        }

        // Create our own graphics context to draw to; `UIGraphicsGetCurrentContext`/`UIGraphicsBeginImageContextWithOptions` doesn't create a new context but returns the current one which isn't thread-safe (e.g. main thread could use it at the same time).
        // Note: It's not worth caching the bitmap context for multiple frames ("unique key" would be `width`, `height` and `hasAlpha`), it's ~50% slower. Time spent in libRIP's `CGSBlendBGRA8888toARGB8888` suddenly shoots up -- not sure why.
        CGContextRef bitmapContextRef = CGBitmapContextCreate(data, bitmapWidth, bitmapHeight, bitsPerComponent, bytesPerRow, colorSpaceDeviceRGBRef, bitmapInfo);
        CGColorSpaceRelease(colorSpaceDeviceRGBRef);
        // Early return on failure!
        if (!bitmapContextRef) {
            NSLog(@"Failed to `CGBitmapContextCreate` with color space %@ and parameters (width: %zu height: %zu bitsPerComponent: %zu bytesPerRow: %zu) for image %@", colorSpaceDeviceRGBRef, bitmapWidth, bitmapHeight, bitsPerComponent, bytesPerRow, self);
            return self;
        }

        if (!bitmapContextRef) {
            return self;
        }

        CGPoint anchorPoint = CGPointZero;
        CGRect faceFrame = CGRectZero;
        BOOL detectFaceSucceed = NO;
        NSInteger algorithm = options & WHLImageCroppingOptionAlgorithmMask;

        switch (algorithm) {
            case WHLImageCroppingOptionAlgorithmCenter:
                anchorPoint = CGPointMake(0.5, 0.5);
                break;

            case WHLImageCroppingOptionAlgorithmTop:
                anchorPoint = CGPointMake(0.5, 0);
                break;

            case WHLImageCroppingOptionAlgorithmPortrait:
                if (imageOriginalSize.height > imageOriginalSize.width) {
                    anchorPoint = CGPointMake(0.5, 0.25);
                } else {
                    anchorPoint = CGPointMake(0.5, 0.5);
                }
                break;

            case WHLImageCroppingOptionAlgorithmDetectFace: {
                if (imageOriginalSize.height <= imageOriginalSize.width) {
                    anchorPoint = CGPointMake(0.5, 0.5);
                    break;
                }

                detectFaceSucceed = WHLGetFaceInfoForImage(self, imageZoomScale, &faceFrame);
                if (detectFaceSucceed) {
                    anchorPoint = WHLRectGetCenter(faceFrame);
                } else {
                    if (imageOriginalSize.height > imageOriginalSize.width) {
                        anchorPoint = CGPointMake(0.5, 0.25);
                    } else {
                        anchorPoint = CGPointMake(0.5, 0.5);
                    }
                }
                break;
            }

            default:
                break;
        }

        // 按pixelScale缩放
        CGContextScaleCTM(bitmapContextRef, pixelScale, pixelScale);
        // 返回的imageRectInContext也是左上角坐标系
        CGRect imageRectInContext = WHLCalculateDrawingRectWithCenterAndSize(anchorPoint, imageScaledSize, toFitSize, YES);
        // 把图片塞进rect里面，rect的size必须跟图片的比例一致，否则会变形。rect 采用的是 context 的坐标系。意思是在 context 的 rect 位置塞一张图。
        // 注意，这里用的是左上角坐标系
        CGContextDrawImage(bitmapContextRef, imageRectInContext, self.CGImage);

#ifdef DEBUG_TOOL
        // 显示人脸边框，只在测试的时候开启。
        if (detectFaceSucceed && WHLImageDisplaysFaceFrame) {
            CGContextSaveGState(bitmapContextRef);
            // 要转成左上角坐标系，因为imageRectInContext也是左上角坐标系的。
            CGRect flippedFaceFrame = WHLRectHorizontalFlip(faceFrame, 1);
            // 根据flippedFaceFrame来生成新的frame
            CGRect flippedFaceFrameInContext;
            flippedFaceFrameInContext.origin.x = imageRectInContext.origin.x + flippedFaceFrame.origin.x * imageRectInContext.size.width;
            flippedFaceFrameInContext.origin.y = imageRectInContext.origin.y + flippedFaceFrame.origin.y * imageRectInContext.size.height;
            flippedFaceFrameInContext.size.width = flippedFaceFrame.size.width * imageRectInContext.size.width;
            flippedFaceFrameInContext.size.height = flippedFaceFrame.size.height * imageRectInContext.size.height;
            CGContextSetStrokeColorWithColor(bitmapContextRef, [UIColor redColor].CGColor);
            CGContextStrokeRect(bitmapContextRef, flippedFaceFrameInContext);
            CGContextRestoreGState(bitmapContextRef);
        }
#endif

        if ((options & WHLImageCroppingOptionAddCroppingShadow) && imageScaledSize.height > toFitSize.height) {
            CGContextSaveGState(bitmapContextRef);
            CGFloat components[] = {
                1, 1, 1, 0.0f,
                0, 0, 0, 0.15f,
            };
            CGFloat locations[] = {
                0.0f,
                1.0f,
            };
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
            CGPoint startPoint = CGPointMake(0, toFitSize.height - 15);
            CGPoint endPoint = CGPointMake(0, toFitSize.height);
            CGContextDrawLinearGradient(bitmapContextRef, gradient, startPoint, endPoint, 0);
            CGColorSpaceRelease(colorSpace);
            CGGradientRelease(gradient);
            CGContextRestoreGState(bitmapContextRef);
        }

        CGImageRef newImageRef = CGBitmapContextCreateImage(bitmapContextRef);

        CGContextRelease(bitmapContextRef);

        UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:pixelScale orientation:UIImageOrientationUp];

        CGImageRelease(newImageRef);

        return newImage;
    }
}

- (UIImage *)whl_imageThatScaleAndCropToFitSizeForNewsPicture:(CGSize)size
{
    return [self whl_imageThatScaleAndCropToFitSize:size
                                            options:WHLImageCroppingOptionAlgorithmDetectFace];
}

- (UIImage *)whl_imageThatScaleAndCropToFitSizeForAlbumPicture:(CGSize)size
{
    return [self whl_imageThatScaleAndCropToFitSize:size
                                            options:WHLImageCroppingOptionAlgorithmPortrait];
}

- (UIImage *)whl_imageThatScaleAndCropToFitSizeForEpisode:(CGSize)size
{
    return [self whl_imageThatScaleAndCropToFitSize:size
                                            options:WHLImageCroppingOptionAddCroppingShadow | WHLImageCroppingOptionAlgorithmTop];
}

- (UIImage *)whl_imageThatScaleAndCropToFitSize:(CGSize)size
{
    return [self whl_imageThatScaleAndCropToFitSize:size
                                            options:WHLImageCroppingOptionAlgorithmCenter];
}

- (UIImage *)whl_imageThatScaleAndCropToFitSize:(CGSize)size alphaChannel:(BOOL)alphaChannel
{
    if (!alphaChannel) {
        return [self whl_imageThatScaleAndCropToFitSize:size];
    } else {
        return [self whl_imageThatScaleAndCropToFitSize:size
                                                options:WHLImageCroppingOptionAlgorithmCenter | WHLImageCroppingOptionAlphaChannel];
    }
}

- (UIImage *)whl_imageStretchToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)whl_imageThatCutAndRelocateCenter:(UIImage *)sourceImage xCenter:(float)xCenter yCenter:(float)yCenter targetSize:(CGSize)targetSize
{
    CGSize sourceImgSize = sourceImage.size;
    if (targetSize.width > sourceImgSize.width || targetSize.height > sourceImgSize.height) {
        sourceImgSize = CGSizeMake(sourceImgSize.width / 2, sourceImgSize.height / 2);
        CGSize targetSizeTmp = CGSizeMake(targetSize.width / 2, targetSize.height / 2);

        float xChange = (0.5 - xCenter) * sourceImgSize.width;
        float yChange = (0.5 - yCenter) * sourceImgSize.height;
        xChange = xChange + (targetSizeTmp.width - sourceImgSize.width) / 2;
        yChange = yChange + (targetSizeTmp.height - sourceImgSize.height) / 2;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(targetSizeTmp.width, targetSizeTmp.height), NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (!context) {
            return nil;
        }
        CGContextTranslateCTM(context, 0, targetSizeTmp.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGRectMake(xChange, yChange, sourceImgSize.width, sourceImgSize.height), sourceImage.CGImage);
        CGContextSaveGState(context);
        CGContextRestoreGState(context);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        CGSize sourceSize = sourceImage.size;
        CGRect targetRect = CGRectMake((sourceSize.width - targetSize.width) / 2 + sourceSize.width * (xCenter - 0.5),
                                       (sourceSize.height - targetSize.height) / 2 + sourceSize.height * (yCenter - 0.5),
                                       targetSize.width, targetSize.height);
        CGImageRef subImageRef = CGImageCreateWithImageInRect(sourceImage.CGImage, targetRect);
        CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));

        UIGraphicsBeginImageContext(smallBounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, smallBounds, subImageRef);
        UIImage *targetImage = [UIImage imageWithCGImage:subImageRef];
        CGImageRelease(subImageRef);
        UIGraphicsEndImageContext();
        return targetImage;
    }
}

+ (UIImage *)whl_roundedImageFromImage:(UIImage *)srcImage diameter:(CGFloat)diameter
{
    if (!srcImage) {
        return nil;
    }

    CGFloat scale = diameter / MAX(srcImage.size.height, srcImage.size.width);
    CGRect clipRect = CGRectMake(0, 0, srcImage.size.width, srcImage.size.height);

    UIGraphicsBeginImageContextWithOptions(clipRect.size, NO, scale * [UIScreen mainScreen].scale);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    CGContextAddPath(context, [UIBezierPath bezierPathWithOvalInRect:clipRect].CGPath);
    CGContextClip(context);
    CGContextTranslateCTM(context, 0, clipRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, clipRect, srcImage.CGImage);
    CGContextRestoreGState(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

/** 交换宽和高 */
static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat swap = rect.size.width;

    rect.size.width = rect.size.height;
    rect.size.height = swap;

    return rect;
}

- (UIImage *)whl_rotate:(UIImageOrientation)orient
{
    CGRect bnds = CGRectZero;
    UIImage *copy = nil;
    CGContextRef ctxt = nil;
    CGImageRef imag = self.CGImage;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;

    rect.size.width = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);

    bnds = rect;

    switch (orient) {
        case UIImageOrientationUp:
            return self;

        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;

        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;

        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;

        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;

        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;

        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;

        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;

        default:
            return self;
    }

    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();

    switch (orient) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;

        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }

    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);

    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return copy;
}

+ (void)whl_setFaceDetectionDisabled:(BOOL)faceDetectionDisabled
{
    WHLImageFaceDetectionDisabled = faceDetectionDisabled;
}

+ (BOOL)whl_faceDetectionDisabled
{
    return WHLImageFaceDetectionDisabled;
}

+ (void)whl_setDisplaysFaceFrame:(BOOL)displayFacesFrame
{
    WHLImageDisplaysFaceFrame = displayFacesFrame;
}

+ (BOOL)whl_displaysFaceFrame
{
    return WHLImageDisplaysFaceFrame;
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor
{
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *)imageWithGradientTintColor:(UIColor *)tintColor
{
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);

    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];

    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

@end

CGRect WHLCalculateDrawingRectWithCenterAndSize(CGPoint destinationCenter, CGSize destinationSize, CGSize canvasSize, BOOL fillCanvas)
{
    CGFloat boundsRelativeX = destinationSize.width * destinationCenter.x - 0.5 * canvasSize.width;
    CGFloat boundsRelativeY = destinationSize.height * destinationCenter.y - 0.5 * canvasSize.height;

    if (fillCanvas) {
        // validate
        boundsRelativeX = MAX(0, MIN(destinationSize.width - canvasSize.width, boundsRelativeX));
        boundsRelativeY = MAX(0, MIN(destinationSize.height - canvasSize.height, boundsRelativeY));
    }

    CGRect contextRelativeRect;
    contextRelativeRect.size = destinationSize;
    contextRelativeRect.origin.x = -boundsRelativeX;
    contextRelativeRect.origin.y = -boundsRelativeY;

    CGRect transformedRect = WHLRectHorizontalFlip(contextRelativeRect, canvasSize.height);

    return transformedRect;
}

BOOL WHLGetFaceInfoForImage(UIImage *image, CGFloat scale, CGRect *outFrame)
{
    WHLAssert(![NSThread isMainThread], @"不能在主线程运行人脸识别");

    if (WHLImageFaceDetectionDisabled) {
        return NO;
    }

    if (!outFrame) {
        return NO;
    }

    NSArray *features = [[WHLImageManager sharedImageManager] featuresInImage:image];

    if (!features || [features count] == 0) {
        return NO;
    }

    CGRect unionRect = CGRectZero;
    CGRect firstFaceRect = CGRectZero;
    NSUInteger i = 0;

    for (CIFeature *feat in features) {
        // CI给的bounds是左下角坐标系
        CGRect faceBounds = feat.bounds;
        if (i == 0) {
            unionRect = faceBounds;
            firstFaceRect = faceBounds;
        } else {
            unionRect = CGRectUnion(unionRect, faceBounds);
        }

        i++;
    }

    // 183是iPhone5的屏幕尺寸下，文章列表焦点图的最大高度。
    // 当人脸范围等比例缩放后，高度仍然大于183.f，我当它是一张
    // 长图，因为人脸的纵向跨度比较大，所以这里只对第一张脸。
    if (unionRect.size.height * scale > 183.f) {
        unionRect = firstFaceRect;
    }

    CGSize imageSize = image.size;

    CGRect transformedRect = WHLRectHorizontalFlip(unionRect, imageSize.height);

    CGRect frame;
    frame.origin.x = transformedRect.origin.x / imageSize.width;
    frame.origin.y = transformedRect.origin.y / imageSize.height;
    frame.size.width = transformedRect.size.width / imageSize.width;
    frame.size.height = transformedRect.size.height / imageSize.height;

    // frame也是左下角坐标系
    if (outFrame) {
        *outFrame = frame;
    }

    return YES;
}

BOOL WHLDataIsValidGIFData(NSData *imageData)
{
    if (![imageData isKindOfClass:[NSData class]]) {
        return NO;
    }

    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    if (imageSource == NULL) {
        return NO;
    }

    CFStringRef imageSourceContainerType = CGImageSourceGetType(imageSource);

    // 先看看是不是GIF的数据结构
    BOOL isValid = UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF);

    if (isValid) {
        // 还要看看帧数是否满足大于0
        isValid = CGImageSourceGetCount(imageSource) > 0;
    }

    CFRelease(imageSource);

    return isValid;
}
