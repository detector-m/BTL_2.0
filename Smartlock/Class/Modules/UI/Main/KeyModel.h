//
//  KeyModel.h
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LockModel.h"

#if 0
/**用户类型：管理员*/
USER_TYPE_ADMIN = 0;
/**用户类型：普通用户*/
USER_TYPE_NOR = 1;
/**状态：正常*/
STATUS_NOR = 0 ;
/**状态：冻结*/
STATUS_FREEZE = 1 ;
/**状态：过期*/
STATUS_EXPIRE = 2 ;
/**状态：重新配对，钥匙删除*/
STATUS_DEL = 3 ;
/**钥匙类型：永久*/
KEYTYPE_FOR_EVER = 1;
/**钥匙类型：期限*/
KEYTYPE_FOR_DEADLINE = 2;
/**钥匙类型：次数*/
KEYTYPE_FOR_TIME = 3;

/*是否管理员0：管理员，1：普通用户*/
userType;
/*钥匙的状态:0正常，1冻结，2过期*/
status;
/*钥匙类型:1永久，2期限，3次数*/
keyType;
#endif

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
@property (nonatomic, strong) NSString *startDate; //开始日期
@property (nonatomic, strong) NSString *invalidDate; //截至日期
@property (nonatomic, assign) KeyStatus keyStatus;
@property (nonatomic, assign) UserType userType;

@property (nonatomic, assign) long long startTimeInterval;
@property (nonatomic, assign) long long invalidTimeInterval;

#pragma mark -
@property (nonatomic, strong) LockModel *keyOwner;

- (instancetype)initWithKeyEntity:(KeyEntity *)keyEntity;
- (BOOL)isValid;
@end
