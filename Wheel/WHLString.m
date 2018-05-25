//
//  WHLString.m
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLString.h"
#import "WHLAccessibility.h"
#import <CoreText/CoreText.h>

@implementation WHLStringMatchResult

@end

@implementation NSString (WHLAdditions)

- (CGSize)whl_sizeOfLastLineWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    if ([self length] == 0) {
        return CGSizeZero;
    }

    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [self length])];

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);

    CGMutablePathRef path = CGPathCreateMutable();
    CGRect textRect = CGRectZero;
    textRect.size = size;
    CGPathAddRect(path, NULL, textRect);

    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedString length]), path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);

    CGSize lineSize = CGSizeZero;
    if (numberOfLines > 0) {
        CTLineRef lastLine = CFArrayGetValueAtIndex(lines, numberOfLines - 1);
        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = CTLineGetTypographicBounds(lastLine, &ascent, &descent, &leading);
        lineSize = CGSizeMake(width, ascent + descent);
    }

    CFRelease(fontRef);
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(framesetter);

    return lineSize;
}

- (NSUInteger)whl_sinaWeiboWordCount
{
    NSUInteger i, n = [self length], l = 0, a = 0, b = 0;

    unichar c;

    for (i = 0; i < n; i++) {
        c = [self characterAtIndex:i];

        if (isblank(c)) {
            b++;
        } else if (isascii(c)) {
            a++;
        } else {
            l++;
        }
    }

    if (a == 0 && l == 0) {
        return 0;
    }

    return (NSUInteger)l + (NSUInteger)ceilf((float)(a + b) / 2.0);
}

- (NSUInteger)whl_locationInSinaWeiboWordCount:(NSUInteger)targetCount
{
    NSUInteger i, n = [self length], l = 0, a = 0, b = 0;

    unichar c;

    for (i = 0; i < n; i++) {
        c = [self characterAtIndex:i];

        if (isblank(c)) {
            b++;
        } else if (isascii(c)) {
            a++;
        } else {
            l++;
        }

        NSUInteger count = (NSUInteger)l + (NSUInteger)ceilf((float)(a + b) / 2.0);
        if (count == targetCount) {
            return i;
        }
    }

    return n;
}

- (BOOL)whl_isIPAddress
{
    if (self.length > 0) {
        NSString *regexPattern = @"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
        if (match && match.range.location != NSNotFound) { // 主机不是ip地址才加重定向
            return YES;
        }
    }

    return NO;
}

- (NSString *)whl_findString:(NSString *)searchString options:(NSStringCompareOptions)mask
{
    NSRange range = [self rangeOfString:searchString options:mask];
    if (range.location != NSNotFound) {
        return [self substringWithRange:range];
    }
    return nil;
}

- (WHLStringMatchResult *)whl_findHost
{
    if (self.length > 0) {
        NSString *regexPattern = @"^(?:(?:[A-Za-z](?:[A-Za-z0-9+-\\\\.]*))\\/\\/)?(?:.+@)?([a-zA-Z0-9\\.\\-]+)";
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
        if (match && [match numberOfRanges] > 1) {
            NSRange matchRange = [match rangeAtIndex:1];
            WHLStringMatchResult *result = [WHLStringMatchResult new];
            result.range = matchRange;
            result.string = [self substringWithRange:matchRange];
            return result;
        }
    }

    return nil;
}

- (NSString *)whl_findRootDomain
{
    WHLStringMatchResult *hostResult = [self whl_findHost];
    if (hostResult) {
        if ([hostResult.string whl_isIPAddress]) {
            // IP必须整个匹配
            return hostResult.string;
        }

        NSString *last2Part = [self whl_findString:@"\\w+\\.\\w+$" options:NSRegularExpressionSearch];
        if ([@[@"com.cn", @"com.hk", @"gov.cn", @"net.cn", @"org.cn"] containsObject: last2Part]) {
            // 最后2个段不能是这几个域名
            // 如果是的话，要匹配到第三个
            NSString *last3Part = [self whl_findString:@"\\w+\\.\\w+\\.\\w+$" options:NSRegularExpressionSearch];
            if (last3Part) {
                return last3Part;
            }
        } else {
            return last2Part;
        }
    }

    return nil;
}

