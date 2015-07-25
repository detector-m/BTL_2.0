//
//  AddDeviceVC.h
//  Smartlock
//
//  Created by RivenL on 15/5/8.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLTableViewController.h"
#import "LockCell.h"
#import "LockModel.h"

#import "RLCharacteristic.h"
#import "RLDefines.h"
#import "RLPeripheral.h"
#import "BluetoothLockCommand.h"

@class LockDevicesVC;
@interface AddDeviceVC : RLTableViewController
//@property (nonatomic, weak) RLCentralManager *manager;

@property (nonatomic, weak) LockDevicesVC *lockDevicesVC;
@end
