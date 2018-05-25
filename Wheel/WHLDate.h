//
//  WHLDate.h
//  Wheel
//
//  Created by Steven Mok on 14-1-27.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>

enum { WHLDateDistantPast = NSIntegerMax };

@interface WHLDate : NSObject

+ (NSDate *)dateFromDayString:(NSString *)dayString timeString:(NSString *)timeString;

+ (NSString *)smartDescriptionWithDayString:(NSString *)dayString timeString:(NSString *)timeString maxRelativePastDays:(NSUInteger)maxRelativePastDays;

@end

@interface NSDate (WHLAdditions)

- (BOOL)whl_inSameYearAsDate:(NSDate *)date;

- (BOOL)whl_inSameDayAsDate:(NSDate *)date;

- (NSString *)whl_smartDescriptionWithMaxRelativePastDays:(NSUInteger)maxRelativePastDays;

- (NSString *)whl_smartDescriptionWithMaxRelativePastDays:(NSUInteger)maxRelativePastDays isDayMonthLevel:(BOOL)isDayMonthLevel;

/**
 判断时间是否过期
 
 @param startingTime 过期判定条件中的起始时间
 @param duration 过期判定中的时限长度
 @return BOOL
 */
- (BOOL)whl_isOverdueWithStartingTime:(NSDate *)startingTime duration:(NSTimeInterval)duration;

/**
 判断时间是否过期(time和startingTime时间戳起始点需相同)

 @param time 需做判定的时间
 @param startingTime 过期判定条件中的起始时间
 @param duration 过期判定中的时限长度
 @return BOOL
 */
+ (BOOL)whl_isTime:(NSTimeInterval)time laterThan:(NSTimeInterval)startingTime duration:(NSTimeInterval)duration;

@end

@interface WHLDateManager : NSObject

+ (WHLDateManager *)sharedManager;

- (NSDate *)dayAsDateFromString:(NSString *)string;
- (NSDate *)minuteAsDateFromString:(NSString *)string;
- (NSDate *)secondAsDateFromString:(NSString *)string;

- (NSString *)dayAsStringFromDate:(NSDate *)date;
- (NSString *)minuteAsStringFromDate:(NSDate *)date;
- (NSString *)secondAsStringFromDate:(NSDate *)date;

@end
