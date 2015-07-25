//
//  RLTitleTextField.m
//  Smartlock
//
//  Created by RivenL on 15/4/1.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLTitleTextField.h"

@interface RLTitleTextField ()
@property (nonatomic, readwrite, strong) UILabel *title;
@property (nonatomic, readwrite, strong) UITextField *textField;
@end

@implementation RLTitleTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.style = kRLTitleTextFieldHorizontal;
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, frame.size.width*0.3-2, frame.size.height-2)];
        self.title.textAlignment = NSTextAlignmentLeft;
        self.title.font = [UIFont systemFontOfSize:16];
        self.title.textColor = [UIColor blackColor];
        [self addSubview:self.title];
        
        CGFloat widthOffset = self.title.frame.origin.x + self.title.frame.size.width + 1;
        
        UITextField *tmp ;
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(widthOffset, 1, frame.size.width*0.7-2, frame.size.height-2)];
        tmp = self.textField;
        tmp.keyboardType = UIKeyboardTypeDefault;
        tmp.borderStyle = UITextBorderStyleRoundedRect;
        tmp.clearButtonMode = UITextFieldViewModeAlways;
        
        tmp.font = [UIFont systemFontOfSize:16];

        [self addSubview:self.textField];
    }
    
    return self;
}

- (void)setStyle:(RLTitleTextFieldStyle)style {
    if(_style == style) {
        return;
    }
    
    _style = style;
    CGRect frame = self.frame;
    if(style == kRLTitleTextFieldVertical) {
        self.title.frame = CGRectMake(1, 1, frame.size.width-2, frame.size.height*0.4);
        self.textField.frame = CGRectMake(0, self.title.frame.size.height+2, frame.size.width, frame.size.height-self.title.frame.size.height-2);
    }
    else {
        self.title.frame = CGRectMake(1, 1, frame.size.width*0.3-2, frame.size.height-2);
        CGFloat widthOffset = self.title.frame.origin.x + self.title.frame.size.width + 1;
        self.textField.frame = CGRectMake(widthOffset, 1, frame.size.width*0.7-2, frame.size.height-2);
    }
}

@end
