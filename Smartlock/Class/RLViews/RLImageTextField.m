//
//  RLImageTextField.m
//  Smartlock
//
//  Created by RivenL on 15/3/31.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLImageTextField.h"

@interface RLImageTextField ()
@property (nonatomic, readwrite, weak) UIImageView *icon;
@property (nonatomic, readwrite, weak) UITextField *textField;
@end

@implementation RLImageTextField
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(3, 3, (frame.size.height-6), frame.size.height-6);
        [self addSubview:imageView];
        self.icon = imageView;
        
        CGFloat widthOffset = imageView.frame.origin.x+frame.size.height-3;
        UITextField *txtField = [UITextField new];
        txtField.keyboardType = UIKeyboardTypeDefault;
        txtField.clearButtonMode = UITextFieldViewModeAlways;
        txtField.frame = CGRectMake(widthOffset, 3, frame.size.width-widthOffset-3, frame.size.height-6);
        [self addSubview:txtField];
        self.textField = txtField;
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

@end
