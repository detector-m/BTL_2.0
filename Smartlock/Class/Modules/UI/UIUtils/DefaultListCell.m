//
//  DefaultListCell.m
//  Smartlock
//
//  Created by RivenL on 15/5/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "DefaultListCell.h"

NSString *kCellIdentifier = @"cellIdentifier";

@implementation DefaultListCell
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setDefaultProperties];
    }
    return self;
}

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    if (![self.badgeLabel isHidden]) {
//        self.badgeLabel.backgroundColor = [UIColor redColor];
//    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
//    if (![self.badgeLabel isHidden]) {
//        self.badgeLabel.backgroundColor = [UIColor redColor];
//    }
}

#pragma mark - 
- (void)setDefaultProperties {
    self.textLabel.font = [UIFont systemFontOfSize:16.0f];
//    self.imageView.frame = CGRectMake(0, 0, 35, 35);
//    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    CGFloat xOffset = 10;
    CGFloat yOffset = self.textLabel.frame.origin.y;
    CGFloat width = 0;
    CGFloat height = 0;
    
    self.imageView.frame = CGRectMake(xOffset, xOffset, ImageViewSize, ImageViewSize);
    
    xOffset = self.imageView.frame.origin.x + self.imageView.frame.size.width + Space;
    width = frame.size.width - xOffset - Space*2;
    height = self.textLabel.frame.size.height;//(contentHeight-yOffset*2 - 2)/2;
    self.textLabel.frame = CGRectMake(xOffset, yOffset, width, height);
}
@end
