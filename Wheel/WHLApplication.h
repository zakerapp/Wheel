//
//  WHLApplication.h
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHLApplication : NSObject

/**
 市场版本号
 
 @return 市场版本号
 */
+ (NSString *)version;

/**
 内部版本号
 
 @return 内部版本号
 */
+ (NSString *)buildVersion;

/**
 主屏幕的 bounds
 
 @return 主屏幕的 bounds
 */
+ (CGRect)applicationBounds;

/**
 主屏幕的 frame
 
 @return 主屏幕的 frame
 */
+ (CGRect)applicationFrame;

@end
