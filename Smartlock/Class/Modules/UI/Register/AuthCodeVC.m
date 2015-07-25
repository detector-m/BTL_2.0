//
//  AuthCodeVC.m
//  Smartlock
//
//  Created by RivenL on 15/3/31.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "AuthCodeVC.h"
#import "RLColor.h"
#import "RLImageTextField.h"
#import "UIViewController+Expand.h"
#import "SetPasswordVC.h"

#define LabelTextColor (0x0F6797)
#define ButtonBackgroundColor (0x399ACA)

@interface AuthCodeVC ()
@property (nonatomic, strong) UILabel *authcodeLabel;
@property (nonatomic, strong) RLImageTextField *phoneTextField;
@property (nonatomic, strong) UITextField *authcodeTextField;
@property (nonatomic, strong) UIButton *authcodeButton;
@property (nonatomic, strong) UIButton *nextButton;
@end

@implementation AuthCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backgroundImage removeFromSuperview];
    self.title = NSLocalizedString(@"手机验证码", nil);
    [self setupForDismissKeyboard];
    
    CGRect frame = self.view.frame;
    CGFloat widthOffset = 20.0f;
    CGFloat heightOffset = 10.0f;
    self.authcodeLabel = [UILabel new];
    self.authcodeLabel.frame = CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 30);
    self.authcodeLabel.text = NSLocalizedString(@"请保持手机通畅，用于接收验证码短信!", nil);
    self.authcodeLabel.textColor = [RLColor colorWithHex:LabelTextColor];
    [self.view addSubview:self.authcodeLabel];
    
    heightOffset += self.authcodeLabel.frame.size.height + 20;
    self.phoneTextField = [[RLImageTextField alloc] initWithFrame:CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 40)];
    self.phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTextField.icon.image = [UIImage imageNamed:@"Phone"];
    self.phoneTextField.textField.placeholder = NSLocalizedString(@"请输入手机号", nil);
    self.phoneTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.phoneTextField.layer.borderWidth = 0.5f;
    [self.view addSubview:self.phoneTextField];
    
    heightOffset += self.phoneTextField.frame.size.height + 10;
    self.authcodeTextField = [UITextField new];
    self.authcodeTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.authcodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.authcodeTextField.frame = CGRectMake(widthOffset, heightOffset, frame.size.width/2-widthOffset-2, 40.0f);
    self.authcodeTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.authcodeTextField.layer.borderWidth = 0.5f;
    [self.view addSubview:self.authcodeTextField];
    
    widthOffset = self.authcodeTextField.frame.size.width + self.authcodeTextField.frame.origin.x + 2;
    self.authcodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.authcodeButton.frame = CGRectMake(widthOffset, heightOffset, frame.size.width/2-20, 40);
    self.authcodeButton.backgroundColor = [RLColor colorWithHex:0xcccccc];
    [self.authcodeButton setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
    [self.authcodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.authcodeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.authcodeButton.layer.borderWidth = 0.5f;
    self.authcodeButton.layer.cornerRadius = 6;
    [self.authcodeButton addTarget:self action:@selector(clickedAuthcodeButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.authcodeButton];
    
    widthOffset = 20+10;
    heightOffset += self.authcodeButton.frame.size.height + 20;
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.frame = CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 35);
    self.nextButton.backgroundColor = [RLColor colorWithHex:0xCCCCCC];
    [self.nextButton setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.nextButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nextButton.layer.borderWidth = 0.5f;
    self.nextButton.layer.cornerRadius = 6;
    [self.nextButton addTarget:self action:@selector(clickedNextButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
}

- (void)clickedAuthcodeButton {
    [self endEditing];
    if(![self.phoneTextField.textField.text isMobile]) {
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"手机号码有误！", nil)];
        return;
    }
    
    void (^verifyBlock)(BaseResponse *response, NSError *error) = ^(BaseResponse *response, NSError *error) {
        if(error) return ;
        if(response.status) {
            [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"获取验证码出错！", nil)];
        }
    };
    
    self.authcodeButton.enabled = NO;
    __weak __block typeof(UIButton *)button = self.authcodeButton;
    __weak __typeof(self)weakSelf = self;
    [Register verifyPhone:self.phoneTextField.textField.text withBlock:^(BaseResponse *response, NSError *error) {
        button.enabled = YES;
        
        if(weakSelf.type == kRegister) {
            if(error) return ;
            if(response.status) {
                DLog(@"验证码获取出错");
                
                [RLHUD hudAlertNoticeWithBody:NSLocalizedString(@"手机号码已被占用！", nil)];
            }
            else {
                [Register getAuthcode:self.phoneTextField.textField.text withBlock:verifyBlock];
                [self startTimer:self.authcodeButton];
            }
        }
        else {
            if(error) return ;
            if(response.status == 1) {
                [Register getAuthcode:self.phoneTextField.textField.text withBlock:verifyBlock];
                [self startTimer:self.authcodeButton];
            }
            else {
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"手机号码未注册！", nil)];
            }
        }
    }];
}

- (void)clickedNextButton {
    [self endEditing];
    if(![self.phoneTextField.textField.text isMobile]) {
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"手机号码有误！", nil)];
        return;
    }
    
    if(![self.authcodeTextField.text isMobileAuthCode]) {
        
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"验证码有误！", nil)];
        return;
    }
    
    [RLHUD hudProgressWithBody:NSLocalizedString(@"正在验证。。。", nil) onView:self.view timeout:URLTimeoutInterval];

    __weak __typeof(self)weakSelf = self;
    [Register verifyAuthcode:self.phoneTextField.textField.text authcode:self.authcodeTextField.text withBlock:^(BaseResponse *response, NSError *error) {
        [RLHUD hideProgress];
        if(error) return ;
        if(response.status) {
            [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"验证失败！", nil)];
            return ;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [User sharedUser].phone = weakSelf.phoneTextField.textField.text;
            SetPasswordVC *vc = [[SetPasswordVC alloc] init];
            vc.type = weakSelf.type;
            if(vc.type == kForgetPSW) {
                FindPasswordModel *findPasswordModel = [FindPasswordModel new];
                findPasswordModel.phone = weakSelf.phoneTextField.textField.text;
                findPasswordModel.authcode = weakSelf.authcodeTextField.text;
                vc.findPasswordModel = findPasswordModel;
            }
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    }];
}

- (void)startTimer:(id)target {
    __weak __block UIButton *button = target;
    button.backgroundColor = [RLColor colorWithHex:ButtonBackgroundColor];
    button.userInteractionEnabled = NO;
    __block NSInteger timeout = 30;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue/*DISPATCH_SOURCE_TYPE_TIMER*/);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if(timeout <= 0) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                button.userInteractionEnabled = YES;
                [button setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
                self.authcodeButton.backgroundColor = [RLColor colorWithHex:0xcccccc];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *timeStr = [NSString stringWithFormat:@"%lds后重新获取", (long)timeout];
                [button setTitle:NSLocalizedString(timeStr, nil) forState:UIControlStateNormal];
            });
            timeout--;
        }
    });
    dispatch_resume(timer);
}

@end
