//
//  AuthCodeVC.h
//  Smartlock
//
//  Created by RivenL on 15/3/31.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BaseVC.h"
#import "Register.h"

typedef enum {
    kRegister = 0,
    kForgetPSW,
}SetPasswordType;
@interface AuthCodeVC : BaseVC
@property (nonatomic, assign) SetPasswordType type;
@end
