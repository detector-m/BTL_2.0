//
//  RLBaseViewController.h
//  Smartlock
//
//  Created by RivenL on 15/3/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLBaseViewController : UIViewController
//- (void)showAlertView:(NSString*)alertString;
@end

@interface RLBaseViewController (BTLBluetooth)
- (BOOL)checkLowEnergyBluetoothIsOk;
@end
