//
//  RLABViewController.m
//  Smartlock
//
//  Created by RivenL on 15/8/6.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLABViewController.h"
#import "RHAddressBook.h"
#import "RHPerson.h"
#import "pinyin.h"
#import "SubTitleListCell.h"
#import "RLColor.h"
#import "RLTableCellButton.h"


@interface RLABViewController ()
{
    RHAddressBook *_addressBook;
    
    NSMutableArray *_sectionTitlesSource;
}
@end

@implementation RLABViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RHAddressBook *ab = [[RHAddressBook alloc] init] ;
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined){
        __weak __typeof(self)weakSelf = self;
        [ab requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
            [weakSelf initData:ab];
        }];
    }
    
    
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通讯录提示" message:@"请在iPhone的[设置]->[隐私]->[通讯录]，允许群友通讯录访问你的通讯录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // warn re restricted access to contacts
    if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusRestricted){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通讯录提示" message:@"请在iPhone的[设置]->[隐私]->[通讯录]，允许群友通讯录访问你的通讯录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self initData:ab];
}

-(void)initData:(RHAddressBook *)ad {
    _addressBook = ad;
    _sectionTitles = [NSMutableArray array];
    NSString *regex = @"^[A-Za-z]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *people = [_addressBook peopleOrderedByUsersPreference];
        for (RHPerson *person in people) {
            NSString *c = [[person.name substringToIndex:1] uppercaseString];
            if ([predicate evaluateWithObject:c]) {
                [person setFirstNamePhonetic:c];
            }
            else {
                NSString *alpha = [[NSString stringWithFormat:@"%c", pinyinFirstLetter([person.name characterAtIndex:0])] uppercaseString];
                [person setFirstNamePhonetic:alpha];
            }
        }
        
        NSArray *sortedArray;
        sortedArray = [people sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                           NSString *first = [(RHPerson*)a firstNamePhonetic];
                           NSString *second = [(RHPerson*)b firstNamePhonetic];
                           return [first compare:second];
                       }];
        
        NSMutableDictionary *sectionDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        for (RHPerson *person in sortedArray) {
            NSString *spellKey = person.firstNamePhonetic;
            if ([sectionDict objectForKey:spellKey]) {
                NSMutableArray *currentSecArray = [sectionDict objectForKey:spellKey];
                [currentSecArray addObject:person];
            }
            else {
                [_sectionTitles addObject:spellKey];
                NSMutableArray *currentSecArray = [[NSMutableArray alloc] initWithCapacity:0];
                [currentSecArray addObject:person];
                [sectionDict setObject:currentSecArray forKey:spellKey];
            }
        }
        
        _abDictionary = sectionDict;
        
        //索引数组
        _sectionTitlesSource = [[NSMutableArray alloc] init] ;
        for(char c = 'A'; c <= 'Z'; c++ ) {
            [_sectionTitlesSource addObject:[NSString stringWithFormat:@"%c",c]];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            [self.table.tableView reloadData];
        });
    });
}

#pragma mark tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionTitles.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (view == nil) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
    }
    NSString *key = [_sectionTitles objectAtIndex:section];
    view.textLabel.text = key;
    return view;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionTitlesSource;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger count = 0;
    for(NSString *character in _sectionTitles) {
        if([character isEqualToString:title]) {
            return count;
        }
        count ++;
    }
    return count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sectionTitles objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [_sectionTitles objectAtIndex:section];
    NSArray *keyArray = [_abDictionary objectForKey:key];
    return keyArray.count;
}

- (BOOL)isInFilterItems:(id)testItem {
    if(testItem == nil)
        return NO;
    if(_filterItems.count == 0)
        return NO;
    
//    for(id item in _filterItems) {
//        
//    }
    
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
    button.hidden = NO;
    button.enabled = YES;
    button.indexPath = indexPath;
    [button setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    
    return cell;
}

- (void)clickCellBtn:(RLTableCellButton *)button {
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#if 0
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //TODO: push our own viewer view, for now just use the AB default one.
    NSString *alpha     = [friendAplha objectAtIndex:indexPath.section];
    NSArray *alphaArray = [friendDictionary objectForKey:alpha];
    RHPerson *person    = [alphaArray objectAtIndex:indexPath.row];
    
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    
    //setup (tell the view controller to use our underlying address book instance, so our person object is directly updated)
    [person.addressBook performAddressBookAction:^(ABAddressBookRef addressBookRef) {
        personViewController.addressBook =addressBookRef;
    } waitUntilDone:YES];
    
    personViewController.displayedPerson = person.recordRef;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
    personViewController.allowsActions = YES;
#endif
    personViewController.allowsEditing = YES;
    
    
    [self.navigationController pushViewController:personViewController animated:YES];
#endif
}
@end
