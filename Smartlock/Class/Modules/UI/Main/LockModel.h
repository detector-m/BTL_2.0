//
//  LockModel.h
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "DeviceModel.h"
#import "LockEntity.h"

@class LockEntity;
@interface LockModel : DeviceModel
@property (nonatomic, copy) NSString *address;

- (instancetype)initWithLockEntity:(LockEntity *)lockEntity;
@end 
