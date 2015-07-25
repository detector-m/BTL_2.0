//
//  RLDate.h
//  Smartlock
//
//  Created by RivenL on 15/5/16.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
extern long long timestampSince1970();
extern NSString *timeStringWithTimestamp(long long timestamp);
extern NSString *dateStringFromTimestamp(long long timestamp);

extern NSTimeInterval timestampSince1970WithReal();

#pragma mark - 
@interface RLDate : NSObject
+ (NSDate *)dateFromString:(NSString *)dateString;
#pragma mark -
+ (NSDateComponents *)dateComponentsWithDate:(NSDate *)date;
+ (NSDateComponents *)dateComponentsNow;
@end
