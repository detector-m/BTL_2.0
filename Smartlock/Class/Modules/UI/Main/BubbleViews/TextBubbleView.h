//
//  TextBubbleView.h
//  Smartlock
//
//  Created by RivenL on 15/5/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BubbleView.h"

#define TextMaxWidth 220 // textLaebl 最大宽度
#define TextFontSize 14      // 文字大小
#define TextLineSpace 0       // 行间距

@interface TextBubbleView : BubbleView
@property (nonatomic, readonly, strong) UILabel *textLabel;

+ (CGFloat)heightForBubbleWithObject:(NotificationMessage *)object;
@end
