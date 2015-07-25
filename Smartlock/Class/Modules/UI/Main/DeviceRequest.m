//
//  DeviceRequest.m
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "DeviceRequest.h"

@implementation DeviceRequest
+ (void)addBluLock:(LockModel *)lock withBlock:(void (^)(DeviceResponse *, NSError *))block {
    NSDictionary *parameters = lock.toDictionary;
    
    [self requestWithUrl:@"bleLock/addBleLock.jhtml"  withParameters:parameters andBlock:block];
}

+ (void)sendKey:(KeyModel *)key withBlock:(void (^)(DeviceResponse *, NSError *))block {
    NSDictionary *parameters = key.toDictionary;
    
    [self requestWithUrl:@"bleLock/sendBleLock.jhtml"  withParameters:parameters andBlock:block];
}

+ (void)lockList:(NSString *)accessToken withBlock:(void (^)(DeviceResponse *, NSError *))block {
    NSDictionary *parameters = [DeviceModel lockListParameters:accessToken];
    
    [self requestWithUrl:@"bleLock/getBleKeyList.jhtml" withParameters:parameters andBlock:block];
}

/**
 *  修改钥匙昵称
 *
 *  @param keyId   keyId
 *  @param gid     用户id
 *  @param token   accessToken
 *  @param keyName 钥匙的昵称
 */
+ (void)modifyKeyName:(NSInteger)keyId gid:(NSString *)gid token:(NSString *)token keyName:(NSString *)keyName withBlock:(void (^)(DeviceResponse *, NSError *))block {
    NSDictionary *parameters = [DeviceModel modifyKeyNameParameters:keyId gid:gid token:token keyName:keyName];
    
    [self requestWithUrl:@"bleLock/editLockName.jhtml" withParameters:parameters andBlock:block];
}

+ (void)keyListOfAdmin:(NSUInteger)lockID token:(NSString *)token withBlock:(void (^)(DeviceResponse *, NSError *))block {
    NSDictionary *parameters = [DeviceModel keyListOfAdminParameters:token lockID:lockID];
    
    [self requestWithUrl:@"bleLock/getBleKeyListByLockId.jhtml" withParameters:parameters andBlock:block];
}

+ (void)lockOrUnlockKey:(NSUInteger)keyID operation:(NSUInteger)operation token:(NSString *)token withBlock:(void (^)(DeviceResponse *, NSError *))block {
    NSDictionary *parameters = [DeviceModel lockOrUnlockKeyParameters:keyID operation:operation token:token];
    
    [self requestWithUrl:@"bleLock/controlMemberLock.jhtml" withParameters:parameters andBlock:block];
}

+ (void)deleteKey:(NSUInteger)keyID token:(NSString *)token withBlock:(void (^)(DeviceResponse *response, NSError *error))block {
    NSDictionary *parameters = [DeviceModel deleteKeyParameters:keyID token:token];
    
    [self requestWithUrl:@"bleLock/delBleKey.jhtml" withParameters:parameters andBlock:block];
}

+ (void)openLock:(NSString *)recordList token:(NSString *)token withBlock:(void (^)(DeviceResponse *response, NSError *error))block {
    NSDictionary *parameters = [DeviceModel openLockParameters:recordList token:token];
    
    [self requestWithUrl:@"bleLock/openLock.jhtml" withParameters:parameters andBlock:block];
}
@end
