//
//  SubTitleListCell.h
//  Smartlock
//
//  Created by RivenL on 15/5/22.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "DefaultListCell.h"

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@interface SubTitleListCell : DefaultListCell
@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, readonly, weak) UIView *contentAccessoryView;
@property (nonatomic, readonly, weak) UILabel *badgeLabel;

@property (nonatomic, readonly, weak) UIView *separateView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier aClass:(Class)aClass;
@end
