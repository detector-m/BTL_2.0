//
//  RLABViewController.h
//  Smartlock
//
//  Created by RivenL on 15/8/6.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLTableViewController.h"

@interface RLABViewController : RLTableViewController {
    NSMutableDictionary *_abDictionary;
    NSMutableArray *_sectionTitles;
}
@property (nonatomic, weak) NSArray *filterItems;

@end
