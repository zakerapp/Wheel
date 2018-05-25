//
//  WHLInvocation.h
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (WHLAdditions)

+ (NSInvocation *)whl_invocationWithTarget:(id)target selector:(SEL)selector arguments:(void *)firstArg, ...;

@end
