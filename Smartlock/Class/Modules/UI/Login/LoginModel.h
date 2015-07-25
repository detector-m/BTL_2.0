//
//  LoginModel.h
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLLogin.h"

@interface LoginModel : RLLogin
+ (NSDictionary *)logoutWithToken:(NSString *)token;
@end