- (NSString *)whl_URLStringByRedirectingToHost:(NSString *)newHost
{
    if (!(newHost.length > 0)) {
        return self;
    }

    WHLStringMatchResult *hostMathResult = [self whl_findHost];
    NSString *oldHost = hostMathResult.string;
    // 当前主机不是ip地址才加重定向，前后主机地址一样就不加重定向
    if (oldHost && ![oldHost whl_isIPAddress] && ![oldHost isEqualToString:newHost]) {
        NSString *replacement = [NSString stringWithFormat:@"%@/%@", newHost, oldHost];
        NSString *newURL = [self stringByReplacingCharactersInRange:hostMathResult.range withString:replacement];
        WHLStringMatchResult *schemeMatch = [newURL whl_findURLScheme];
        if (schemeMatch && [schemeMatch.string isEqualToString:@"https"]) {
            // 重定向到IP地址时，需要去掉https，因为IP主机不支持https
            newURL = [newURL stringByReplacingCharactersInRange:schemeMatch.range withString:@"http"];
        }
        return newURL;
    }

    return self;
}

- (WHLStringMatchResult *)whl_findURLScheme
{
    if (self.length > 0) {
        /*
         According to RFC 2396, Appendix A:

         scheme = alpha *( alpha | digit | "+" | "-" | "." )
         */
        NSString *regexPattern = @"^([A-Za-z](?:[A-Za-z0-9+-\\.]*)):";
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
        if (match && [match numberOfRanges] > 1) {
            NSRange matchRange = [match rangeAtIndex:1];
            WHLStringMatchResult *result = [WHLStringMatchResult new];
            result.range = matchRange;
            result.string = [self substringWithRange:matchRange];
            return result;
        }
    }
    return nil;
}

- (NSString *)whl_URLStringByReplacingSchemeWithScheme:(NSString *)scheme
{
    if (!(scheme.length > 0)) {
        return self;
    }
    WHLStringMatchResult *schemeMatchResult = [self whl_findURLScheme];
    if (schemeMatchResult) {
        return [self stringByReplacingCharactersInRange:schemeMatchResult.range withString:scheme];
    } else {
        // 找不到scheme就在前面插入新的scheme
        return [NSString stringWithFormat:@"%@://%@", scheme, self];
    }
    return self;
}

- (NSString *)whl_stringByRemovingBothEndsCharacter
{
    NSUInteger length = self.length;
    if (length > 2) {
        return [self substringWithRange:NSMakeRange(1, length - 2)];
    } else {
        return @"";
    }
}

- (NSString *)whl_stringByRemovingPrefix:(NSString *)prefix
{
    if (!prefix) {
        return self;
    }

    NSRange range = [self rangeOfString:prefix options:NSAnchoredSearch];

    if (range.location != NSNotFound) {
        return [self substringFromIndex:range.location + range.length];
    }

    return self;
}

- (NSString *)whl_stringByRemovingSuffix:(NSString *)suffix
{
    if (!suffix) {
        return self;
    }

    NSRange range = [self rangeOfString:suffix options:NSAnchoredSearch | NSBackwardsSearch];

    if (range.location != NSNotFound) {
        return [self substringToIndex:range.location];
    }

    return self;
}

- (NSString *)whl_substringWithRange:(NSRange)range
{
    if (range.location == NSNotFound) {
        return nil;
    }
    if (range.location + range.length <= self.length) {
        return [self substringWithRange:range];
    }
    return nil;
}

- (NSUInteger)whl_numberOfLines
{
    NSUInteger length = [self length];
    NSUInteger numberOfLines = 0;
    for (NSUInteger index = 0; index < length; numberOfLines++) {
        index = NSMaxRange([self lineRangeForRange:NSMakeRange(index, 0)]);
    }
    return numberOfLines;
}

@end

@implementation NSMutableString (WHLAdditions)

- (NSUInteger)whl_replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
{
    if (!target) {
        return 0;
    }

    if (!replacement) {
        replacement = @"";
    }

    return [self replaceOccurrencesOfString:target withString:replacement options:options range:searchRange];
}

@end
