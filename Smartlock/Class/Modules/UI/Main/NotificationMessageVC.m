//
//  NotifierMessageVC.m
//  Smartlock
//
//  Created by RivenL on 15/5/8.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "NotificationMessageVC.h"
#import "MessageContentVC.h"

#import "MyCoreDataManager.h"
#import "RLDate.h"

#pragma mark -
#import "XMPPManager.h"

@interface NotificationMessageCell : ListCell

@end

@implementation NotificationMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
    
    }
    
    return self;
}
@end


@implementation NotificationMessageVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"消息", nil);
    self.table.tableView.rowHeight = 66.0f;
    NSArray *messages = [[MyCoreDataManager sharedManager] objectsSortByAttribute:nil withTablename:NSStringFromClass([Message class])];
    if(!messages.count) self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.table addObjectFromArray:[self reverseArray:messages]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage) name:(NSString *)kReceiveMessage object:nil];
}

#pragma mark -
- (void)clickedClearBtn:(UIBarButtonItem *)btn {
    [[MyCoreDataManager sharedManager]  deleteAllTableObjectInTable:NSStringFromClass([Message class])];
    [self.table.datas removeAllObjects];
    [self.table.tableView reloadData];
}
- (void)setupRightItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clickedClearBtn:)];
}

#pragma mark -
- (void)receiveMessage {
    [self.table.datas removeAllObjects];
    [[MyCoreDataManager sharedManager] updateObjectsInObjectTable:@{@"isRead" : @YES} withKey:@"isRead" contains:@NO withTablename:NSStringFromClass([Message class])];

    NSArray *messages = [[MyCoreDataManager sharedManager] objectsSortByAttribute:nil withTablename:NSStringFromClass([Message class])];
    
    if(!messages.count) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }

    [self.table.datas addObjectsFromArray:[self reverseArray:messages]];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.table.tableView reloadData];
    });
}

#pragma mark -
- (NSArray *)reverseArray:(NSArray *)array {
    return [[array reverseObjectEnumerator] allObjects];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.table.datas.count;
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
    [tableView registerClass:[NotificationMessageCell class] forCellReuseIdentifier:kCellIdentifier];
    NotificationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString *)kCellIdentifier forIndexPath:indexPath];
    NSInteger index = [self indexForData:indexPath];
    Message *message = [self.table.datas objectAtIndex:index];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *displayname = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    cell.textLabel.text = displayname;//NSLocalizedString(@"永家科技", nil);
    cell.imageView.image = [UIImage imageNamed:@"MessageAvater.png"];
    cell.detailTextLabel.text = message.content;
    cell.timeLabel.text = timeStringWithTimestamp([message.timestamp longLongValue]);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            MessageContentVC *vc = [[MessageContentVC alloc] init];
            NSInteger index = [self indexForData:indexPath];
            vc.message = [self.table.datas objectAtIndex:index];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger index = [self indexForData:indexPath];
        Message *message = [self.table.datas objectAtIndex:index];
        [[MyCoreDataManager sharedManager] deleteTableRecord:message withTablename:NSStringFromClass([message class])];
        [self.table.datas removeObject:message];
        [self.table.tableView reloadData];
                
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
@end
