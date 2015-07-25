//
//  SetPasswordVC.h
//  Smartlock
//
//  Created by RivenL on 15/4/1.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BaseVC.h"
#import "AuthCodeVC.h"

@interface SetPasswordVC : BaseVC
@property (nonatomic, assign) SetPasswordType type;

@property (nonatomic, strong) FindPasswordModel *findPasswordModel;
@end
