//
//  RLHUD.m
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLHUD.h"

static const float kPopViewDuration  = 2.f;

NSString * const kSuccessTitle = @"Congratulations 😊";
NSString * const kErrorTitle = @"Error 😭";
NSString * const kNoticeTitle = @"Notice";
NSString * const kWarningTitle = @"Warning ⚠️";
NSString * const kInfoTitle = @"Info";
NSString * const kWaitingTitle = @"Waiting... ⌛️";

@implementation RLHUD
+ (void)hideAllOldAlertHUD {
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
}

+ (MBProgressHUD *)getMBAlertHUDWithTitle:(NSString *)title andDetails:(NSString *)details {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.removeFromSuperViewOnHide = YES;
    [view addSubview:HUD];
    HUD.labelText = title;
    HUD.detailsLabelText = details;
//    HUD.margin = 2.f;
    
    return HUD;
}

+ (void)HUDAlertTask {
    sleep(kPopViewDuration);
//    usleep(3000000);
}
#pragma mark -
+ (void)hudAlertSuccessWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideAllOldAlertHUD];
        
        __block MBProgressHUD *HUD = [self getMBAlertHUDWithTitle:nil andDetails:body];
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUDCheckmark.png"]];
        
        // Set custom view mode
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.square = YES;
        
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self HUDAlertTask];
        } completionBlock:^{
            if(block) {
                block();
            }
            HUD = nil;
        }];
//        [HUD show:YES];
//        [HUD hide:YES afterDelay:3];
    });
}
+ (void)hudAlertErrorWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideAllOldAlertHUD];
        
        __block MBProgressHUD *HUD = [self getMBAlertHUDWithTitle:nil andDetails:body];
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUDErrormark.png"]];
        
        // Set custom view mode
        HUD.mode = MBProgressHUDModeCustomView;
        
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self HUDAlertTask];
        } completionBlock:^{
            if(block) {
                block();
//                block = nil;
            }
            HUD = nil;
        }];
    });
}
+ (void)hudAlertNoticeWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideAllOldAlertHUD];

        __block MBProgressHUD *HUD = [self getMBAlertHUDWithTitle:kNoticeTitle andDetails:body];
        HUD.mode = MBProgressHUDModeText;
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self HUDAlertTask];
        } completionBlock:^{
            if(HUD == nil)
                return ;
            if(block) {
                block();
            }
            HUD = nil;
        }];
    });
    
}
+ (void)hudAlertWarningWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideAllOldAlertHUD];
        
        __block MBProgressHUD *HUD = [self getMBAlertHUDWithTitle:kWarningTitle andDetails:body];
        HUD.mode = MBProgressHUDModeText;
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self HUDAlertTask];
        } completionBlock:^{
            if(block) {
                block();
            }
            HUD = nil;
        }];

    });
}
+ (void)hudAlertInfoWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideAllOldAlertHUD];
        
        __block MBProgressHUD *HUD = [self getMBAlertHUDWithTitle:kWaitingTitle andDetails:body];
        HUD.mode = MBProgressHUDModeText;
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self HUDAlertTask];
        } completionBlock:^{
            if(block) {
                block();
            }
            HUD = nil;
        }];

    });
}
+ (void)hudAlertEditWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            if(block) {
                [alert alertIsDismissed:block];
            }
            [alert showEdit:[UIApplication sharedApplication].keyWindow.rootViewController title:body
                   subTitle:nil
           closeButtonTitle:NSLocalizedString(@"确定", nil) duration:kPopViewDuration];
        });
    });
}

+ (void)hudAlertWaitingWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideAllOldAlertHUD];
        
        __block MBProgressHUD *HUD = [self getMBAlertHUDWithTitle:kWaitingTitle andDetails:body];
        HUD.mode = MBProgressHUDModeText;
        [HUD showAnimated:YES whileExecutingBlock:^{
            [self HUDAlertTask];
        } completionBlock:^{
            if(block) {
                block();
            }
            HUD = nil;
        }];
    });
}


