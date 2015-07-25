//
//  RLAlertLabel.m
//  Smartlock
//
//  Created by RivenL on 15/6/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLAlertLabel.h"
#import "RLColor.h"
#import "RLImage.h"

#define BackgroundColor (0x000000)

@interface AlertLabel : UILabel

@end

@implementation AlertLabel
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {5, 10, 0, 5};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end

@interface RLAlertLabel ()
@property (nonatomic, strong) AlertLabel *alertLabel;
@property (nonatomic, strong) UIButton *closeButton;
@end
@implementation RLAlertLabel

static UIImage *closeButtonImage;
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        self.alertLabel = [[AlertLabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
        self.alertLabel.backgroundColor = [UIColor colorWithRed:0.03 green:0.03 blue:0.03 alpha:0.8];//[RLColor colorWithHex:BackgroundColor];
        self.alertLabel.layer.cornerRadius = 6.0f;
        self.alertLabel.clipsToBounds = YES;
        self.alertLabel.numberOfLines = 0;
        self.alertLabel.font = [UIFont systemFontOfSize:15];
        self.alertLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.alertLabel];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.frame = CGRectMake(frame.size.width-30, -2, 32, 32);
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            closeButtonImage = [RLImage closeButtonImageWithFrame:self.closeButton.frame];
        });
        [self.closeButton setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
    }
    
    return self;
}

- (void)clickedCloseButton:(UIButton *)button {
    self.hidden = YES;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.alertLabel.frame = CGRectMake(5, 5, frame.size.width-10, frame.size.height-10);
    self.closeButton.frame = CGRectMake(frame.size.width-30, -2, 32, 32);
}
#pragma mark - 
static RLAlertLabel *alert = nil;
+ (void)showInView:(UIView *)view withText:(NSString *)text andFrame:(CGRect)frame {
    if(!alert) {
        alert = [[RLAlertLabel alloc] initWithFrame:frame];
        alert.alertLabel.text = text;
        alert.frame = frame;

        [view addSubview:alert];
    }
    else {
        alert.hidden = NO;
        if(alert.superview == view) {
            alert.alertLabel.text = text;
            alert.frame = frame;
        }
        else {
            [alert removeFromSuperview];
            [view addSubview:alert];
        }
    }
}
@end
