//
//  RLTitleTextField.h
//  Smartlock
//
//  Created by RivenL on 15/4/1.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RLTitleTextFieldStyle) {
    kRLTitleTextFieldVertical,
    kRLTitleTextFieldHorizontal,
};
@interface RLTitleTextField : UIView
@property (nonatomic, readonly, strong) UILabel *title;
@property (nonatomic, readonly, strong) UITextField *textField;

@property (nonatomic, assign) RLTitleTextFieldStyle style;
@end
