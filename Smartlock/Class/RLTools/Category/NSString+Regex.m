//
//  NSString+Regex.m
//  GlobalVillage_First
//
//  Created by RivenL on 14/12/3.
//  Copyright (c) 2014年 RivenL. All rights reserved.
//

#import "NSString+Regex.h"

@implementation NSString (Regex)
- (BOOL)isMatched:(NSString *)regexString {
    if(regexString && regexString.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
        return [predicate evaluateWithObject:self];
    }
    
    return NO;
}

- (BOOL)isEmail {
    NSString *regexString = @"[a-zA-Z0-9._%+-]+@[A-Za-z0-9.-]+\\.[a-zA-Z]{2,4}";
    return [self isMatched:regexString];
}

- (BOOL)isMobile {
    NSString *regexString = @"^((13[0-9])|(15[^4, \\D])|(18[0, 0-9]))\\d{8}$";
    
    return [self isMatched:regexString];
}

- (BOOL)isMobileAuthCode {
    NSString *regexString = @"^[a-zA-Z0-9]{4,8}$";
    
    return [self isMatched:regexString];
}

//是否是地球号
- (BOOL)isChikyugo {
    NSString *regexString = @"^[a-zA-Z0-9]{6,10}$";
    
    return [self isMatched:regexString];
}

@end
