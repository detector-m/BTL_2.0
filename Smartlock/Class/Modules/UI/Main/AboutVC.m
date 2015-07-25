//
//  AboutVC.m
//  Smartlock
//
//  Created by RivenL on 15/6/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "AboutVC.h"
#import "RLColor.h"

#import "MoreDetailVC.h"
#import "RLHTTPAPIClient.h"

@interface AboutVC ()
@property (nonatomic, strong) UIView *headerForTableView;
@property (nonatomic, strong) UIView *footerForTableView;
@end

@implementation AboutVC
//#if __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"关于我们", nil);
    self.view.backgroundColor = [RLColor colorWithHex:0xF0F4F8 alpha:1.0];//[UIColor lightGrayColor];
    self.table.tableView.backgroundColor = [UIColor clearColor];
    
    [self.table.datas addObject:@"公司名称"];
    [self.table.datas addObject:@"隐私政策"];
    [self.table.datas addObject:@"致谢"];
    
    self.table.tableView.tableHeaderView = [self headerViewForTableView];
    self.table.tableView.tableFooterView = [self footerViewForTableView];
    [self.table.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#define IconSize 80
#define HeaderViewHeight 180
#define VersionLabelHeigh 25

- (UIView *)headerViewForTableView {
    if(self.headerForTableView)
        return self.headerForTableView;
    
    CGRect frame = self.table.tableView.frame;
    self.headerForTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, HeaderViewHeight)];
    self.headerForTableView.backgroundColor = [UIColor clearColor];
    
    frame = self.headerForTableView.frame;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-IconSize)/2, (frame.size.height-IconSize-VersionLabelHeigh)/2, IconSize, IconSize)];
    imageView.image = [UIImage imageNamed:@"AboutIcon.png"];
    imageView.layer.cornerRadius = 10.0f;
    imageView.clipsToBounds = YES;
    [self.headerForTableView addSubview:imageView];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    CGFloat offsetY = imageView.frame.origin.y + IconSize + 8;
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width-IconSize)/2, offsetY, IconSize, VersionLabelHeigh)];
    versionLabel.font = [UIFont systemFontOfSize:16];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    NSString *versionString = [NSString stringWithFormat:@"v %@", version];
    versionLabel.text = versionString;//NSLocalizedString(@"hello", nil);
    [self.headerForTableView addSubview:versionLabel];
    
    return self.headerForTableView;
}

- (UIView *)footerViewForTableView {
    if(self.footerForTableView)
        return self.footerForTableView;
    
    CGRect frame = self.table.tableView.frame;
    CGFloat height = self.table.datas.count * self.table.tableView.rowHeight;
    height = frame.size.height - self.headerForTableView.frame.size.height - height;
    self.footerForTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
    self.footerForTableView.backgroundColor = [UIColor clearColor];
    frame = self.footerForTableView.frame;
    UILabel *licenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, frame.size.height-45, frame.size.width-10, 40)];
    licenceLabel.numberOfLines = 2;
    licenceLabel.textAlignment = NSTextAlignmentCenter;
    licenceLabel.text = @"Copyright © 2015 Yong Jia Ke Ji. All rights reserved.";
    licenceLabel.font = [UIFont systemFontOfSize:13];
    [self.footerForTableView addSubview:licenceLabel];
    return self.footerForTableView;
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.table.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aboutCell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"aboutCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.table.datas objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if(indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *displayname = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        cell.detailTextLabel.text = displayname;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectRow];
    if(!self.table.datas.count) return;
    if(indexPath.row == 0) {
        return;
    }
    MoreDetailVC *vc = [MoreDetailVC new];
    if(indexPath.row == 1) {
        vc.url = [kRLHTTPMobileBaseURLString stringByAppendingString:@"privacy.jsp"];//kAboutWebUrl;
        vc.title = NSLocalizedString(@"隐私政策", nil);
    }
    else {
        vc.url = [kRLHTTPMobileBaseURLString stringByAppendingString:@"excuse.jsp"];//kAboutWebUrl;
        vc.title = NSLocalizedString(@"致谢", nil);
    }
    [self.navigationController pushViewController:vc animated:YES];
}

@end
