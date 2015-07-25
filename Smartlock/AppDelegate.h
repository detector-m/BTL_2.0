//
//  AppDelegate.h
//  Smartlock
//
//  Created by RivenL on 15/3/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (nonatomic, weak) NSString *deviceTokenString;

+ (void)setLoginVCToRootVCAnimate:(BOOL)animate;
+ (void)setMainVCToRootVCAnimate:(BOOL)animate;
+ (void)changeRootViewController:(UIViewController *)vc;
@end

