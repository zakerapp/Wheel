//
//  WHLArray.h
//  Wheel
//
//  Created by chars on 16/9/5.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (WHLAdditions)

/**
 安全的获取数组指定下标的值

 @param index 指定下标
 @return 数组在 index 下标的值(若下标超出数组大小则返回 nil)
 */
- (id)whl_objectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray (WHLAdditions)

/**
 安全的向数组中添加元素，元素值为 nil 则不添加

 @param object 指定下标
 */
- (void)whl_addObject:(id)object;

+ (NSMutableArray *)whl_randomizedArrayWithArray:(NSMutableArray *)array;

@end
