//
//  WHLError.m
//  Wheel
//
//  Created by Steven Mok on 14-6-29.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import "WHLError.h"

NSString *const WHLGenericException = @"WHLGenericException";

NSString *const WHLErrorDomain = @"WHLErrorDomain";

@implementation NSError (WHLAdditions)

+ (NSError *)whl_errorWithCode:(NSInteger)code reason:(NSString *)reason
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if (reason) {
        userInfo[NSLocalizedFailureReasonErrorKey] = reason;
        userInfo[NSLocalizedDescriptionKey] = reason;
    }
    return [NSError errorWithDomain:WHLErrorDomain code:code userInfo:userInfo];
}

@end
