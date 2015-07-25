//
//  RLTypecast.m
//  GlobalVillage
//
//  Created by RivenL on 15/1/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLTypecast.h"

@implementation RLTypecast
+ (NSString *)integerToString:(NSInteger)aInt {
    return [NSString stringWithFormat:@"%li", (long)aInt];
}
+ (NSString *)longLongToString:(long long)aInt {
    return [NSString stringWithFormat:@"%lli", aInt];
}
+ (NSString *)floatToString:(CGFloat)aFloat {
    return [NSString stringWithFormat:@"%f", aFloat];
}
+ (NSString *)doubleToString:(double)aDouble {
    return [NSString stringWithFormat:@"%f", aDouble];
}
+ (NSInteger)stringToInteger:(NSString *)aStr {
    if(aStr == nil || aStr.length == 0)
        return 0;
    
    return [aStr integerValue];
}

+ (long long)stringToLongLongInteger:(NSString *)aStr {
    if(aStr == nil || aStr.length == 0)
        return 0;
    
    return [aStr longLongValue];
}

+ (CGFloat)stringToFloat:(NSString *)aStr {
    if(aStr == nil || aStr.length == 0)
        return 0.0f;
    
    return [aStr floatValue];
}
+ (double)stringToDouble:(NSString *)aStr {
    if(aStr == nil || aStr.length == 0)
        return 0.0;
    
    return [aStr doubleValue];
}

+ (NSString *)numberToString:(NSNumber *)aNumber {
    if(aNumber == nil)
        return nil;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    return [numberFormatter stringFromNumber:aNumber];
}
+ (NSNumber *)stringToNumber:(NSString *)aStr {
    if(aStr == nil || aStr.length == 0)
        return nil;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    return [numberFormatter numberFromString:aStr];
}

#pragma mark -
/**
 *  Decodes an NSString containing hex encoded bytes into an NSData object
 *
 *  @param string string
 *
 *  @return data
 */
+ (NSData *)stringToHexData:(NSString *)string
{
    int len = (int)[string length] / 2; // Target length
    unsigned char *buf = malloc(len);
    unsigned char *wholeByte = buf;
    char byteChars[3] = {0, 0, 0};
    
    
    int i;
    for (i=0; i < [string length] / 2; i++) {
        byteChars[0] = [string characterAtIndex:i*2];
        byteChars[1] = [string characterAtIndex:i*2+1];
        *wholeByte = strtol(byteChars, NULL, 16);
        wholeByte++;
    }
    
    buf[18] = 0;
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

+ (NSString *)dataToHexString:(NSData *)data {
    NSUInteger len = [data length];
    char * chars = (char *)[data bytes];
    NSMutableString * hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
    
    return hexString;
}

//判断整形
- (BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

//判断浮点型
- (BOOL)isPureFloat:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

@end
