//
//  ServicesViewController.h
//  Smartlock
//
//  Created by RivenL on 15/3/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLBaseTableViewController.h"
#import "RLPeripheral.h"

@interface ServicesViewController : RLBaseTableViewController
@property (nonatomic, weak) RLPeripheral *peripheral;
@end
