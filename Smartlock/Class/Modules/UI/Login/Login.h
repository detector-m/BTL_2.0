//
//  Login.h
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LoginRequest.h"

@interface Login : NSObject
+ (void)login:(id)login withBlock:(void (^)(LoginResponse *response, NSError *error))block;

+ (void)logout:(NSString *)token withBlock:(void (^)(LoginResponse *response, NSError *error))block;

#pragma mark - UI
+ (void)login;
+ (void)logout;
+ (void)forcedLogout;
+ (void)hudAlertLogout;
@end
