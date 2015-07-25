//
//  DeviceManager.m
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "DeviceManager.h"

typedef void (^callbackBlock)(DeviceResponse *, NSError *);
static void callbackFunction(__weak callbackBlock block, id responseObject, NSError *error) {
    if(error) {
        if(block) {
            block(nil, error);
        }
        return ;
    }
    DeviceResponse *response = [[DeviceResponse alloc] initWithResponseObject:responseObject];
    
    if(block) {
        block(response, nil);
    }
}

@implementation DeviceManager
+ (void)addBluLock:(LockModel *)lock withBlock:(void (^)(DeviceResponse *, NSError *))block {

    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    
    [DeviceRequest addBluLock:lock withBlock:callBlock];
}

+ (void)sendKey:(KeyModel *)key withBlock:(void (^)(DeviceResponse *, NSError *))block {
    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    
    [DeviceRequest sendKey:key withBlock:callBlock];
}

+ (void)lockList:(NSString *)accessToken withBlock:(void (^)(DeviceResponse *, NSError *))block {
    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
//        if(error) {
//            if(block) {
//                block(nil, error);
//            }
//            return ;
//        }
//        DeviceResponse *response = [[DeviceResponse alloc] initWithResponseObject:responseObject];
//        
//        if(block) {
//            block(response, nil);
//        }
        callbackFunction(block, responseObject, error);
    };
    [DeviceRequest lockList:accessToken withBlock:callBlock];
}

+ (void)modifyKeyName:(NSInteger)keyId gid:(NSString *)gid token:(NSString *)token keyName:(NSString *)keyName withBlock:(void (^)(DeviceResponse *response, NSError *error))block {
    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    [DeviceRequest modifyKeyName:keyId gid:gid token:token keyName:keyName withBlock:callBlock];
}

+ (void)keyListOfAdmin:(NSUInteger)lockID token:(NSString *)token withBlock:(void (^)(DeviceResponse *, NSError *))block {
    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    [DeviceRequest keyListOfAdmin:lockID token:token withBlock:callBlock];
}

+ (void)lockOrUnlockKey:(NSUInteger)keyID operation:(NSUInteger)operation token:(NSString *)token withBlock:(void (^)(DeviceResponse *, NSError *))block {
    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    
    [DeviceRequest lockOrUnlockKey:keyID operation:operation token:token withBlock:callBlock];
}

+ (void)deleteKey:(NSUInteger)keyID token:(NSString *)token withBlock:(void (^)(DeviceResponse *, NSError *))block {
    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    
    [DeviceRequest deleteKey:keyID token:token withBlock:callBlock];
}

+ (void)openLock:(NSString *)recordList token:(NSString *)token withBlock:(void (^)(DeviceResponse *response, NSError *error))block {
    void (^callBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        callbackFunction(block, responseObject, error);
    };
    [DeviceRequest openLock:recordList token:token withBlock:callBlock];
}
@end
