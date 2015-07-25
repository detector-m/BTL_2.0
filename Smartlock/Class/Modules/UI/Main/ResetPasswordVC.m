//
//  ResetPasswordVC.m
//  Smartlock
//
//  Created by RivenL on 15/5/5.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "ResetPasswordVC.h"
#import "UIViewController+Expand.h"
#import "RLTitleTextField.h"
#import "RLColor.h"
#import "UserOperationRequest.h"

#import "Login.h"

@interface ResetPasswordVC ()
@property (nonatomic, strong) RLTitleTextField *oldPassword;
@property (nonatomic, strong) RLTitleTextField *password;
@property (nonatomic, strong) RLTitleTextField *pswCheck;

@property (nonatomic, strong) UIButton *commiteBtn;
@end

#define ButtonBackgroundColor (0xcccccc)

@implementation ResetPasswordVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"更改密码", nil);
    [self setupForDismissKeyboard];
    
    CGRect frame = self.view.frame;
    CGFloat widthOffset = 20;
    CGFloat heightOffset = 20;
    
    self.oldPassword = [[RLTitleTextField alloc] initWithFrame:CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 60)];
    self.oldPassword.textField.secureTextEntry = YES;
    [self.oldPassword setStyle:kRLTitleTextFieldVertical];
    self.oldPassword.title.text = NSLocalizedString(@"原密码", nil);
    [self.view addSubview:self.oldPassword];
    
    heightOffset += self.oldPassword.frame.size.height;
    self.password = [[RLTitleTextField alloc] initWithFrame:CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 60)];
    self.password.textField.secureTextEntry = YES;
    [self.password setStyle:kRLTitleTextFieldVertical];
    self.password.title.text = NSLocalizedString(@"请输入新密码", nil);
    [self.view addSubview:self.password];
    
    heightOffset += self.password.frame.size.height;
    self.pswCheck = [[RLTitleTextField alloc] initWithFrame:CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 60)];
    self.pswCheck.textField.secureTextEntry = YES;
    [self.pswCheck setStyle:kRLTitleTextFieldVertical];
    self.pswCheck.title.text = NSLocalizedString(@"确认密码", nil);
    [self.view addSubview:self.pswCheck];
    
    heightOffset += self.pswCheck.frame.size.height + 20;
    self.commiteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commiteBtn.frame = CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 30);
    self.commiteBtn.backgroundColor = [RLColor colorWithHex:ButtonBackgroundColor];
    [self.commiteBtn setTitle:NSLocalizedString(@"确认", nil) forState:UIControlStateNormal];
    [self.commiteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.commiteBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.commiteBtn.layer.borderWidth = 0.5f;
    self.commiteBtn.layer.cornerRadius = 6;
    [self.commiteBtn addTarget:self action:@selector(clickCommiteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commiteBtn];
}

- (void)clickCommiteBtn:(UIButton *)button {
    [self endEditing];
    if(self.oldPassword.textField.text.length < 6) {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"原密码有误！", nil)];
        return;
    }
    
    if(self.password.textField.text.length < 6 || ![self.password.textField.text isEqualToString:self.pswCheck.textField.text]) {
        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"密码输入错误！", nil)];
        
        return;
    }
    
    [UserOperationRequest resetPassword:self.oldPassword.textField.text newPwd:self.password.textField.text token:[User sharedUser].sessionToken withBlock:^(UserOperationResponse *response, NSError *error) {
        if(error) return ;
        if(response.status > 0) {
            [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"修改密码失败！", nil)];
            
            return ;
        }
        
        [RLHUD hudAlertSuccessWithBody:NSLocalizedString(@"密码更改成功", nil) dimissBlock:^{
            [Login logout];
        }];
    }];
}
@end
