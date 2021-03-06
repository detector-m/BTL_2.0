//
//  SystemSettingVC.m
//  Smartlock
//
//  Created by RivenL on 15/6/24.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "SystemSettingVC.h"

@interface SystemSettingVC ()
@property (nonatomic, strong) UISwitch *voiceSwitch;

@property (nonatomic, strong) UISwitch *autoOpenlockSwitch;

@property (nonatomic, strong) UISwitch *openlockTypeSwitch;

@property (nonatomic, strong) UIView *footerForTableView;
@end

@implementation SystemSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"设置", nil);
    
    self.table.tableView.rowHeight = 60.0f;
    
    [self.table.datas addObject:@"声音"];
    [self.table.datas addObject:@"自动开锁"];
//    BOOL bBoice = [User getAutoOpenLockSwitch];
//    if(bBoice) {
//        if(self.table.datas.count <= 2) {
//            [self.table.datas addObject:@"家用锁"];
//        }
//    }
    
    self.table.tableView.tableFooterView = [self footerViewForTableView];
    [self.table.tableView reloadData];
}

#pragma mark -
- (UISwitch *)voiceSwitch {
    if(_voiceSwitch) {
        return _voiceSwitch;
    }
    
    _voiceSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 15, 60, 30)];
    BOOL bBoice = [User getVoiceSwitch];
    [_voiceSwitch setSelected:bBoice];
    _voiceSwitch.on = !bBoice;
    [_voiceSwitch addTarget:self action:@selector(voiceSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    return _voiceSwitch;
}

- (void)voiceSwitchChanged:(UISwitch *)voiceSwitch {
    BOOL bBoice = !_voiceSwitch.selected;
    [_voiceSwitch setSelected:bBoice];
    [User setVoiceSwitch:bBoice];
}

- (UISwitch *)autoOpenlockSwitch {
    if(_autoOpenlockSwitch) {
        return _autoOpenlockSwitch;
    }
    
    _autoOpenlockSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 15, 60, 30)];
    BOOL bBoice = [User getAutoOpenLockSwitch];
    [_autoOpenlockSwitch setSelected:bBoice];
    _autoOpenlockSwitch.on = !bBoice;
    [_autoOpenlockSwitch addTarget:self action:@selector(autoOpenlockSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    return _autoOpenlockSwitch;
}

- (void)autoOpenlockSwitchChanged:(UISwitch *)aSwitch {
    BOOL bBoice = !_autoOpenlockSwitch.selected;
    [_autoOpenlockSwitch setSelected:bBoice];
    [User setAutoOpenLockSwitch:bBoice];
    
    [User setOpenLockTypeSwitch:NO];
    
//    if(bBoice) {
//        if(self.table.datas.count <= 2) {
//            [self.table.datas addObject:@"家用锁"];
//        }
//    }
//    else {
//        if(self.table.datas.count > 2) {
//            [self.table.datas removeLastObject];
//        }
//    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.table.tableView reloadData];
    }];
}

- (UISwitch *)openlockTypeSwitch {
    if(_openlockTypeSwitch) {
        return _openlockTypeSwitch;
    }
    _openlockTypeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 15, 60, 30)];
    BOOL bBoice = [User getOpenLockTypeSwitch];
    [_openlockTypeSwitch setSelected:bBoice];
    _openlockTypeSwitch.on = !bBoice;
    [_openlockTypeSwitch addTarget:self action:@selector(openlockTypeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    return _openlockTypeSwitch;
}

- (void)openlockTypeSwitchChanged:(UISwitch *)aSwitch {
    BOOL bBoice = !_openlockTypeSwitch.selected;
    [_openlockTypeSwitch setSelected:bBoice];
    [User setOpenLockTypeSwitch:bBoice];
}

#pragma mark -
- (UIView *)footerViewForTableView {
    if(self.footerForTableView)
        return self.footerForTableView;
    
    CGRect frame = self.table.tableView.frame;
    UIView *lineview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
    lineview.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat height = 165;
    self.footerForTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
    self.footerForTableView.backgroundColor = [UIColor clearColor];
    frame = self.footerForTableView.frame;
    UILabel *licenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, frame.size.width-10, height)];
    licenceLabel.numberOfLines = 0;
    licenceLabel.textAlignment = NSTextAlignmentLeft;
    licenceLabel.text = @"开锁模式为自动时：\n\t1 打开APP登陆并进入APP主界面  \n\t2 触摸锁设备开关 ，后将自动开锁；\n开锁模式为手动时：\n\t1 打开APP登陆并进入APP主界面   \n\t2 点击APP主界面开锁图标  \n\t3 触摸锁设备开关 ，后将自动开锁  \n\t4 当手动开锁模式时，可选择家用开锁类型，或者常开常闭类型，开关打开为家用型，关闭时为常开常闭。当为常开常闭时，点击常开开关将开门且不会自动反锁，只有点击常关开关后才会进行反锁。";
    licenceLabel.font = [UIFont systemFontOfSize:13];
    licenceLabel.textColor = [UIColor blueColor];
    [self.footerForTableView addSubview:licenceLabel];
    [self.footerForTableView addSubview:lineview];
    return self.footerForTableView;
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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
    [tableView registerClass:[DefaultListCell class] forCellReuseIdentifier:kCellIdentifier];
    DefaultListCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString *)kCellIdentifier forIndexPath:indexPath];
    NSInteger index = [self indexForData:indexPath];
    cell.textLabel.text = [self.table.datas objectAtIndex:index];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == 0) {
        [self.voiceSwitch removeFromSuperview];
    
        [cell.contentView addSubview:self.voiceSwitch];
        cell.imageView.image = [UIImage imageNamed:@"Voice.png"];
    }
    else if(indexPath.row == 1) {
        [self.autoOpenlockSwitch removeFromSuperview];
        
        [cell.contentView addSubview:self.autoOpenlockSwitch];
        cell.imageView.image = [UIImage imageNamed:@"LockIcon.png"];
    }
//    else if(indexPath.row == 2) {
//        [self.openlockTypeSwitch removeFromSuperview];
//        [cell.contentView addSubview:self.openlockTypeSwitch];
//        cell.imageView.image = [UIImage imageNamed:@"LockIcon.png"];
//    }
    
    return cell;
}
@end
