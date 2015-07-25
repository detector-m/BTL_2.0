//
//  RLBaseViewController.m
//  Smartlock
//
//  Created by RivenL on 15/3/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLBaseViewController.h"
#import "UIViewController+Expand.h"
#import "RLBluetooth.h"
#import "RLHUD.h"

@interface RLBaseViewController ()

@end

@implementation RLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        if(self.navigationController) {
            CGRect frame = self.view.frame;
            self.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height-64);
        }
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupForDismissKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

@implementation RLBaseViewController (BTLBluetooth)
- (BOOL)checkLowEnergyBluetoothIsOk {
    if(![[RLBluetooth sharedBluetooth] isSupportBluetoothLow]) {
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"该设备不支持低功耗蓝牙!", nil)];
        return NO;
    }
    if(![[RLBluetooth sharedBluetooth] bluetoothIsReady]) {
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"请开启蓝牙！", nil)];
        return NO;
    }
    
    return YES;
}
@end
