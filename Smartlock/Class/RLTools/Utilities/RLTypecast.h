//
//  RLTypecast.h
//  GlobalVillage
//
//  Created by RivenL on 15/1/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLTypecast : NSObject
+ (NSString *)integerToString:(NSInteger)aInt;
+ (NSString *)longLongToString:(long long)aInt;
+ (NSString *)floatToString:(CGFloat)aFloat;
+ (NSString *)doubleToString:(double)aDouble;
+ (NSInteger)stringToInteger:(NSString *)aStr;
+ (long long)stringToLongLongInteger:(NSString *)aStr;
+ (CGFloat)stringToFloat:(NSString *)aStr;
+ (double)stringToDouble:(NSString *)aStr;

+ (NSString *)numberToString:(NSNumber *)aNumber;
+ (NSNumber *)stringToNumber:(NSString *)aStr;

+ (NSData *)stringToHexData:(NSString *)string;
+ (NSString *)dataToHexString:(NSData *)data;
@end
