//
//  SendKeyWithABVC.m
//  Smartlock
//
//  Created by RivenL on 15/8/6.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "SendKeyWithABVC.h"
#import "SubTitleListCell.h"
#import "RLTableCellButton.h"
#import "RLColor.h"
#import "KeyModel.h"

#import "SendKeyVC.h"

#import "RHAddressBook.h"
#import "RHPerson.h"

@interface SendKeyWithABVC ()

@end

@implementation SendKeyWithABVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)isInFilterItems:(id)testItem text:(NSString **)text {
    NSString *itemString = (NSString *)testItem;
    if(text) {
        *text = NSLocalizedString(@"发送", nil);
    }
    
    if(testItem == nil)
        return NO;
    if(self.filterItems.count == 0)
        return NO;

    if([itemString hasPrefix:@"+"]) {
        itemString = [itemString substringFromIndex:4];
    }
    itemString = [itemString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if(![itemString isMobile]) {
        if(text) {
            *text = NSLocalizedString(@"不可用", nil);
        }
        return YES;
    }
    
    for(KeyModel *key in self.filterItems) {
        if([key.user.phone isEqualToString:itemString]) {
            if(text) {
                *text = NSLocalizedString(@"已存在", nil);
            }
            return YES;
        }
    }
    
    return NO;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubTitleListCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString *)kCellIdentifier];
    if(!cell) {
        cell = [[SubTitleListCell alloc] initWithReuseIdentifier:kCellIdentifier aClass:[RLTableCellButton class]];
        UIButton *button = (RLTableCellButton *)cell.contentAccessoryView;
        [button addTarget:self action:@selector(clickCellBtn:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [RLColor colorWithHex:0xFF7B00];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *alpha     = [_sectionTitles objectAtIndex:indexPath.section];
    NSArray *alphaArray = [_abDictionary objectForKey:alpha];
    RHPerson *person    = [alphaArray objectAtIndex:indexPath.row];
    person.firstNamePhonetic = @"";
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = [person.phoneNumbers valueAtIndex:0];
    cell.imageView.image = person.thumbnail?:[UIImage imageNamed:@"ListAvater.png"];
    
    RLTableCellButton *button = (RLTableCellButton *)cell.contentAccessoryView;
    button.indexPath = indexPath;
    NSString *btnTitle = nil;
    if([self isInFilterItems:[person.phoneNumbers valueAtIndex:0] text:&btnTitle]) {
        button.enabled = NO;
    }
    else {
        button.hidden = NO;
        button.enabled = YES;
    }
    [button setTitle:btnTitle forState:UIControlStateNormal];
    
    return cell;
}

- (void)clickCellBtn:(RLTableCellButton *)button {
    NSIndexPath *indexPath = button.indexPath;
    
    NSString *alpha     = [_sectionTitles objectAtIndex:indexPath.section];
    NSArray *alphaArray = [_abDictionary objectForKey:alpha];
    RHPerson *person    = [alphaArray objectAtIndex:indexPath.row];
    person.firstNamePhonetic = @"";
    NSString *phone = [person.phoneNumbers valueAtIndex:0];
    
    NSString *lockIDString = [RLTypecast integerToString:self.lockId];
    
    SendKeyVC *vc = [[SendKeyVC alloc] init];
    vc.lockID = lockIDString;
    
    if([phone hasPrefix:@"+"]) {
        phone = [phone substringFromIndex:4];
    }
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if(![phone isMobile]) {
        phone = nil;
    }
    vc.phone = phone;
    
    [self.navigationController pushViewController:vc animated:YES];
}
@end
