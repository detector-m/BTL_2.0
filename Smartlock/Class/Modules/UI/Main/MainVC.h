//
//  MainVC.h
//  Smartlock
//
//  Created by RivenL on 15/3/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BaseVC.h"
#import "KeyModel.h"
#import "RLBluetooth.h"

@interface MainVC : BaseVC
@property (nonatomic, strong) RLBluetooth *manager;

@property (nonatomic, assign) NSInteger messageBadgeNumber;

- (void)addKey:(KeyModel *)key;
- (void)removeKey:(KeyModel *)key;

- (void)loadLockList;

- (NSArray *)locks;

#pragma mark -
- (void)cancelAutoOpenlockTimer;
@end
