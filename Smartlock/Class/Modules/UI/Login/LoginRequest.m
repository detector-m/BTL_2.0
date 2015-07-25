//
//  LoginRequest.m
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LoginRequest.h"

@implementation LoginRequest
+ (void)login:(id)login withBlock:(void (^)(LoginResponse *response, NSError *error))block {
    
    LoginModel *temp = login;
    
    NSDictionary *parameters = temp.toDictionary;
    
    [self requestWithUrl:@"member/login.jhtml"  withParameters:parameters andBlock:block];
}

+ (void)logout:(NSString *)token withBlock:(void (^)(LoginResponse *response, NSError *error))block {
    NSDictionary *parameters = [LoginModel logoutWithToken:token];
    
    [self requestWithUrl:@"member/loginOut.jhtml" withParameters:parameters andBlock:block];
}
@end
