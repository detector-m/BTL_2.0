//
//  RLTable.m
//  Smartlock
//
//  Created by RivenL on 15/3/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLTable.h"

@interface RLTable ()
//@property (nonatomic, readwrite, weak) NSMutableArray *datas;
@end
@implementation RLTable
- (void)dealloc {
    [self.datas removeAllObjects], self.datas = nil;
    self.tableView = nil;
}

- (instancetype)init {
    if(self = [super init]) {
        self.datas = [NSMutableArray new];
    }
    return self;
}

//- (NSArray *)datas {
//    return self.tableDatas;
//}

#pragma mark -
- (void)addObjectFromArray:(NSArray *)objects {
    if(!objects || objects.count == 0) {
        return;
    }
    
    [self.datas addObjectsFromArray:objects];
}

@end
