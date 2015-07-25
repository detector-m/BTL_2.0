//
//  RLHUD.h
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#pragma mark -
#import "SCLAlertView.h"

#define HUDAlertViewDuration (2.0f)
@interface RLHUD : NSObject
//+ (MBHUDView*)hudAlertWithBody:(NSString*)body type:(MBAlertViewHUDType)type hidesAfter:(float)delay show:(BOOL)show;

+ (void)hudAlertSuccessWithBody:(NSString *)body dimissBlock:(DismissBlock)block;
+ (void)hudAlertErrorWithBody:(NSString *)body dimissBlock:(DismissBlock)block;
+ (void)hudAlertNoticeWithBody:(NSString *)body dimissBlock:(DismissBlock)block;
+ (void)hudAlertWarningWithBody:(NSString *)body dimissBlock:(DismissBlock)block;
+ (void)hudAlertInfoWithBody:(NSString *)body dimissBlock:(DismissBlock)block;
+ (void)hudAlertEditWithBody:(NSString *)body dimissBlock:(DismissBlock)block;
+ (void)hudAlertWaitingWithBody:(NSString *)body dimissBlock:(DismissBlock)block;

+ (void)hudAlertSuccessWithBody:(NSString *)body;
+ (void)hudAlertErrorWithBody:(NSString *)body;
+ (void)hudAlertNoticeWithBody:(NSString *)body;
+ (void)hudAlertWarningWithBody:(NSString *)body;
+ (void)hudAlertInfoWithBody:(NSString *)body;
+ (void)hudAlertEditWithBody:(NSString *)body;
+ (void)hudAlertWaitingWithBody:(NSString *)body;

#pragma mark - ProgressHUD
+ (void)hudProgressWithBody:(NSString *)body onView:(UIView *)view timeout:(NSTimeInterval)timeout withTimeoutBlock:(void (^)())block;
+ (void)hudProgressWithBody:(NSString *)body onView:(UIView *)view timeout:(NSTimeInterval)timeout;
+ (void)hideProgress;

#pragma mark -
+ (void)hudStatusBarProgress;
+ (void)hideStatusBarProgress;
@end
