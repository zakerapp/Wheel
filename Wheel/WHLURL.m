//
//  WHLURL.m
//  Wheel
//
//  Created by Steven Mok on 14-8-19.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import "WHLURL.h"

@implementation NSURL (WHLURLAdditions)

- (NSURL *)whl_makeDirectory
{
    [self.path whl_makeDirectory];
    
    return self;
}

- (BOOL)whl_isFilePath
{
    if ([self.scheme isEqualToString:@"file"]) {
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation NSString (WHLURLAdditions)

- (NSString *)whl_makeDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:self]) {
        NSError *error = nil;
        [fm createDirectoryAtPath:self withIntermediateDirectories:YES attributes:nil error:&error];
    }

    return self;
}

@end
