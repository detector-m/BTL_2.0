//
//  SetPasswordVC.m
//  Smartlock
//
//  Created by RivenL on 15/4/1.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "SetPasswordVC.h"
#import "MainVC.h"
#import "UIViewController+Expand.h"
#import "RLColor.h"
#import "RLTitleTextField.h"

#import "Register.h"
#import "Login.h"

#pragma mark -
#import "XMPPManager.h" 
#import "MyCoreDataManager.h"

#define ButtonBackgroundColor (0xcccccc)

@interface SetPasswordVC ()
@property (nonatomic, strong) RLTitleTextField *password;
@property (nonatomic, strong) RLTitleTextField *pswCheck;

@property (nonatomic, strong) UIButton *commiteButton;
@end

@implementation SetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"设置密码", nil);
    [self setupForDismissKeyboard];
    
    CGRect frame = self.view.frame;
    CGFloat widthOffset = 20;
    CGFloat heightOffset = 20;
    self.password = [[RLTitleTextField alloc] initWithFrame:CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 60)];
    self.password.textField.secureTextEntry = YES;
    [self.password setStyle:kRLTitleTextFieldVertical];
    self.password.title.text = NSLocalizedString(@"请输入密码", nil);
//    self.password.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.password.textField.layer.borderWidth = 0.5f;
    [self.view addSubview:self.password];
    
    heightOffset += self.password.frame.size.height;
    self.pswCheck = [[RLTitleTextField alloc] initWithFrame:CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 60)];
    self.pswCheck.textField.secureTextEntry = YES;
    [self.pswCheck setStyle:kRLTitleTextFieldVertical];
    self.pswCheck.title.text = NSLocalizedString(@"确认密码", nil);
//    self.pswCheck.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.pswCheck.textField.layer.borderWidth = 0.5f;
    [self.view addSubview:self.pswCheck];
    
    heightOffset += self.pswCheck.frame.size.height + 20;
    self.commiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commiteButton.frame = CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 30);
    self.commiteButton.backgroundColor = [RLColor colorWithHex:ButtonBackgroundColor];
    [self.commiteButton setTitle:NSLocalizedString(@"确认", nil) forState:UIControlStateNormal];
    [self.commiteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.commiteButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.commiteButton.layer.borderWidth = 0.5f;
    self.commiteButton.layer.cornerRadius = 6;
    [self.commiteButton addTarget:self action:@selector(clickedCommiteButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commiteButton];
}

- (void)clickedCommiteButton {
    [self endEditing];
    if(self.password.textField.text.length == 0 || self.pswCheck.textField.text.length == 0 || ![self.password.textField.text isEqualToString:self.pswCheck.textField.text]) {
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"密码输入有误！", nil)];
        
        return;
    }
    
    if(self.type == kRegister) {
        RegisterModel *aRegister = [[RegisterModel alloc] init];
        aRegister.deviceToken = [User sharedUser].deviceToken;
//        if(!aRegister.deviceToken) {
//            [RLHUD hudAlertNoticeWithBody:NSLocalizedString(@"请过5－10s后再试！", nil)];
//            return;
//        }
        [RLHUD hudProgressWithBody:nil onView:self.view timeout:URLTimeoutInterval];
        aRegister.account = [User sharedUser].phone;
        aRegister.password = self.password.textField.text;
        [Register register:aRegister withBlock:^(RegisterResponse *response, NSError *error) {
            [RLHUD hideProgress];
            if(error) return ;
            if(response.status) {
                
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"注册失败！", nil)];
            }
            else {
                [User sharedUser].password = aRegister.password;
                [[MyCoreDataManager sharedManager] setIdentifier:[User sharedUser].dqID];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(![[XMPPManager sharedXMPPManager] connect]) {
                        [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"登录失败", nil)];
                        
                        return ;
                    }
                    [Login login];
                });
            }
        }];
    }
    else {
        [RLHUD hudProgressWithBody:nil onView:self.view timeout:URLTimeoutInterval];
        self.findPasswordModel.password = self.password.textField.text;
        __weak __typeof(self)weakSelf = self;
        [Register findPassword:self.findPasswordModel withBlock:^(RegisterResponse *response, NSError *error) {
            [RLHUD hideProgress];
            if(error) return ;
            if(response.status) {
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"找回密码失败！", nil)];
            }
            else {
                [RLHUD hudAlertSuccessWithBody:NSLocalizedString(@"成功找回", nil) dimissBlock:^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }];
            }
        }];
    }
}

@end
