//
//  CharacteristicsViewController.m
//  Smartlock
//
//  Created by RivenL on 15/3/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "CharacteristicsViewController.h"
#import "RLTable.h"
#import "RLCharacteristic.h"

#import "ExcuteVC.h"


@interface CharacteristicsViewController ()
@property (nonatomic, strong) RLTable *peripheralsTable;

@end

@implementation CharacteristicsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Characteristic", nil);
    
    self.peripheralsTable = [RLTable new];
    self.peripheralsTable.tableView = self.tableView;
    self.peripheralsTable.datas = [NSMutableArray arrayWithArray:self.service.characteristics];
    
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
    RLCharacteristic *characteristic = [self.peripheralsTable.datas objectAtIndex:indexPath.row];
    cell.textLabel.text = self.service.cbService.UUID.UUIDString;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"特征 UUID: %@(%@)", characteristic.cbCharacteristic.UUID.data, characteristic.cbCharacteristic.UUID];//characteristic.cbCharacteristic.UUID.UUIDString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   RLCharacteristic *characteristic = [self.peripheralsTable.datas objectAtIndex:indexPath.row];
    ExcuteVC *vc = [[ExcuteVC alloc] init];
    vc.ch = characteristic;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
