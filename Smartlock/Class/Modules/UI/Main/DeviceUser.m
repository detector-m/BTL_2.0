//
//  DeviceUser.m
//  Smartlock
//
//  Created by RivenL on 15/6/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "DeviceUser.h"
@interface DeviceUser ()
@property (nonatomic, readwrite, assign) NSUInteger ID;
@property (nonatomic, readwrite, copy) NSString *name;
@end

@implementation DeviceUser
@synthesize ID;
@synthesize name;

- (void)setWithParameters:(NSDictionary *)parameters {
    if(!parameters || parameters.count == 0) {
        return;
    }
    
    self.name = self.nickname = parameters[@"memberName"];
    self.phone = parameters[@"mobile"];
    self.dqID = parameters[@"guestChikyugo"];
    self.gid = parameters[@"gid"];
    self.gender = [parameters[@"sex"] integerValue];
}

@end
