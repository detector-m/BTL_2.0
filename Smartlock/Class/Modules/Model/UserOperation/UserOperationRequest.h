//
//  UserOperationRequest.h
//  Smartlock
//
//  Created by RivenL on 15/5/19.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLRequest.h"
#import "UserOperationResponse.h"

@interface UserOperationRequest : RLRequest
#pragma mark -
/**
 *  修改信息
 *
 *  @param infoDictionary parameters
 *  @param block          刷新ui
 */
+ (void)modifyInfo:(NSDictionary *)infoDictionary withBlock:(void (^)(UserOperationResponse *response, NSError *error))block;

/**
 *  修改密码
 *
 *  @param oldPwd 旧密码
 *  @param newPwd 新密码
 *  @param token  token
 *  @param block  刷新ui
 */
+ (void)resetPassword:(NSString *)oldPwd newPwd:(NSString *)newPwd token:(NSString *)token withBlock:(void (^)(UserOperationResponse *response, NSError *error))block;
#pragma mark -
+ (NSDictionary *)paramaterForModifyNickname:(NSString *)nickname andToken:(NSString *)token;
@end
