//
//  SubTitleListCell.m
//  Smartlock
//
//  Created by RivenL on 15/5/22.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "SubTitleListCell.h"
#import "RLColor.h"

#define ButtonWidth 60
#define ButtonHeight 35

@interface SubTitleListCell ()
@property (nonatomic, readwrite, weak) UIView *contentAccessoryView;
@property (nonatomic, readwrite, weak) UILabel *badgeLabel;
@property (nonatomic, readwrite, weak) UIView *separateView;

@property (nonatomic) Class contentAccessoryViewClass;
@end

@implementation SubTitleListCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier aClass:(Class)aClass {
    self.contentAccessoryViewClass = aClass;
    return [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        if(self.contentAccessoryViewClass != NULL) {
            UIView *tempView = nil;
            if(self.contentAccessoryViewClass == [UIView class]) {
                tempView = [[UIView alloc] initWithFrame:CGRectMake(240, 7, TimeLabelWidth, TimeLabelHeight)];
                tempView.backgroundColor = [UIColor clearColor];
            }
            else if(self.contentAccessoryViewClass == [UILabel class]) {
                tempView = [[UILabel alloc] initWithFrame:CGRectMake(240, 7, TimeLabelWidth, TimeLabelHeight)];
                ((UILabel *)tempView).textAlignment = NSTextAlignmentCenter;
                ((UILabel *)tempView).font = [UIFont systemFontOfSize:13];
                ((UILabel *)tempView).backgroundColor = [UIColor clearColor];
            }
            else if(self.contentAccessoryViewClass == [UIButton class]) {
                tempView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                tempView.frame = CGRectMake(240, 7, ButtonWidth, ButtonHeight);
                UIButton *button = (UIButton *)tempView;
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                button.backgroundColor = [RLColor colorWithHex:0xFF7B00];
                button.layer.cornerRadius = 10;
            }
            
            if(tempView) {
                [self.contentView addSubview:tempView];
                self.contentAccessoryView = tempView;
            }
        }
        
        UILabel *tempLabel;
        tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, BadgeLabelWidth, BadgeLabelHeight)];
        tempLabel.backgroundColor = [UIColor redColor];
        tempLabel.textColor = [UIColor whiteColor];
        
        tempLabel.textAlignment = NSTextAlignmentCenter;
        tempLabel.font = [UIFont systemFontOfSize:11];
        tempLabel.layer.cornerRadius = 10;
        tempLabel.clipsToBounds = YES;
        [self.contentView addSubview:tempLabel];
        self.badgeLabel = tempLabel;
        self.badgeLabel.hidden = YES;
        
        UIView *tempView = nil;
        tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
        tempView.backgroundColor = [UIColor clearColor];//RGBACOLOR(207, 210, 213, 0.7);
        [self.contentView addSubview:tempView];
        self.separateView = tempView;
        self.separateView.hidden = YES;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (![self.badgeLabel isHidden]) {
        self.badgeLabel.backgroundColor = [UIColor redColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (![self.badgeLabel isHidden]) {
        self.badgeLabel.backgroundColor = [UIColor redColor];
    }
}

#pragma mark -
- (void)setDefaultProperties {
    self.textLabel.font = [UIFont systemFontOfSize:16.0f];
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    CGFloat contentWidth = frame.size.width;
    CGFloat contentHeight = frame.size.height;
    CGFloat xOffset = 10;
    CGFloat yOffset = (frame.size.height-ImageViewSize)/2;
    CGFloat width = 0;
    CGFloat height = 0;
    
    self.imageView.frame = CGRectMake(xOffset, xOffset, ImageViewSize, ImageViewSize);
    
    xOffset = self.imageView.frame.origin.x + self.imageView.frame.size.width - Space;
    self.badgeLabel.frame = CGRectMake(xOffset, 2, BadgeLabelWidth, BadgeLabelHeight);
    
    if(self.contentAccessoryViewClass == [UIButton class]) {
        xOffset = contentWidth - Space - ButtonWidth;
        width = ButtonWidth;
        height = ButtonHeight;
    }
    else {
        xOffset = contentWidth - Space - TimeLabelWidth;
        width = TimeLabelWidth;
        height = TimeLabelHeight;
    }
    self.contentAccessoryView.frame = CGRectMake(xOffset, yOffset, width, height);
    
    xOffset = self.imageView.frame.origin.x + self.imageView.frame.size.width + Space + self.badgeLabel.frame.size.width;
    width = frame.size.width - xOffset - Space*2 - self.contentAccessoryView.frame.size.width;
    height = (contentHeight-yOffset*2 - 2)/2;
    self.textLabel.frame = CGRectMake(xOffset, yOffset, width, height);
    
    yOffset += self.textLabel.frame.size.height + Space;
    width = frame.size.width - xOffset - Space;
    self.detailTextLabel.frame = CGRectMake(xOffset, yOffset, width, height);
}
@end
