//
//  WHLDictionary.m
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLDictionary.h"

@implementation NSDictionary (WHLAccessibility)

- (id)whl_objectForKey:(id)aKey
{
    if (aKey) {
        return [self objectForKey:aKey];
    }
    return nil;
}

- (instancetype)whl_dictionaryForKeys:(NSArray *)keys
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in keys) {
        [result whl_setObject:[self objectForKey:key] forKey:key];
    }
    
    if (result.count) {
        return [[self.class alloc] initWithDictionary:result];
    } else {
        return nil;
    }
}

@end

@implementation NSMutableDictionary (WHLAdditions)

- (void)whl_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

- (BOOL)whl_setValue:(id)value forKeyPath:(NSString *)keyPath
{
    if (!(keyPath.length > 0)) {
        return NO;
    }

    NSArray *keyPathAsArray = [keyPath componentsSeparatedByString:@"."];

    return [self whl_setObject:value forKeyPaths:keyPathAsArray];
}

- (BOOL)whl_setObject:(id)object forKeyPaths:(NSArray *)keyPaths
{
    if ([keyPaths isKindOfClass:[NSArray class]]) {
        return NO;
    }

    NSUInteger count = [keyPaths count];
    if (count < 1) {
        return NO;
    }

    NSArray *remainderKeyPath = nil;
    id key = keyPaths[0];
    if (count > 1) {
        remainderKeyPath = [keyPaths subarrayWithRange:NSMakeRange(1, count - 1)];
    }

    if ([remainderKeyPath count]) {
        id existObject = [self objectForKey:key];

        if (!existObject) {
            NSMutableDictionary *mDictionary = [[NSMutableDictionary alloc] init];
            [self setObject:mDictionary forKey:key];

            return [mDictionary whl_setObject:object forKeyPaths:remainderKeyPath];
        } else if ([existObject isKindOfClass:[NSMutableDictionary class]]) {
            return
                [(NSMutableDictionary *)existObject whl_setObject:object
                                                       forKeyPaths:remainderKeyPath];
        } else if ([existObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mDictionary = [[NSMutableDictionary alloc]
                                                initWithDictionary:(NSDictionary *)existObject];
            [self setObject:mDictionary forKey:key];
            return [mDictionary whl_setObject:object forKeyPaths:remainderKeyPath];
        } else {
            return NO;
        }
    } else {
        [self setObject:object forKey:key];
        return YES;
    }
}

@end
