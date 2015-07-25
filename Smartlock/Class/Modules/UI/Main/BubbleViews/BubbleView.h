//
//  BubbleView.h
//  Smartlock
//
//  Created by RivenL on 15/5/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationMessage.h"

#define BubbleArrowWidth (5) // bubbleView中，箭头的宽度
#define BubbleViewPadding (8) // bubbleView 与 在其中的控件内边距

#define BubbleRightLeftCapWidth 5 // 文字在右侧时,bubble用于拉伸点的X坐标
#define BubbleRightTopCapHeight 35 // 文字在右侧时,bubble用于拉伸点的Y坐标

#define BubbleLeftLeftCapWidth 35 // 文字在左侧时,bubble用于拉伸点的X坐标
#define BubbleLeftTopCapHeight 35 // 文字在左侧时,bubble用于拉伸点的Y坐标


@interface BubbleView : UIView
@property (nonatomic, readonly, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) NotificationMessage *message;

+ (CGFloat)heightForBubbleWithObject:(NotificationMessage *)object;
@end
