//
//  KeyModel.h
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LockModel.h"

typedef NS_ENUM(NSInteger, KeyStatus) {
    kKeyNormal,
    kKeyFreeze,
    kKeyExpire,
    kKeyDelete,
};

typedef NS_ENUM(NSInteger, UserType) {
    kUserTypeAdmin = 0,
    kUserTypeCommon,
};

typedef NS_ENUM(NSInteger, KeyType) {
    kKeyTypeForever = 1,
    kKeyTypeDate,
    kKeyTypeTimes,
};

@class KeyEntity;

@interface KeyModel : DeviceModel
@property (nonatomic, assign) NSUInteger lockID;
@property (nonatomic, assign) NSUInteger validCount;
@property (nonatomic, strong) NSString *invalidDate; //截至日期
@property (nonatomic, assign) KeyStatus keyStatus;
@property (nonatomic, assign) UserType userType;

@property (nonatomic, assign) long long invalidTimeInterval;

#pragma mark -
@property (nonatomic, strong) LockModel *keyOwner;

- (instancetype)initWithKeyEntity:(KeyEntity *)keyEntity;
- (BOOL)isValid;
@end
