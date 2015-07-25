//
//  LoginRequest.h
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLRequest.h"

#import "LoginModel.h"
#import "LoginResponse.h"

@interface LoginRequest : RLRequest
+ (void)login:(id)login withBlock:(void (^)(LoginResponse *response, NSError *error))block;

+ (void)logout:(NSString *)token withBlock:(void (^)(LoginResponse *response, NSError *error))block;
@end
