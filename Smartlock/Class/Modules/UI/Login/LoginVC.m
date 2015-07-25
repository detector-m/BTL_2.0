//
//  LoginVC.m
//  Smartlock
//
//  Created by RivenL on 15/3/31.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LoginVC.h"
#import "RLColor.h"
#import "UIViewController+Expand.h"
#import "RLImageTextField.h"

#import "MainVC.h"
#import "AuthCodeVC.h"

#import "RLHTTPAPIClient.h"

#pragma mark -
#import "XMPPManager.h"

#import "MyCoreDataManager.h"

#define LoginBackgroundColor (0x199ACA) 
//(0x0F6797)
#define ButtonBackgroundColor (0x3FCDFD)
//(0x399ACA)

#define LoginIconSize (160)

@interface LoginVC ()
@property (nonatomic, strong) UIImageView *loginIcon;

@property (nonatomic, strong) RLImageTextField *account;
@property (nonatomic, strong) RLImageTextField *password;

@property (nonatomic, strong) UIButton *forgetPWButton;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) UILabel *registerLabel;
@property (nonatomic, strong) UIButton *registerButton;

#pragma mark -
@property (nonatomic, assign) CGPoint orignalCenter;
@end

@implementation LoginVC
- (void)dealloc {
    [self removeNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [User sharedUser].isLogined = NO;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *displayname = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    self.title = displayname;//NSLocalizedString(@"永家科技", nil);
    [self.backgroundImage removeFromSuperview];
    [self setupForDismissKeyboard];
    
    self.view.backgroundColor = [RLColor colorWithHex:LoginBackgroundColor];
    self.orignalCenter = self.view.center;
    
    CGRect frame = self.view.frame;
    self.loginIcon = [UIImageView new];
    self.loginIcon.frame = CGRectMake((frame.size.width-LoginIconSize)/2, 5, LoginIconSize, LoginIconSize);
    self.loginIcon.image = [UIImage imageNamed:@"LoginIcon.png"];
    [self.view addSubview:self.loginIcon];
    
    CGFloat heightOffset = self.loginIcon.frame.size.height + self.loginIcon.frame.origin.y + 5;
    CGFloat widthOffset = 20;
    self.account = [[RLImageTextField alloc] initWithFrame:CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 40)];
    self.account.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.account.icon.image = [UIImage imageNamed:@"Account"];
    self.account.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.account.layer.borderWidth = 0.5f;
    [self.view addSubview:self.account];
    
    heightOffset += self.account.frame.size.height;
    self.password = [[RLImageTextField alloc] initWithFrame:CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 40)];
    self.password.textField.secureTextEntry = YES;
    self.password.icon.image = [UIImage imageNamed:@"Password"];
    self.password.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.password.layer.borderWidth = 0.5f;
    [self.view addSubview:self.password];
    
