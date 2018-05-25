//
//  WHLDate.m
//  Wheel
//
//  Created by Steven Mok on 14-1-27.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import "WHLDate.h"

#define M_MINUTE 60.f
#define M_HOUR   (M_MINUTE * 60.f)
#define M_DAY    (M_HOUR * 24.f)

@interface WHLDateManager ()

@property (nonatomic) NSDateFormatter *secondLevelDateFormater;
@property (nonatomic) NSDateFormatter *minuteLevelDateFormater;
@property (nonatomic) NSDateFormatter *dayLevelDateFormater;
@property (nonatomic) NSDateFormatter *dayMonthLevelDateFormater;

@property (nonatomic) NSRecursiveLock *secondLevelDateFormaterLock;
@property (nonatomic) NSRecursiveLock *minuteLevelDateFormaterLock;
@property (nonatomic) NSRecursiveLock *dayLevelDateFormaterLock;
@property (nonatomic) NSRecursiveLock *dayMonthLevelDateFormaterLock;

@end

@implementation WHLDateManager

+ (WHLDateManager *)sharedManager
{
    static WHLDateManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager =  [[WHLDateManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _secondLevelDateFormater =  [[NSDateFormatter alloc] init];
        [_secondLevelDateFormater setDateFormat:@"yyyy-M-d H:m:s"];
        
        _minuteLevelDateFormater = [[NSDateFormatter alloc] init];
        [_minuteLevelDateFormater setDateFormat:@"yyyy-M-d H:m"];
        
        _dayLevelDateFormater = [[NSDateFormatter alloc] init];
        [_dayLevelDateFormater setLocale:[NSLocale currentLocale]];
        [_dayLevelDateFormater setDateFormat:@"yyyy-M-d"];
        
        _dayMonthLevelDateFormater = [[NSDateFormatter alloc] init];
        [_dayMonthLevelDateFormater setLocale:[NSLocale currentLocale]];
        [_dayMonthLevelDateFormater setDateFormat:@"M-d"];
        
        _secondLevelDateFormaterLock = [[NSRecursiveLock alloc] init];
        _minuteLevelDateFormaterLock = [[NSRecursiveLock alloc] init];
        _dayLevelDateFormaterLock = [[NSRecursiveLock alloc] init];
        _dayMonthLevelDateFormaterLock = [[NSRecursiveLock alloc] init];
    }
    
    return self;
}

- (NSDate *)dayAsDateFromString:(NSString *)string
{
    [self.dayLevelDateFormaterLock lock];
    NSDate *final = [self.dayLevelDateFormater dateFromString:string];
    [self.dayLevelDateFormaterLock unlock];
    
    return final;
}

- (NSDate *)minuteAsDateFromString:(NSString *)string
{
    [self.minuteLevelDateFormaterLock lock];
    NSDate *final = [self.minuteLevelDateFormater dateFromString:string];
    [self.minuteLevelDateFormaterLock unlock];
    
    return final;
}

- (NSDate *)secondAsDateFromString:(NSString *)string
{
    [self.secondLevelDateFormaterLock lock];
    NSDate *final = [self.secondLevelDateFormater dateFromString:string];
    [self.secondLevelDateFormaterLock unlock];
    
    return final;
}

- (NSString *)dayAsStringFromDate:(NSDate *)date
{
    [self.dayLevelDateFormaterLock lock];
    NSString *final = [self.dayLevelDateFormater stringFromDate:date];
    [self.dayLevelDateFormaterLock unlock];
    
    return final;
}

- (NSString *)dayMonthAsStringFromDate:(NSDate *)date
{
    [self.dayMonthLevelDateFormaterLock lock];
    NSString *final = [self.dayMonthLevelDateFormater stringFromDate:date];
    [self.dayMonthLevelDateFormaterLock unlock];
    
    return final;
}

- (NSString *)minuteAsStringFromDate:(NSDate *)date
{
    [self.minuteLevelDateFormaterLock lock];
    NSString *final = [self.minuteLevelDateFormater stringFromDate:date];
    [self.minuteLevelDateFormaterLock unlock];
    
    return final;
}

- (NSString *)secondAsStringFromDate:(NSDate *)date
{
    [self.secondLevelDateFormaterLock lock];
    NSString *final = [self.secondLevelDateFormater stringFromDate:date];
    [self.secondLevelDateFormaterLock unlock];
    
    return final;
}

@end

@implementation WHLDate

+ (NSDate *)dateFromDayString:(NSString *)dayString timeString:(NSString *)timeString
{
    if (![dayString length]) {
        return nil;
    }
    
    NSString *dateString = nil;
    
    if ([dayString length] > 11) {
        dateString = dayString;
    } else {
        dateString = [NSString stringWithFormat:@"%@ %@", dayString, [timeString length] ? timeString : @"00:00:01"];
    }
    
    NSDate *date = [[WHLDateManager sharedManager] secondAsDateFromString:dateString];
    if (!date) {
        date = [[WHLDateManager sharedManager] minuteAsDateFromString:dateString];
    }
    if (!date) {
        date = [[WHLDateManager sharedManager] dayAsDateFromString:dateString];
    }
    
    return date;
}

+ (NSString *)smartDescriptionWithDayString:(NSString *)dayString timeString:(NSString *)timeString maxRelativePastDays:(NSUInteger)maxRelativePastDays
{
    NSDate *date = [self dateFromDayString:dayString timeString:timeString];
    
    return date ? [date whl_smartDescriptionWithMaxRelativePastDays:maxRelativePastDays] : @"";
}

@end

@implementation NSDate (WHLAdditions)

- (BOOL)whl_inSameYearAsDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components1 = [calendar components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [calendar components:NSCalendarUnitYear fromDate:date];
    
    return components1.year == components2.year;
}

- (BOOL)whl_inSameDayAsDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components1 = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    NSDateComponents *components2 = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    return (components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day);
}

