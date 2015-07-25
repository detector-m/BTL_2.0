//
//  RLTable.h
//  Smartlock
//
//  Created by RivenL on 15/3/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLTable : NSObject
@property (nonatomic, readwrite, strong) NSMutableArray *datas;
@property (nonatomic, readwrite, strong) UITableView *tableView;

- (void)addObjectFromArray:(NSArray *)objects;
@end
