//
//  NSString+Regex.h
//  GlobalVillage_First
//
//  Created by RivenL on 14/12/3.
//  Copyright (c) 2014年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Regex)
//判断是否是邮箱
- (BOOL)isEmail;
//判断是否是电话号码
- (BOOL)isMobile;
//判断是否是英文和数字以及下划线
//- (BOOL)isWordNumAndUnderLine;
//判断是否是有中文

//是否是手机验证码
- (BOOL)isMobileAuthCode;

//是否是地球号
- (BOOL)isChikyugo;

@end