- (NSString *)whl_smartDescriptionWithMaxRelativePastDays:(NSUInteger)maxRelativePastDays
{
    return [self whl_smartDescriptionWithMaxRelativePastDays:maxRelativePastDays isDayMonthLevel:NO];
}

- (NSString *)whl_smartDescriptionWithMaxRelativePastDays:(NSUInteger)maxRelativePastDays isDayMonthLevel:(BOOL)isDayMonthLevel
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self];
    
    if (timeInterval < 60.0) {
        return @"刚刚";
    }
    
    NSString *finalString = nil;
    
    if (timeInterval < 0) {
        if (isDayMonthLevel) {
            if ([self whl_inSameYearAsDate:[NSDate date]]) {
                finalString = [[WHLDateManager sharedManager] dayMonthAsStringFromDate:self];
            } else {
                finalString = [[WHLDateManager sharedManager] dayAsStringFromDate:self];
            }
        } else {
            finalString = [[WHLDateManager sharedManager] dayAsStringFromDate:self];
        }
    } else {
        if (timeInterval < M_HOUR) {
            finalString = [NSString stringWithFormat:@"%.0f分钟前", floorf(timeInterval / M_MINUTE)];
        } else if (timeInterval < M_DAY) {
            finalString = [NSString stringWithFormat:@"%.0f小时前", floorf(timeInterval / M_HOUR)];
        } else if (timeInterval < M_DAY * maxRelativePastDays) {
            finalString = [NSString stringWithFormat:@"%.0f天前", floorf(timeInterval / M_DAY)];
        } else {
            if (isDayMonthLevel) {
                if ([self whl_inSameYearAsDate:[NSDate date]]) {
                    finalString = [[WHLDateManager sharedManager] dayMonthAsStringFromDate:self];
                } else {
                    finalString = [[WHLDateManager sharedManager] dayAsStringFromDate:self];
                }
            } else {
                finalString = [[WHLDateManager sharedManager] dayAsStringFromDate:self];
            }
        }
    }
    
    if (finalString == nil) {
        return @"";
    }
    
    return finalString;
}

- (BOOL)whl_isOverdueWithStartingTime:(NSDate *)startingTime duration:(NSTimeInterval)duration
{
    return [NSDate whl_isTime:[self timeIntervalSince1970] laterThan:[startingTime timeIntervalSince1970] duration:duration];
}

+ (BOOL)whl_isTime:(NSTimeInterval)time laterThan:(NSTimeInterval)startingTime duration:(NSTimeInterval)duration
{
    if ((time < startingTime) || (time > startingTime + duration)) {
        return YES;//time小于startingTime的异常情况，也看作是过期
    } else {
        return NO;
    }
}

@end

