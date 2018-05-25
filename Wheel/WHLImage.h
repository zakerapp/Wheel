//
//  WHLImage.h
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLDefines.h"
#import "WHLGeometry.h"

/**
 计算图片的人脸信息

 @param image 检测的图片
 @param scale 图片即将要缩放到的比例，用于计算业务需求（将来可能去掉这个参数）
 @param outFrame 输出的框架指针，各项取值范围为0~1。左下角坐标系
 @returns 是否检测到人脸
 */
WHL_EXTERN BOOL WHLGetFaceInfoForImage(UIImage *image, CGFloat scale, CGRect *outFrame);

/**
 自动生成正确的画图的Rect

 @param destinationSize 要画的东西本来的大小
 @param destinationCenter 定位的中心点，各项取值范围为0~1。左下角坐标系
 @param canvasSize 画布的大小
 @returns 大小为destinationSize，定位在画布的destinationCenter点的新rect。左上角坐标系
 */
WHL_EXTERN CGRect WHLCalculateDrawingRectWithCenterAndSize(CGPoint destinationCenter, CGSize destinationSize, CGSize canvasSize, BOOL fillCanvas);

/**
 判断data是否为gif图像
 */
WHL_EXTERN BOOL WHLDataIsValidGIFData(NSData *imageData);

@interface UIImage (WHLAdditions)

+ (UIImage *)whl_imageNamed:(NSString *)name;

+ (UIImage *)whl_imageNamed:(NSString *)name tintColor:(UIColor *)tintColor;

+ (UIImage *)whl_imageWithColor:(UIColor *)color opaque:(BOOL)opaque;

- (UIImage *)whl_imageByCroppingToRect:(CGRect)rect opaque:(BOOL)opaque;

- (UIImage *)whl_imageByCroppingToRect:(CGRect)rect tintColor:(UIColor *)tintColor opaque:(BOOL)opaque;

// This method only reduce the size if possible, if the original size
// is smaller than the input size (both width and height), would return
// a new image with original size.
- (UIImage *)whl_imageThatZoomOutToFitSize:(CGSize)size;

- (UIImage *)whl_imageThatScaleAndCropToFitSize:(CGSize)size;

- (UIImage *)whl_imageThatScaleAndCropToFitSize:(CGSize)size alphaChannel:(BOOL)alphaChannel;

- (UIImage *)whl_imageThatScaleAndCropToFitSizeForNewsPicture:(CGSize)size;

- (UIImage *)whl_imageThatScaleAndCropToFitSizeForAlbumPicture:(CGSize)size;

- (UIImage *)whl_imageThatScaleAndCropToFitSizeForEpisode:(CGSize)size;

/**
 旋转图片

 @param orient 旋转角度
 @return 旋转后的图片
 */
- (UIImage*)whl_rotate:(UIImageOrientation)orient;

- (UIImage*)whl_imageStretchToSize:(CGSize)size;

/**
 *  将图片剪裁并重新定位居中点
 *
 *  @param sourceImage 源图片
 *  @param xCenter     x轴中心点（例：0.5）
 *  @param yCenter     y轴中心点（例：0.4）
 *  @param targetSize  目标size
 *
 *  @return 剪裁后图片
 */
+ (UIImage *)whl_imageThatCutAndRelocateCenter:(UIImage *)sourceImage xCenter:(float)xCenter yCenter:(float)yCenter targetSize:(CGSize)targetSize;


+ (UIImage *)whl_roundedImageFromImage:(UIImage *)srcImage diameter:(CGFloat)diameter;


#pragma mark For Debug

+ (void)whl_setDisplaysFaceFrame:(BOOL)displayFacesFrame;

+ (BOOL)whl_displaysFaceFrame;

+ (void)whl_setFaceDetectionDisabled:(BOOL)faceDetectionDisabled;

+ (BOOL)whl_faceDetectionDisabled;

@end
