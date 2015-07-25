//
//  ListCell.h
//  Smartlock
//
//  Created by RivenL on 15/5/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DefaultListCell.h"

@interface ListCell : UITableViewCell
@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, readonly, weak) UILabel *timeLabel;
@property (nonatomic, readonly, weak) UILabel *badgeLabel;

@property (nonatomic, readonly, weak) UIView *separateView;
@end
