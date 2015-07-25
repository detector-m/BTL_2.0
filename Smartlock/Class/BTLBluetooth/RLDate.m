//
//  RLDate.m
//  Smartlock
//
//  Created by RivenL on 15/5/16.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLDate.h"

#pragma mark -

long long secondTimestampSince1970() {
    return (long long)[[NSDate date] timeIntervalSince1970];
}

long long timestampSince1970() {
    long long timestamp = 0ll;
    
    timestamp = secondTimestampSince1970();
    return timestamp;
}

NSTimeInterval timestampSince1970WithReal() {
    return [[NSDate date] timeIntervalSince1970];
}

NSString *timeStringWithTimestamp(long long timestamp) {
    long long sub = secondTimestampSince1970() - timestamp;
    
    NSInteger hour = 60 * 60;
    NSInteger day = hour * 24;
    
    if(sub < 0)
        return @"";
    if(sub < 60) {
        if(sub == 0)
            sub = 1;
        return [NSString stringWithFormat:@"%llds前", sub];
    }
    if(sub >= 60 && sub < hour) {
        return [NSString stringWithFormat:@"%lld分钟前", (long long)(sub/60)];
    }
    
    if(sub >= hour && sub < day) {
        return [NSString stringWithFormat:@"%li小时前", (long)(sub/hour)];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-sub];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSInteger month = day * 31;

    if(sub >= day && sub < month) {
        NSString *string = [formatter stringFromDate:date];
        return [string substringFromIndex:5];
    }
    
    if(sub >= month) {
        return [formatter stringFromDate:date];
    }
    

    
#if 0
    NSInteger month = day * 31;
    NSInteger year = month * 12;

    if(sub >= day && sub < month) {
        return [NSString stringWithFormat:@"%i", (NSInteger)(sub/day)];
    }
    
    if(sub >= month && sub < year) {
        return [NSString stringWithFormat:@"%i", (NSInteger)(sub/month)];
    }
    
    if(sub >= year) {
        return [NSString stringWithFormat:@"%i", (NSInteger)(sub/year)];
    }
#endif
    
    return @"";
}

#pragma mark -
NSString *dateStringFromTimestamp(long long timestamp) {
    if(timestamp < 0)
        return @"";
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter stringFromDate:date];
}

#pragma mark -
@implementation RLDate
+ (NSDate *)dateFromString:(NSString *)dateString {
    if(!dateString || dateString.length == 0) {
        return nil;
    }
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    dateformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateformatter dateFromString:dateString];
    
    return date;
}

#pragma mark -
+ (NSDateComponents *)dateComponentsWithDate:(NSDate *)date {
    if(!date)
        return nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    return dateComponents;
}

+ (NSDateComponents *)dateComponentsNow {
    NSDate *date = [NSDate date];
    
    return [self dateComponentsWithDate:date];
}
@end
