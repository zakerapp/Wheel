//
//  WHLError.h
//  Wheel
//
//  Created by Steven Mok on 14-6-29.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const WHLGenericException;

extern NSString *const WHLErrorDomain;

#ifdef DEBUG

static inline void _WHLThrowException(NSString *desc)
{
    @throw [NSException exceptionWithName:WHLGenericException reason:desc userInfo:nil];
}

static inline void WHLException(NSString *desc)
{
    _WHLThrowException(desc);
}

static inline void WHLAssert(BOOL condition, NSString *desc)
{
    if (!condition) {
        _WHLThrowException(desc);
    }
}

#else
    #define WHLException(...)
    #define WHLAssert(...)
#endif

@interface NSError (WHLAdditions)

+ (NSError *)whl_errorWithCode:(NSInteger)code reason:(NSString *)reason;

@end
