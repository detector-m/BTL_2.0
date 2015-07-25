//
//  ExcuteVC.h
//  Smartlock
//
//  Created by RivenL on 15/4/26.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLTitleTextField.h"

#import "RLPeripheral.h"
#import "BluetoothLockCommand.h"

@interface ExcuteVC : UIViewController
@property (nonatomic, strong) RLTitleTextField *textField;

@property (nonatomic, weak) RLCharacteristic *ch;
@end
