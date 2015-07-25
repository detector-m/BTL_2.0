//
//  User.h
//  Smartlock
//
//  Created by RivenL on 15/4/9.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLUser.h"

@interface User : RLUser
@property (nonatomic, copy) NSString *dqID;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *gid;

@property (nonatomic, strong) NSData *certificazte;
@end
