//
//  BaseVC.h
//  Smartlock
//
//  Created by RivenL on 15/3/17.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLBaseViewController.h"

@interface BaseVC : RLBaseViewController
@property (nonatomic, readonly, weak) UIImageView *backgroundImage;

- (void)setNavigationBar;

- (void)setupBackItem;
- (void)setupRightItem;

- (void)setBackButtonHide:(BOOL)hide;

#pragma mark -
- (void)endEditing;

@end
