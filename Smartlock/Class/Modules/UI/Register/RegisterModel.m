//
//  RegisterModel.m
//  Smartlock
//
//  Created by RivenL on 15/4/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RegisterModel.h"

#import "RLTypecast.h"
#import "RLUtilitiesMethods.h"

@interface RegisterModel ()
@property (nonatomic, readwrite, unsafe_unretained) id user;
@end

@implementation RegisterModel
- (instancetype)init {
    if(self = [super init]) {
        //        _user = [RLUser sharedUser];
        self.user = [User sharedUser];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    User *user = self.user;

    [mutableDic setObject:user.phone forKey:@"memberName"];
    [mutableDic setObject:user.phone forKey:@"mobile"];
    [mutableDic setObject:hexStringFromData(self.deviceToken)/*self.deviceToken*/ forKey:@"deviceToken"];

//    [mutableDic setObject:user.deviceToken forKey:@"deviceToken"];
    
    return mutableDic;
}

+ (NSDictionary *)verifyPhoneParametersWithPhone:(NSString *)phone {
    NSDictionary *parameters = @{@"number":phone};

    return parameters;
}

+ (NSDictionary *)getAuthcodeParametersWithPhone:(NSString *)phone {
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setObject:phone forKey:@"mobile"];
    [mutableDic setObject:@"iphone" forKey:@"mobileAppId"];
    return mutableDic;
}

+ (NSDictionary *)verifyAuthcodeParametersWithPhone:(NSString *)phone andAuthcode:(NSString *)authcode {
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setObject:phone forKey:@"mobile"];
    [mutableDic setObject:authcode forKey:@"authcode"];
    return mutableDic;
}
@end

@implementation FindPasswordModel
- (NSDictionary *)toDictionary {
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setObject:self.phone forKey:@"mobile"];
    [mutableDic setObject:self.authcode forKey:@"authcode"];
    [mutableDic setObject:self.password forKey:@"newPassward"];
    return mutableDic;
}
@end
