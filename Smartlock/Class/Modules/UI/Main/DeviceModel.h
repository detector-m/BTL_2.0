//
//  DeviceModel.h
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLPeripheral.h"

#import "DeviceUser.h"

@interface DeviceModel : NSObject
@property (nonatomic, assign) NSUInteger ID;
@property (nonatomic, assign) long long pwd;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *ower; //memberGid
@property (nonatomic, copy) NSString *time;

@property (nonatomic, assign) NSInteger status;

#pragma mark -
@property (nonatomic, weak) NSString *token;

#pragma mark -
@property (nonatomic, strong) DeviceUser *user;

- (instancetype)initWithParameters:(NSDictionary *)parameters;
- (NSDictionary *)toDictionary;

#pragma mark -
+ (NSDictionary *)lockListParameters:(NSString *)accessToken;
+ (NSDictionary *)modifyKeyNameParameters:(NSInteger)keyId gid:(NSString *)gid token:(NSString *)token keyName:(NSString *)keyName;
+ (NSDictionary *)keyListOfAdminParameters:(NSString *)token lockID:(NSUInteger)lockID;
+ (NSDictionary *)lockOrUnlockKeyParameters:(NSUInteger)keyID operation:(NSUInteger)operation token:(NSString *)token;
+ (NSDictionary *)deleteKeyParameters:(NSUInteger)keyID token:(NSString *)token;

+ (NSDictionary *)openLockParameters:(NSString *)recordList token:(NSString *)token;
@end