#if 0
+ (void)alertViewOnScreenHide {
    for(UIViewController *vc in [UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers) {
        if([vc isKindOfClass:[SCLAlertView class]]) {
            [(SCLAlertView *)vc hideView];
        }
    }
}

+ (void)hudAlertSuccessWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideAllOldAlertView];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        if(block) {
            [alert alertIsDismissed:block];
        }
        [alert showSuccess:[UIApplication sharedApplication].keyWindow.rootViewController title:kSuccessTitle
                subTitle:body
        closeButtonTitle:NSLocalizedString(@"确定", nil) duration:kPopViewDuration];
    });
}
+ (void)hudAlertErrorWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideAllOldAlertView];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        if(block) {
            [alert alertIsDismissed:block];
        }
        [alert showError:[UIApplication sharedApplication].keyWindow.rootViewController title:kErrorTitle
                  subTitle:body
          closeButtonTitle:NSLocalizedString(@"确定", nil) duration:kPopViewDuration];
    });
}
+ (void)hudAlertNoticeWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertViewOnScreenHide];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        if(block) {
            [alert alertIsDismissed:block];
        }
        [alert showNotice:[UIApplication sharedApplication].keyWindow.rootViewController title:kNoticeTitle
                subTitle:body
        closeButtonTitle:NSLocalizedString(@"确定", nil) duration:kPopViewDuration];
    });

}
+ (void)hudAlertWarningWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertViewOnScreenHide];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        if(block) {
            [alert alertIsDismissed:block];
        }
        [alert showWarning:[UIApplication sharedApplication].keyWindow.rootViewController title:kWarningTitle
                 subTitle:body
         closeButtonTitle:NSLocalizedString(@"确定", nil) duration:kPopViewDuration];
    });
}
+ (void)hudAlertInfoWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertViewOnScreenHide];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        if(block) {
            [alert alertIsDismissed:block];
        }
        [alert showInfo:[UIApplication sharedApplication].keyWindow.rootViewController title:kInfoTitle
                 subTitle:body
         closeButtonTitle:NSLocalizedString(@"确定", nil) duration:kPopViewDuration];
    });
}
+ (void)hudAlertEditWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertViewOnScreenHide];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        if(block) {
            [alert alertIsDismissed:block];
        }
        [alert showEdit:[UIApplication sharedApplication].keyWindow.rootViewController title:body
                 subTitle:nil
         closeButtonTitle:NSLocalizedString(@"确定", nil) duration:kPopViewDuration];
    });
}

+ (void)hudAlertWaitingWithBody:(NSString *)body dimissBlock:(DismissBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertViewOnScreenHide];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        if(block) {
            [alert alertIsDismissed:block];
        }
        [alert showWaiting:[UIApplication sharedApplication].keyWindow.rootViewController title:kWaitingTitle
                 subTitle:body
         closeButtonTitle:NSLocalizedString(@"确定", nil) duration:kPopViewDuration];
    });
}
#endif

+ (void)hudAlertSuccessWithBody:(NSString *)body {
    [self hudAlertSuccessWithBody:body dimissBlock:nil];
}
+ (void)hudAlertErrorWithBody:(NSString *)body {
    [self hudAlertErrorWithBody:body dimissBlock:nil];
}
+ (void)hudAlertNoticeWithBody:(NSString *)body {
    [self hudAlertNoticeWithBody:body dimissBlock:nil];
}
+ (void)hudAlertWarningWithBody:(NSString *)body {
    [self hudAlertWarningWithBody:body dimissBlock:nil];
}
+ (void)hudAlertInfoWithBody:(NSString *)body {
    [self hudAlertInfoWithBody:body dimissBlock:nil];
}
+ (void)hudAlertEditWithBody:(NSString *)body {
    [self hudAlertErrorWithBody:body dimissBlock:nil];
}
+ (void)hudAlertWaitingWithBody:(NSString *)body {
    [self hudAlertWarningWithBody:body dimissBlock:nil];
}


#pragma mark - 
static MBProgressHUD *hudProgress = nil;
static void (^timeoutblock)() = nil;
+ (void)hudProgressWithBody:(NSString *)body onView:(UIView *)view timeout:(NSTimeInterval)timeout withTimeoutBlock:(void (^)())block {
    if(hudProgress) {
        timeoutblock = nil;
        [hudProgress setHidden:YES];
        [hudProgress removeFromSuperview];
        hudProgress = nil;
    }
    if(!hudProgress) {
        hudProgress = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hudProgress];
        hudProgress.labelText = body;
        hudProgress.removeFromSuperViewOnHide = YES;
    }
    
    timeoutblock = block;

    __weak typeof(self)weakSelf = self;
    [hudProgress showAnimated:YES whileExecutingBlock:^{
        [weakSelf timeout:timeout];
    } completionBlock:^{
        if(timeoutblock) {
            timeoutblock();
        }
        if(hudProgress) {
//            [hudProgress hide:NO];
            [hudProgress removeFromSuperview];
            hudProgress = nil;
        }
    }];
}

+ (void)hudProgressWithBody:(NSString *)body onView:(UIView *)view timeout:(NSTimeInterval)timeout {
    [self hudProgressWithBody:body onView:view timeout:timeout withTimeoutBlock:nil];
}

+ (void)timeout:(NSTimeInterval)timeout {
    // Do something usefull in here instead of sleeping ...
    sleep(timeout);
}

+ (void)hideProgress {
    if(hudProgress) {
//        [hudProgress setHidden:YES];
//        [hudProgress removeFromSuperview];
        [hudProgress hide:YES afterDelay:0.0f];
//        hudProgress = nil;
    }
    
    if(timeoutblock) {
        timeoutblock = nil;
    }
}

#pragma mark -
+ (void)hudStatusBarProgress {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
+ (void)hideStatusBarProgress {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
