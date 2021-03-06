//
//  NSDate+Additons.m
//  YiYiProject
//
//  Created by lichaowei on 15/5/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "NSDate+Additons.h"

@implementation NSDate (Additons)

/**
 *  时间间隔小时
 *
 *  @param toDate 比较的时间
 *
 *  @return 返回天数
 */
- (NSInteger)hoursBetweenDate:(NSDate *)toDate
{
    NSTimeInterval time = [self timeIntervalSinceDate:toDate];
    return  fabs(time / 60 / 60);
}

/**
 *  时间间隔天数
 *
 *  @param toDate 比较的时间
 *
 *  @return 返回天数
 */
- (NSInteger)daysBetweenDate:(NSDate *)toDate
{
    NSTimeInterval time = [self timeIntervalSinceDate:toDate];
    return  fabs(time / 60 / 60 / 24);
}

/**
 *  返回星期
 *
 *  @return 星期几
 */
- (NSString *)weekString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSArray *weekdayAry = [NSArray arrayWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    [dateFormat  setShortWeekdaySymbols:weekdayAry];
    [dateFormat setDateFormat:@"eee"];
    NSDate *date = self;
    NSString *srting = [dateFormat stringFromDate:date];
    return srting;
}

@end
