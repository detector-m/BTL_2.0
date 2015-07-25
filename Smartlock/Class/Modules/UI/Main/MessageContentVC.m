//
//  MessageContentVC.m
//  Smartlock
//
//  Created by RivenL on 15/5/8.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "MessageContentVC.h"

#import "TimeCell.h"
#import "MessageCell.h"

#import "RLColor.h"

@implementation MessageContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"消息", nil);
    
    self.table.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.tableView.backgroundColor = [RLColor colorWithHex:0xE5E5E5];//[UIColor grayColor];
    
    self.table.tableView.rowHeight = 66.0f;
}

#pragma mark -

- (void)setMessage:(NotificationMessage *)message {
    if(!message)
        return;
    _message = message;
    [self.table.datas addObject:timeStringWithTimestamp([message.timestamp longLongValue])];
    [self.table.datas addObject:message];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.table.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexForData:indexPath];
    id obj = [self.table.datas objectAtIndex:index];
    if([obj isKindOfClass:[NSString class]]) {
        return 30;
    }
    else {
        return [MessageCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:obj];
    }
}

- (NSInteger)indexForData:(NSIndexPath *)indexPath {
    NSInteger index = 0;
    for(NSInteger i=0; i<indexPath.section; i++) {
        index += [self tableView:nil numberOfRowsInSection:i];
    }
    index += indexPath.row;
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *timeIdentifier = @"TimeIdentifier";
    static NSString *messageIdentifier = @"MessageIdentifier";

    NSInteger index = [self indexForData:indexPath];
    id obj = [self.table.datas objectAtIndex:index];
    if([obj isKindOfClass:[NSString class]]) {
        TimeCell *cell = (TimeCell *)[tableView dequeueReusableCellWithIdentifier:timeIdentifier];
        if(cell == nil) {
            cell = [[TimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeIdentifier];
//            cell.backgroundColor = [UIColor clearColor];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = obj;
        return cell;
    }
    else {
        NotificationMessage *message = (NotificationMessage *)obj;
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:messageIdentifier];
        if(!cell) {
            cell = [[MessageCell alloc] initWithMessage:message reuseIdentifier:messageIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.message = message;
        return cell;
    }
    
    return nil;
}
@end
