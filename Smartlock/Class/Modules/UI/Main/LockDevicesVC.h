//
//  LockDevicesVC.h
//  Smartlock
//
//  Created by RivenL on 15/3/23.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BaseTableVC.h"

#import "RLCharacteristic.h"
#import "RLDefines.h"
#import "RLPeripheral.h"
#import "BluetoothLockCommand.h"

#import "KeyModel.h"

@class MainVC;
@interface LockDevicesVC : BaseTableVC
@property (nonatomic, weak) MainVC *mainVC;
#pragma mark -
- (void)addLockWithPeripheral:(LockModel *)lock;
@end
