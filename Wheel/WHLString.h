//
//  WHLString.h
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHLDefines.h"
#import "WHLNetwork.h"

#define WHLPureDescription()                         [[super description] whl_stringByRemovingBothEndsCharacter]

#define WHLDescriptionByAppendingString(str)         [NSString stringWithFormat : @"<%@; %@>", WHLPureDescription(), str]

#define WHLDescriptionByAppendingFormat(format, ...) [NSString stringWithFormat : @"<%@; " format ">", WHLPureDescription(), __VA_ARGS__]

WHL_INLINE NSString * WHLIntegerToString(NSInteger num)
{
    return [NSString stringWithFormat:@"%td", num];
}

@interface WHLStringMatchResult : NSObject

@property (nonatomic, assign) NSRange range;

@property (nonatomic, strong) NSString *string;

@end

@interface NSString (WHLAdditions)

- (CGSize)whl_sizeOfLastLineWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (NSUInteger)whl_sinaWeiboWordCount;

- (NSUInteger)whl_locationInSinaWeiboWordCount:(NSUInteger)targetCount;

- (NSString *)whl_URLStringByRedirectingToHost:(NSString *)host;

- (BOOL)whl_isIPAddress;

- (NSString *)whl_findString:(NSString *)searchString options:(NSStringCompareOptions)mask;

- (WHLStringMatchResult *)whl_findHost;

- (NSString *)whl_findRootDomain;

- (WHLStringMatchResult *)whl_findURLScheme;

/**
 移除两端的符号，例如 <hi> 变成 hi

 @returns 移除后的字符串
 */
- (NSString *)whl_stringByRemovingBothEndsCharacter;

- (NSString *)whl_stringByRemovingPrefix:(NSString *)prefix;

- (NSString *)whl_stringByRemovingSuffix:(NSString *)suffix;

- (NSUInteger)whl_numberOfLines;

- (NSString *)whl_substringWithRange:(NSRange)range;

@end

@interface NSMutableString (WHLAdditions)

- (NSUInteger)whl_replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;

@end
