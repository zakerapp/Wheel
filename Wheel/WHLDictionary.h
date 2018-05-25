//
//  WHLDictionary.h
//  Wheel
//
//  Created by Steven Mok on 13-10-11.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (WHLAccessibility)

/**
 安全的获取字典指定键对应值
 
 @param aKey 键
 @return 字典指定键对应的值(若键为 nil，则直接返回 nil)
 */
- (id)whl_objectForKey:(id)aKey;

/**
 用指定的数组创建字典
 
 @param keys 指定数组
 @return 创建的字典
 */
- (instancetype)whl_dictionaryForKeys:(NSArray<id<NSCopying> > *)keys;

@end

@interface NSMutableDictionary (WHLAdditions)

/**
 安全的设置可变字典里的键值，键和值必须同时不为空，否则设置失败
 
 @param anObject 值
 @param aKey 键
 */
- (void)whl_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

/**
 通过 keyPath 设置字典的键值
 
 @param value 值
 @param keyPath 需要设置值的 keyPath
 @return 设置是否成功
 */
- (BOOL)whl_setValue:(id)value forKeyPath:(NSString *)keyPath;

/**
 通过 keyPaths 设置字典的多个键值
 
 @param object 值
 @param keyPaths 多个需要设置值的 keyPath 数组
 @return 设置是否成功
 */
- (BOOL)whl_setObject:(id)object forKeyPaths:(NSArray *)keyPaths;

@end

