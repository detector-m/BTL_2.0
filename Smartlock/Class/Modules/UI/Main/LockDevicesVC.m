//
//  LockDevicesVC.m
//  Smartlock
//
//  Created by RivenL on 15/3/23.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LockDevicesVC.h"
#import "AddDeviceVC.h"
#import "MainVC.h"
#import "SubTitleListCell.h"
#import "KeysOfLockVC.h"

#import "SCLAlertView.h"

#pragma mark -
#import "LockModel.h"
#import "DeviceManager.h"

#import "MyCoreDataManager.h"
#import "KeyEntity.h"
#import "RecordManager.h"

@interface LockDevicesVC () <UIAlertViewDelegate>
//@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) KeyModel *modifyKey;
@end

@implementation LockDevicesVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadTableData];
}

- (void)reloadTableData {
    [self.table.datas removeAllObjects];
    [self.table addObjectFromArray:[self.mainVC locks]];
    [self.table.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"My Devices", nil);
 
    self.table.tableView.rowHeight = 60.0f;
    [self setupLongPressGesture];
}

- (void)setupRightItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickRightItem)];
}


- (void)clickRightItem {
    if(![[RLBluetooth sharedBluetooth] bluetoothIsReady]) {
        [RLHUD hudAlertWaitingWithBody:NSLocalizedString(@"未开启蓝牙，请先开启蓝牙", nil)];
        
        return;
    }
    AddDeviceVC *vc = [AddDeviceVC new];
    vc.lockDevicesVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
- (void)showAlertView {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    UITextField *txt = [alert addTextField:@"请输入"];
    __weak __typeof(self)weakSelf = self;
    [alert addButton:NSLocalizedString(@"确定", nil) actionBlock:^(void) {
        if(!txt || txt.text.length == 0)
            return;
        
        [DeviceManager modifyKeyName:self.modifyKey.ID gid:self.modifyKey.ower token:[User sharedUser].sessionToken keyName:txt.text withBlock:^(DeviceResponse *response, NSError *error) {
            if(error) return ;
            if(response.status) {
                return;
            }
            self.modifyKey.name = txt.text;
            [[MyCoreDataManager sharedManager] insertUpdateObjectInObjectTable:keyEntityDictionaryFromKeyModel(self.modifyKey) updateOnExistKey:@"keyID" withTablename:NSStringFromClass([KeyEntity class])];
            [RLHUD hudAlertSuccessWithBody:NSLocalizedString(@"成功", nil)];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.table.tableView reloadData];
            });
        }];
    }];
    
    [alert showEdit:self title:NSLocalizedString(@"修改钥匙名", nil) subTitle:nil closeButtonTitle:NSLocalizedString(@"取消", nil) duration:0.0f];
    
}

- (void)setupLongPressGesture {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    gesture.minimumPressDuration = 1.0f;
    gesture.numberOfTouchesRequired = 1;
    [self.table.tableView addGestureRecognizer:gesture];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.table.tableView];
        NSIndexPath *indexPath = [self.table.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil)
            return;
        
        self.modifyKey = [self.table.datas objectAtIndex:indexPath.row];
        [self showAlertView];
    }
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.table.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubTitleListCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString *)kCellIdentifier];
    if(!cell) {
        cell = [[SubTitleListCell alloc] initWithReuseIdentifier:kCellIdentifier aClass:/*[UIButton class]*/NULL];
        UIButton *button = (UIButton *)cell.contentAccessoryView;
        [button addTarget:self action:@selector(clickCellBtn:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    KeyModel *key = [self.table.datas objectAtIndex:indexPath.row];
    cell.textLabel.text = key.name;
    if(key.type == kKeyTypeForever) {
        cell.detailTextLabel.text = @"永久";
    }
    else if(key.type == kKeyTypeTimes) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"还可使用%d次", (int)key.validCount];
    }
    else  {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"钥匙有效期限%@", key.invalidDate];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if(key.userType == kUserTypeAdmin) {
        cell.imageView.image = [UIImage imageNamed:@"LockIcon"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"KeyIcon"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(!key.userType) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
#if 0
    UIButton *button = (UIButton *)cell.contentAccessoryView;
    if(!key.userType) {
        button.hidden = YES;
        return cell;
    }
    
    button.hidden = NO;
    button.tag = indexPath.row;
    if(!key.status) {
        [button setTitle:NSLocalizedString(@"冻结", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"解冻", nil) forState:UIControlStateNormal];
    }
#endif
    
    return cell;
 }

- (void)clickCellBtn:(UIButton *)button {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectRow];
    KeyModel *key = [self.table.datas objectAtIndex:indexPath.row];
    if(!key.userType) {
        KeysOfLockVC *vc = [[KeysOfLockVC alloc] init];
        vc.lockId = key.lockID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     KeyModel *key = [self.table.datas objectAtIndex:indexPath.row];
     if(!key.userType)
         return NO;
     return YES;
 }

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     KeyModel *key = [self.table.datas objectAtIndex:indexPath.row];

     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         __weak __typeof(self)weakSelf = self;
         if(!key.userType)
             return;
         [DeviceManager deleteKey:key.ID token:[User sharedUser].sessionToken withBlock:^(DeviceResponse *response, NSError *error) {
             if(error || response.status) {
                 return ;
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.table.datas removeObjectAtIndex:indexPath.row];
                 [RecordManager removeRecordsWithKeyID:(long long)key.ID];
                 [weakSelf.mainVC removeKey:key];
                 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             });
         }];
         
     } else if (editingStyle == UITableViewCellEditingStyleInsert) {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
 }


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        if(!txt || txt.text.length == 0)
            return;
        
        [DeviceManager modifyKeyName:self.modifyKey.ID gid:self.modifyKey.ower token:[User sharedUser].sessionToken keyName:txt.text withBlock:^(DeviceResponse *response, NSError *error) {
            if(error) {
                DLog(@"%@", error);
                
                return ;
            }
            
            if(response.status) {
                return;
            }
            
        }];
    }
}

@end