#if 0
    heightOffset += self.password.frame.size.height + 5;
    widthOffset = (frame.size.width-100-widthOffset);
    self.forgetPWButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forgetPWButton.frame = CGRectMake(widthOffset, heightOffset, 100, 30);
    [self.forgetPWButton setTitle:NSLocalizedString(@"Forget PW?", nil) forState:UIControlStateNormal];
    [self.forgetPWButton addTarget:self action:@selector(clickedForgetPWButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.forgetPWButton];
    
    heightOffset += self.forgetPWButton.frame.size.height+3;
    widthOffset = 40;
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginButton.frame = CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 35);
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(clickedLoginButton) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.backgroundColor = [RLColor colorWithHex:ButtonBackgroundColor];
    self.loginButton.layer.cornerRadius = 6;
    [self.view addSubview:self.loginButton];
    
    heightOffset += self.loginButton.frame.size.height + 50;
    self.registerLabel = [UILabel new];
    self.registerLabel.frame = CGRectMake(frame.size.width/2-100, heightOffset, 200, 30);
    self.registerLabel.textAlignment = NSTextAlignmentCenter;
    self.registerLabel.textColor = [UIColor whiteColor];
    self.registerLabel.text = NSLocalizedString(@"当前没有账号？", nil);
    [self.view addSubview:self.registerLabel];
    
    heightOffset += self.registerLabel.frame.size.height + 1;
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerButton.frame = CGRectMake(frame.size.width/2-65, heightOffset, 130, 35);
    [self.registerButton setTitle:NSLocalizedString(@"注    册", nil) forState:UIControlStateNormal];
    self.registerButton.backgroundColor = [RLColor colorWithHex:ButtonBackgroundColor];
    self.registerButton.layer.cornerRadius = 6;
    [self.registerButton addTarget:self action:@selector(clickedRegisterButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
#else
    heightOffset += self.password.frame.size.height + 20;
    widthOffset = 25;
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginButton.frame = CGRectMake(widthOffset, heightOffset, frame.size.width-widthOffset*2, 40);
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:23];
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(clickedLoginButton) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.backgroundColor = [RLColor colorWithHex:ButtonBackgroundColor];
    self.loginButton.layer.cornerRadius = 6;
    [self.view addSubview:self.loginButton];
    
    heightOffset += self.loginButton.frame.size.height + 20;
    self.forgetPWButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forgetPWButton.frame = CGRectMake(widthOffset, heightOffset, 100, 35);
    [self.forgetPWButton setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
    [self.forgetPWButton addTarget:self action:@selector(clickedForgetPWButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.forgetPWButton];
    
    widthOffset = (frame.size.width-100-widthOffset);
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerButton.frame = CGRectMake(widthOffset, heightOffset, 100, 35);
    [self.registerButton setTitle:NSLocalizedString(@"注册用户", nil) forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(clickedRegisterButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
#endif
    
    [self addNotifications];
}

- (void)clickedForgetPWButton {
    [self endEditing];
    AuthCodeVC *vc = [AuthCodeVC new];
    vc.type = kForgetPSW;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickedLoginButton {
    [self endEditing];
    self.navigationItem.backBarButtonItem = nil;
    if(![self.account.textField.text isMobile]) {
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"账号输入有误！", nil)];
        return;
    }
    
    if(self.password.textField.text.length == 0) {
        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"密码为空！", nil)];
        return;
    }
    
    LoginModel *login = [[LoginModel alloc] init];
    login.account = self.account.textField.text;
    login.password = self.password.textField.text;
    login.location = [RLLocationManager sharedLocationManager].curLoction;
    login.deviceToken = [User sharedUser].deviceToken;
//    if(!login.deviceToken) {
//        [RLHUD hudAlertWarningWithBody:NSLocalizedString(@"请查看网络！", nil)];
//        return;
//    }
    if(!login.location.city || login.location.city.length == 0) {
        [RLHUD hudAlertNoticeWithBody:NSLocalizedString(@"请过5－10s后再试！", nil)];

        return;
    }

    [Login login:login withBlock:^(LoginResponse *response, NSError *error) {
        [RLHUD hideProgress];
        if(response.success) {
            [User sharedUser].password = login.password;
            [[MyCoreDataManager sharedManager] setIdentifier:[User sharedUser].dqID];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(![[XMPPManager sharedXMPPManager] connect]) {
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"登录失败", nil)];
                    return ;
                }
                
                [Login login];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"用户名或密码错误！", nil)];

            });
        }
    }];
    [RLHUD hudProgressWithBody:NSLocalizedString(@"登录中。。。", nil) onView:self.view timeout:URLTimeoutInterval];
}

- (void)clickedRegisterButton {
    [self endEditing];
    AuthCodeVC *vc = [AuthCodeVC new];
    vc.type = kRegister;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDismiss:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (void)keyboardWillShow:(id)sender {
    self.orignalCenter = self.view.center;
    [UIView animateWithDuration:.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.center = CGPointMake(self.orignalCenter.x, self.orignalCenter.y-90);
    } completion:nil];
}

- (void)keyboardWillDismiss:(id)sender {
    [UIView animateWithDuration:.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.center = self.orignalCenter;
    } completion:nil];
}

@end
