//
//  TextBubbleView.m
//  Smartlock
//
//  Created by RivenL on 15/5/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "TextBubbleView.h"

@interface TextBubbleView ()
@property (nonatomic, readwrite, strong) UILabel *textLabel;
@end

@implementation TextBubbleView
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.textLabel.font = [UIFont systemFontOfSize:TextFontSize];
        self.textLabel.backgroundColor = [UIColor clearColor];
//        self.textLabel.userInteractionEnabled = NO;
//        self.textLabel.multipleTouchEnabled = NO;
        [self addSubview:_textLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BubbleArrowWidth;
    frame = CGRectInset(frame, BubbleViewPadding, BubbleViewPadding);
    frame.origin.x = BubbleViewPadding + BubbleArrowWidth;
    
    frame.origin.y = BubbleViewPadding;
    
    [self.textLabel setFrame:frame];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize textBlockMinSize = {TextMaxWidth, CGFLOAT_MAX};
    CGSize retSize;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:TextLineSpace];//[[self class] lineSpacing]];//调整行间距
        
        retSize = [self.message.content boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TextFontSize], NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
    }
    else {
#ifdef __IPHONE_7_0
#else
        retSize = [self.message.content sizeWithFont:[UIFont systemFontOfSize:TextFontSize] constrainedToSize:textBlockMinSize lineBreakMode:NSLineBreakByCharWrapping];
#endif
    }
    
    CGFloat height = 40;
    if (2*BubbleViewPadding + retSize.height > height) {
        height = 2*BubbleViewPadding + retSize.height;
    }
    
    return CGSizeMake(retSize.width + BubbleViewPadding*2 + BubbleViewPadding, height);
}

#pragma mark -
- (void)setMessage:(NotificationMessage *)message {
    [super setMessage:message];
    
    self.textLabel.text = message.content;
}

#pragma mark -

+ (CGFloat)heightForBubbleWithObject:(NotificationMessage *)object {
    CGSize textBlockMinSize = {TextMaxWidth, CGFLOAT_MAX};
    CGSize size;
    static float systemVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    });
    
    if (systemVersion >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:TextLineSpace];//调整行间距
        size = [object.content boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TextFontSize], NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
    }
    else {
#ifdef __IPHONE_7_0
#else
        size = [object.content sizeWithFont:[UIFont systemFontOfSize:TextFontSize] constrainedToSize:textBlockMinSize lineBreakMode:NSLineBreakByCharWrapping];
#endif

    }
    
    return 2*BubbleViewPadding + size.height;
}

@end
