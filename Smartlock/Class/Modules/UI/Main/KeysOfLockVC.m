//
//  KeysOfLockVC.m
//  Smartlock
//
//  Created by RivenL on 15/5/22.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "KeysOfLockVC.h"

#import "SubTitleListCell.h"

#import "DeviceManager.h"
#import "RLColor.h"

#import "SendKeyWithABVC.h"

@implementation KeysOfLockVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"钥匙列表", nil);
}

- (void)setupRightItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送钥匙" style:UIBarButtonItemStylePlain target:self action:@selector(clickedRightItem:)];
}

- (void)setupLongPressGesture {

}

- (void)reloadTableData {
    // do nothing
}

- (void)clickedRightItem:(UIBarButtonItem *)item {
    SendKeyWithABVC *vc = [[SendKeyWithABVC alloc] init];
    vc.filterItems = self.table.datas;
    vc.title = NSLocalizedString(@"发送钥匙", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
- (void)loadKeysOfLockWithLockID:(NSUInteger)lockID {
    __weak __typeof(self)weakSelf = self;
    
    [RLHUD hudProgressWithBody:nil onView:self.view timeout:URLTimeoutInterval];
    [DeviceManager keyListOfAdmin:lockID token:[User sharedUser].sessionToken withBlock:^(DeviceResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [RLHUD hideProgress];
            if(!response.success || response.list.count == 0) {
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"加载失败!", nil)];
                return ;
            }
            if(weakSelf.table.datas.count) {
                [weakSelf.table.datas removeAllObjects];
            }
            
            [weakSelf.table.datas addObjectsFromArray:[response.list copy]];
            [weakSelf.table.tableView reloadData];
        });
    }];
}

#pragma mark -
- (void)setLockId:(NSUInteger)lockId {
    _lockId = lockId;
    
    [self loadKeysOfLockWithLockID:_lockId];
}

#pragma mark -
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubTitleListCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString *)kCellIdentifier];
    if(!cell) {
        cell = [[SubTitleListCell alloc] initWithReuseIdentifier:kCellIdentifier aClass:[UIButton class]];
        UIButton *button = (UIButton *)cell.contentAccessoryView;
        [button addTarget:self action:@selector(clickCellBtn:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [RLColor colorWithHex:0xFF7B00];//[UIColor blueColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    KeyModel *key = [self.table.datas objectAtIndex:indexPath.row];
    NSString *text = key.user.nickname.length ? [NSString stringWithFormat:@"%@ ( %@ )", key.user.phone, key.user.nickname] : [NSString stringWithFormat:@"%@", key.user.phone];
    cell.textLabel.text = text;//key.user.phone;
    if(key.type == kKeyTypeForever) {
        cell.detailTextLabel.text = @"永久";
    }
    else if(key.type == kKeyTypeTimes) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"还可使用%d次", (int)key.validCount];
    }
    else  {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"有效期%@", key.invalidDate];
    }
    cell.imageView.image = [UIImage imageNamed:@"KeyIcon"];

    UIButton *button = (UIButton *)cell.contentAccessoryView;
    button.tag = indexPath.row;
    if(!key.userType) {
        button.hidden = YES;
        return cell;
    }
    
    button.hidden = NO;
    button.tag = indexPath.row;
    button.enabled = YES;
    if(key.status == kKeyNormal) {
        [button setTitle:NSLocalizedString(@"冻结", nil) forState:UIControlStateNormal];
    }
    else if(key.status == kKeyFreeze) {
        [button setTitle:NSLocalizedString(@"解冻", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"无效", nil) forState:UIControlStateNormal];
        button.enabled = NO;
    }
    
    return cell;
}

- (void)clickCellBtn:(UIButton *)button {
    KeyModel *key = [self.table.datas objectAtIndex:button.tag];
    if(key.status != kKeyNormal && key.status != kKeyFreeze)
        return;
    button.enabled = NO;
    
    [DeviceManager lockOrUnlockKey:key.ID operation:!key.status token:[User sharedUser].sessionToken withBlock:^(DeviceResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            button.enabled = YES;
        });
        
        if(error || response.status) {
            return ;
        }
        
        key.status = !key.status;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!key.status) {
                [button setTitle:NSLocalizedString(@"冻结", nil) forState:UIControlStateNormal];
            }
            else {
                [button setTitle:NSLocalizedString(@"解冻", nil) forState:UIControlStateNormal];
            }
        });
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KeyModel *key = [self.table.datas objectAtIndex:indexPath.row];
    if(!key.userType) {
        
    }
}

@end
