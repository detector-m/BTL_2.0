//
//  ServicesViewController.m
//  Smartlock
//
//  Created by RivenL on 15/3/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "ServicesViewController.h"
#import "RLTable.h"
#import "RLService.h"
#import "CharacteristicsViewController.h"

@interface ServicesViewController ()
@property (nonatomic, strong) RLTable *peripheralsTable;
@end

@implementation ServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Service", nil);
    
    self.peripheralsTable = [RLTable new];
    self.peripheralsTable.tableView = self.tableView;
    self.peripheralsTable.datas = [NSMutableArray arrayWithArray:self.peripheral.services];
    
    [self.peripheralsTable.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralsTable.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    RLService *service = [self.peripheralsTable.datas objectAtIndex:indexPath.row];
    cell.textLabel.text = self.peripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"服务 UUID: %@(%@)", service.cbService.UUID.data, service.cbService.UUID]; //service.cbService.UUID.UUIDString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CharacteristicsViewController *vc = [CharacteristicsViewController new];
    vc.service = [self.peripheralsTable.datas objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
