//
//  TimeCell.m
//  Smartlock
//
//  Created by RivenL on 15/5/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "TimeCell.h"

#import "RLColor.h"

@implementation TimeCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [RLColor colorWithHex:0xC9C9C9];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.layer.cornerRadius = 10;
        self.textLabel.layer.masksToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

#define LabelWidth 80
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGRect frame = self.textLabel.frame;
    
    frame = CGRectMake((width-LabelWidth)/2, frame.origin.y+2, LabelWidth, frame.size.height-4);
    self.textLabel.frame = frame;
}
@end
