//
//  ProfileVC.m
//  Smartlock
//
//  Created by RivenL on 15/5/5.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "ProfileVC.h"
#import "RLTable.h"
#import "ResetPasswordVC.h"
#import "ModifierVC.h"

#import "Login.h"

#pragma mark -
#import "XMPPManager.h"

@interface ProfileCell : UITableViewCell

@end

@implementation ProfileCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont systemFontOfSize:18.0f];
        self.detailTextLabel.font = self.textLabel.font;
    }
    
    return self;
}
@end

@interface ProfileVC ()
@property (nonatomic) UIView *footer;
@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"我的资料", nil);
    [self setupBackItem:NSLocalizedString(@"取消", nil)];
    self.table.tableView.tableFooterView = self.footer;
    
    [self.table.datas addObject:@"昵称"];
    [self.table.datas addObject:@"账户名"];
    [self.table.datas addObject:@"更改密码"];
}

#pragma mark -
#define FooterHeight (100.0f)
- (UIView *)footer {
    if(!_footer) {
        
        CGRect frame = self.view.frame;
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 100.0f)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        frame = _footer.frame;
        button.frame = CGRectMake(50, frame.size.height/2 - 20, frame.size.width-100, 40);
        [button setTitle:NSLocalizedString(@"退出登录", nil)forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickLogoutBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_footer addSubview:button];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(16, 0, frame.size.width-16, .5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_footer addSubview:lineView];
    }
    
    return _footer;
}

- (void)clickLogoutBtn:(UIButton *)button {
//    __weak __typeof(self)weakSelf = self;
    [Login logout];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2;
        case 1: return 1;
        default: return 0;
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
    [tableView registerClass:[ProfileCell class] forCellReuseIdentifier:kCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString *)kCellIdentifier forIndexPath:indexPath];
    NSInteger index = [self indexForData:indexPath];
    cell.textLabel.text = [self.table.datas objectAtIndex:index];
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            cell.detailTextLabel.text = [User sharedUser].nickname;
        }
        else {
            cell.detailTextLabel.text = [User sharedUser].phone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectRow];
    NSInteger index = [self indexForData:indexPath];
    
    switch (indexPath.section) {
        case 0: {
            if(indexPath.row == 0) {
                ModifierVC *vc = [[ModifierVC alloc] init];
                vc.vc = self;
                vc.title = NSLocalizedString([self.table.datas objectAtIndex:index], nil);
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case 1:
        default:
        {
            ResetPasswordVC *vc = [[ResetPasswordVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}
@end
