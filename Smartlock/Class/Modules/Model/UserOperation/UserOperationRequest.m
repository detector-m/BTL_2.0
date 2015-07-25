//
//  UserOperationRequest.m
//  Smartlock
//
//  Created by RivenL on 15/5/19.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "UserOperationRequest.h"

#import "RLSecurityPolicy.h"


typedef void (^callbackBlock)(UserOperationResponse *, NSError *);
static void callbackFunction(__weak callbackBlock block, id responseObject, NSError *error) {
    if(error) {
        if(block) {
            block(nil, error);
        }
        return ;
    }
    UserOperationResponse *response = [[UserOperationResponse alloc] initWithResponseObject:responseObject];
    
    if(block) {
        block(response, nil);
    }
}

@implementation UserOperationRequest
+ (void)modifyInfo:(NSDictionary *)infoDictionary withBlock:(void (^)(UserOperationResponse *response, NSError *error))block {
    
    void (^modifyInfoBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    
    [self requestWithUrl:@"member/updateUserInfo.jhtml" withParameters:infoDictionary andBlock:modifyInfoBlock];
}

+ (void)resetPassword:(NSString *)oldPwd newPwd:(NSString *)newPwd token:(NSString *)token withBlock:(void (^)(UserOperationResponse *response, NSError *error))block {
    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    
    [self requestWithUrl:@"member/editPassword.jhtml" withParameters:[self paramaterForResetPwd:oldPwd newPwd:newPwd token:token] andBlock:callBlock];
}


#pragma mark -
+ (NSDictionary *)paramaterForModifyNickname:(NSString *)nickname andToken:(NSString *)token {
    return @{@"memberName" : nickname, @"accessToken" : encryptedTokenToBase64(token, [User sharedUser].certificazte)};
}

+ (NSDictionary *)paramaterForResetPwd:(NSString *)oldPwd newPwd:(NSString *)newPwd token:(NSString *)token {
    return @{@"oldPassward": oldPwd, @"newPassward":newPwd, @"accessToken":encryptedTokenToBase64(token, [User sharedUser].certificazte)};
}
@end
