//
//  RLTableViewController.m
//  Smartlock
//
//  Created by RivenL on 15/6/15.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLTableViewController.h"

@interface RLTableViewController ()
@property (nonatomic, readwrite, strong) RLTable *table;

@end

@implementation RLTableViewController

- (void)dealloc {
    self.table = nil;
}

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        [self setupTable];
//    }
//    
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTable];
    [self setupBackItem:@"返回"];
    [self setupRightItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark -
- (void)setTableViewProperties {
    if(self.table.tableView == nil) {
        self.table.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        self.table.tableView.dataSource = self;
        self.table.tableView.delegate = self;
        [self.view addSubview:self.table.tableView];
    }
    
    self.table.tableView .showsHorizontalScrollIndicator = NO;
    self.table.tableView .showsVerticalScrollIndicator = NO;
    self.table.tableView .tableFooterView = [UIView new];
    self.table.tableView .rowHeight = 60;
    self.table.tableView .backgroundView = nil;
}

- (void)setupTable {
    if(!self.table) {
        self.table = [RLTable new];
        
        [self setTableViewProperties];
    }
}

- (void)setupBackItem:(NSString *)title {
    self.navigationItem.backBarButtonItem = [UIBarButtonItem new];
    [self.navigationItem.backBarButtonItem setTitle:NSLocalizedString(title, nil)];
}

- (void)setupRightItem {
    
}

#pragma mark -
- (void)deselectRow {
    self.table.tableView.userInteractionEnabled = NO;
    [self performSelector:@selector(deselectRow:) withObject:self.table.tableView afterDelay:0.5];
}


- (void)deselectRow:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    tableView.userInteractionEnabled = YES;
}

#pragma UITableViewDataSource and UITableViewDelegate
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
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
