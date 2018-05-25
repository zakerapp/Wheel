//
//  WHLData.m
//  Wheel
//
//  Created by 麦家豪 on 16/9/5.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import "WHLData.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (WHLAdditions)

- (NSString *)whl_md5String;
{
    const char *cStr = (const char *)[self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (uint32_t)[self length], result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

- (NSString *)whl_hexadecimalString
{
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */

    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];

    if (!dataBuffer) return [NSString string];

    NSUInteger dataLength  = [self length];
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }

    return [NSString stringWithString:hexString];
}

+ (NSData *)whl_dataFromHexadecimalString:(NSString *)hexString
{
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *data = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = { '\0', '\0', '\0' };
    NSUInteger length = hexString.length / 2;
    for (NSUInteger i = 0; i < length; i++) {
        byte_chars[0] = [hexString characterAtIndex:i << 1];
        byte_chars[1] = [hexString characterAtIndex:(i << 1) + 1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

@end
