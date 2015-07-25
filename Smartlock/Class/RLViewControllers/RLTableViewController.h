//
//  RLTableViewController.h
//  Smartlock
//
//  Created by RivenL on 15/6/15.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLBaseViewController.h"
#import "RLTable.h"

@interface RLTableViewController : RLBaseViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, readonly, strong) RLTable *table;

- (NSInteger)indexForData:(NSIndexPath *)indexPath;
- (void)deselectRow;
@end
