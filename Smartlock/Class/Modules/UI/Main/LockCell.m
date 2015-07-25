//
//  LockCell.m
//  Smartlock
//
//  Created by RivenL on 15/5/8.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LockCell.h"

@implementation LockCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        self.textLabel.numberOfLines = 2;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    CGFloat widthOffset = 15;
    self.imageView.frame = CGRectMake(widthOffset, frame.size.height/2-35/2, 35, 35);
    
    frame = self.imageView.frame;
    widthOffset = frame.origin.x + frame.size.width + 15;
    self.textLabel.frame = CGRectMake(widthOffset, 0, self.textLabel.frame.size.width-widthOffset-15, self.contentView.frame.size.height);
    
    frame = self.textLabel.frame;
    widthOffset = self.textLabel.frame.origin.x+self.textLabel.frame.size.width + 10;
    self.detailTextLabel.frame = CGRectMake(widthOffset, self.detailTextLabel.frame.origin.y, self.contentView.frame.size.width-widthOffset-5, self.detailTextLabel.frame.size.height);
}
@end
