//
//  BubbleView.m
//  Smartlock
//
//  Created by RivenL on 15/5/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BubbleView.h"

@interface BubbleView ()
@property (nonatomic, readwrite, weak) UIImageView *backgroundImageView;
@end

@implementation BubbleView
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        self.backgroundImageView = imageView;
    }
    
    return self;
}

- (void)setMessage:(NotificationMessage *)message {
    _message = message;
    
    self.backgroundImageView.image = [[UIImage imageNamed:@"ReceiverBg.png"] stretchableImageWithLeftCapWidth:BubbleLeftLeftCapWidth topCapHeight:BubbleLeftTopCapHeight];
}

+ (CGFloat)heightForBubbleWithObject:(NotificationMessage *)object {
    return 30.0;
}
@end
