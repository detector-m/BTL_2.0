//
//  BaseTableVC.h
//  Smartlock
//
//  Created by RivenL on 15/3/23.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLBaseTableViewController.h"
#import "RLTable.h"
//#import "TextAccessoryCell.h"
#import "ListCell.h"

#define kDefaultRowHeight 50.0f

@interface BaseTableVC : RLBaseTableViewController
@property (nonatomic, readonly, strong) RLTable *table;
- (void)setTableViewProperties;

- (void)setupBackItem:(NSString *)title;
- (void)setupRightItem;

- (void)deselectRow;
@end
