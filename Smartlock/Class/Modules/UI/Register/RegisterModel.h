//
//  RegisterModel.h
//  Smartlock
//
//  Created by RivenL on 15/4/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LoginModel.h"
#import "User.h"

//@interface AuthcodeModel
//
//@end

@interface RegisterModel : LoginModel
@property (nonatomic, readonly, unsafe_unretained) id user;

+ (NSDictionary *)verifyPhoneParametersWithPhone:(NSString *)phone;
+ (NSDictionary *)getAuthcodeParametersWithPhone:(NSString *)phone;
+ (NSDictionary *)verifyAuthcodeParametersWithPhone:(NSString *)phone andAuthcode:(NSString *)authcode;
@end

@interface FindPasswordModel : NSObject
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *authcode;
@property (nonatomic, copy) NSString *password;

- (NSDictionary *)toDictionary;
@end
