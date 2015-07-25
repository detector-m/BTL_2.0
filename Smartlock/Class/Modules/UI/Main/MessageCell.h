//
//  MessageCell.h
//  Smartlock
//
//  Created by RivenL on 15/5/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NotificationMessage.h"
#import "TextBubbleView.h"

#define CellPadding BubbleViewPadding
#define AvaterSize (40)
#define AvaterPadding (5.0f)

@interface MessageCell : UITableViewCell
@property (nonatomic, weak) NotificationMessage *message;
@property (nonatomic, strong) TextBubbleView *bubbleView;

- (id)initWithMessage:(NotificationMessage *)message reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setupForMessage:(NotificationMessage *)model;

#pragma mark -
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NotificationMessage *)message;
@end
