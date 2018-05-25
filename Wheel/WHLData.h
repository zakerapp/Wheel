//
//  WHLData.h
//  Wheel
//
//  Created by 麦家豪 on 16/9/5.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (WHLAdditions)

/**
 获取 NSData 的 md5 加密字符串

 @return 加密结果
 */
- (NSString *)whl_md5String;

/**
 获取 NSData 对应的十六进制字符串表示

 @return 对应的十六进制字符串
 */
- (NSString *)whl_hexadecimalString;

/**
 用十六进制字符串生成对应的 NSData

 @return 返回十六进制字符串生成的对应的 NSData
 */
+ (NSData *)whl_dataFromHexadecimalString:(NSString *)hexString;

@end
