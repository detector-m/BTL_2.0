//
//  MessageCell.m
//  Smartlock
//
//  Created by RivenL on 15/5/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell
- (id)initWithMessage:(NotificationMessage *)message reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self setupForMessage:message];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat originX = AvaterPadding;
    CGRect frame = CGRectMake(originX, CellPadding, AvaterSize, AvaterSize);
    self.imageView.frame = frame;
    
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = self.imageView.frame.origin.y;
    
    bubbleFrame.origin.x = AvaterPadding * 2 + AvaterSize;
    self.bubbleView.frame = bubbleFrame;
}

#pragma mark -
- (void)setMessage:(NotificationMessage *)message {
    _message = message;
    
    UIImage *placeholderImage = [UIImage imageNamed:@"ListAvater"];
    self.imageView.image = placeholderImage;
    
    self.bubbleView.message = message;
    [self.bubbleView sizeToFit];
}

#pragma mark -
- (void)setupForMessage:(NotificationMessage *)model {
    self.imageView.frame = CGRectMake(0, CellPadding, AvaterSize, AvaterSize);
    
    self.bubbleView = [[TextBubbleView alloc] init];
    [self.contentView addSubview:self.bubbleView];
}

#pragma mark -
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NotificationMessage *)message {
    NSInteger bubbleHeight = [TextBubbleView heightForBubbleWithObject:message];
    NSInteger headHeight = AvaterPadding * 2 + AvaterSize;
    
    return MAX(headHeight, bubbleHeight) + CellPadding;
}
@end
