//
//  AudioCell.m
//  Smartlock
//
//  Created by RivenL on 15/8/27.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "AudioCell.h"

@implementation AudioCell
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setDefaultProperties];
        _audioPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _audioPlayBtn.frame = CGRectMake(1, 0, ImageViewSize, ImageViewSize);
        [_audioPlayBtn setImage:[UIImage imageNamed:@"AudioPlay.png"] forState:UIControlStateNormal];
        [_audioPlayBtn setImage:[UIImage imageNamed:@"AudioStop.png"] forState:UIControlStateSelected];
        [self.contentView addSubview:_audioPlayBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    CGFloat xOffset = (frame.size.height-ImageViewSize)/2;
    CGFloat yOffset = self.textLabel.frame.origin.y;
    CGFloat width = 0;
    CGFloat height = 0;
    
    self.imageView.frame = CGRectZero;
    _audioPlayBtn.frame = CGRectMake(xOffset, xOffset, ImageViewSize, ImageViewSize);
    
    xOffset = self.audioPlayBtn.frame.origin.x + self.audioPlayBtn.frame.size.width + Space;
    width = frame.size.width - xOffset - Space*2;
    height = self.textLabel.frame.size.height;//(contentHeight-yOffset*2 - 2)/2;
    self.textLabel.frame = CGRectMake(xOffset, yOffset, width, height);
}
@end
