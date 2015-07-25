//
//  LockModel.m
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LockModel.h"

@implementation LockModel

- (instancetype)initWithParameters:(NSDictionary *)parameters {
    if(self = [super initWithParameters:parameters]) {
        self.pwd = [RLTypecast stringToLongLongInteger:[parameters objectForKey:@"lockPwd"]];
        self.address = [parameters objectForKey:@"bleAddress"];
    }
    
    return self;
}

- (instancetype)initWithLockEntity:(LockEntity *)lockEntity {
    if(self = [super init]) {
        self.ID = [lockEntity.lockID integerValue];
        self.pwd = [lockEntity.pwd longLongValue];
        self.type = [lockEntity.type integerValue];
        self.status = [lockEntity.status integerValue];
        self.address = [lockEntity address];
        self.caption = lockEntity.caption;
        self.name = lockEntity.name;
        self.ower = lockEntity.ownUser;
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *parameters = nil;
    parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:self.name forKey:@"lockName"];
    [parameters setObject:self.address forKey:@"bleAddress"];
    [parameters setObject:self.token forKey:@"accessToken"];
    [parameters setObject:[RLTypecast longLongToString:self.pwd] forKey:@"lockPwd"];
    
    return parameters;
}
@end
