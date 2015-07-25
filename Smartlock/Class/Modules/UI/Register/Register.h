//
//  Register.h
//  Smartlock
//
//  Created by RivenL on 15/4/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RegisterRequest.h"

@interface Register : NSObject
+ (void)verifyPhone:(NSString *)phone withBlock:(void (^)(id response, NSError *error))block;

+ (void)getAuthcode:(NSString *)phone withBlock:(void (^)(id response, NSError *error))block;

+ (void)verifyAuthcode:(NSString *)phone authcode:(NSString *)authcode withBlock:(void (^)(id response, NSError *error))block;

+ (void)register:(RegisterModel *)aRegister withBlock:(void (^)(RegisterResponse *response, NSError *error))block;

+ (void)findPassword:(FindPasswordModel *)findPasswordModel withBlock:(void (^)(RegisterResponse *response, NSError *error))block;
@end
