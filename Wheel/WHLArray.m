//
//  WHLArray.m
//  Wheel
//
//  Created by chars on 16/9/5.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import "WHLArray.h"

@implementation NSArray (WHLAdditions)

- (id)whl_objectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end

@implementation NSMutableArray (WHLAdditions)

- (void)whl_addObject:(id)object
{
    if (!object) {
        return;
    }

    [self addObject:object];
}

+ (NSMutableArray *)whl_randomizedArrayWithArray:(NSMutableArray *)array
{
    NSMutableArray *results = [[NSMutableArray alloc]initWithArray:array];
    
    NSUInteger i = [results count];
    
    while (--i > 0) {
        int j = rand() % (i + 1);
        
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    return results;
}

@end
