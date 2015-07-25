//
//  RLRegister.h
//  Smartlock
//
//  Created by RivenL on 15/4/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLLogin.h"
#import "RLUser.h"

@interface RLRegister : RLLogin
@property (nonatomic, readonly, unsafe_unretained) id user;
@end
