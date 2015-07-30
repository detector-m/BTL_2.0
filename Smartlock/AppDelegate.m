//
//  AppDelegate.m
//  Smartlock
//
//  Created by RivenL on 15/3/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "AppDelegate.h"
#import "RLBaseNavigationController.h"

#import "LoginVC.h"
#import "MainVC.h"

#import "RLNotificationManager.h"
#import "AWVersionAgent.h"

#import "XMPPManager.h"

#import "RLHTTPAPIClient.h"

#import "RLBluetooth.h"

#import "RLUtilitiesMethods.h"

#import "MyCoreDataManager.h"

#pragma mark -
#import "CustomURLCache.h"

#if 1
/************** Test *****************/
#import "ViewController.h"
#import "TestViewController.h"
#import "Register.h"
#import "MyCoreDataManager.h"

#import "BluetoothLockCommand.h"

#import "Message.h"
#import "RLJSON.h"
#import "RLDate.h"

#import "KeyEntity.h"
#import "LockEntity.h"

#import "RLSecurityPolicy.h"
/*************************************/
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)securityTest {
//    NSData *tempData = [[NSString stringWithFormat:@"12345abcdF"] dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *decryptWithVariableKey(NSData *data, Byte *key);
//    NSData *enData = encryptStringWithFinalKey(@"12345675432334abcAABDEFASDf");
//    NSLog(@"%@", enData);
//    NSString *string = [[NSString alloc] initWithData:decryptWithFinalKey(enData) encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", string);
    
//    NSData *data = [[NSString stringWithFormat:@"12345abcdF"] dataUsingEncoding:NSUTF8StringEncoding];
//    uint8_t data[] = {0x51, 0x05, 0x97, 0x47, 0xd7, 0xe9, 0x05, 0xfc, 0xb0, 0xda, 0x00};//"12345AbcdefaDD";
//    uint8_t finalKey[16] = {0xDB,0x8F,0xBB,0x54,0xCA,0x77,0x0C,0x7A,0xEF,0x9F,0x41,0xE2,0xBF,0xFF,0x57,0x40};
//    NSLog(@"%s", data);
//    int i = strlen(data);
//    NSData *enData = [NSData dataWithBytes:data length:i];
//    NSLog(@"%@", enData);
//
//    xxtea_byte_encrypt(data, i, (uint32_t *)finalKey);
//    enData = [NSData dataWithBytes:data length:i];
//    NSLog(@"%@", enData);
    
//    xxtea_byte_decrypt(data, 10, (uint32_t *)finalKey);
//    NSLog(@"%s", data);
//    NSLog(@"%@", enData);
    
    Byte xx = 0;
    long long time = getTimestamp();
//    NSData *data = [[NSString stringWithFormat:@"12345abcdF"] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:(unsigned char *)&time length:sizeof(long long)];
    NSLog(@"%@", data);
    NSData *enData = btlXXTEAByteEncryptDataWithFinalKey(data, &xx);
    NSLog(@"%@", enData);
    NSData *tt = btlXXTEAByteDecryptDataWithFinalKey(enData, xx);
    NSLog(@"%@", tt);
    NSString *string = [[NSString alloc] initWithData:btlXXTEAByteDecryptDataWithFinalKey(enData, xx) encoding:NSUTF8StringEncoding];
    NSLog(@"%@", string);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    [self securityTest];
//    return YES;
    
#pragma mark - webview url cache
    CustomURLCache *urlCache = [[CustomURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024 diskCapacity:200 * 1024 * 1024 diskPath:nil cacheTime:60*24*60*7];
    [CustomURLCache setSharedURLCache:urlCache];

#pragma mark - SoundManager
    [[SoundManager sharedManager] prepareToPlay];
    
#pragma mark - Network
    static BOOL isCanShowAlert = YES;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(isCanShowAlert) {
                    isCanShowAlert = NO;
                    [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"网络不可用", nil) dimissBlock:^{
                        isCanShowAlert = YES;
                    }];
                }
            });
        }
    }];
    
#pragma mark -
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
#if 0
//    ViewController *vc = [ViewController new];
    TestViewController *vc = [TestViewController new];

    RLBaseNavigationController *nav = [RLBaseNavigationController new];
    [nav pushViewController:vc animated:NO];
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
#else
    User *user = [User loadArchiver];
    
    [[self class] setLoginVCToRootVCAnimate:NO];
    if(user) {
        [[User sharedUser] setWithUser:user];
        [[MyCoreDataManager sharedManager] setIdentifier:user.dqID];
        if([[XMPPManager sharedXMPPManager] connect]) {
            [[self class] setMainVCToRootVCAnimate:NO];
        }
        else {
            [RLHUD hudAlertErrorWithBody:NSLocalizedString(@"登录失败", nil)];
        }
    }
    
    [self.window makeKeyAndVisible];
    
#pragma mark -
    [RLNotificationManager openNotificationPermission];
    [RLNotificationManager openRemoteNotification];
//    [RLNotificationManager messageNotification];
    
#pragma mark - Version agent
//    [[AWVersionAgent sharedAgent] setDebug:YES];
//    [AWVersionAgent sharedAgent].actionText = @"test";
//    [[AWVersionAgent sharedAgent] checkNewVersionForApp:@"453718989"];
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        [self application:application didReceiveLocalNotification:launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]];
    }
    
    if(launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [[RLLocationManager sharedLocationManager] stopUpdatingLocation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
#if 1
    UIApplication *app = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
#endif
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[RLLocationManager sharedLocationManager] startUpdatingLocation];
    
    [RLNotificationManager removeMessageNotification];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[RLBluetooth sharedBluetooth] disconnectAllPeripherals];
    [RLBluetooth sharedRelease];
}

#pragma mark -
/*****************************************************
 1.创建消息上面要添加的动作(按钮的形式显示出来)
 2.创建动作(按钮)的类别集合
 3.创建UIUserNotificationSettings，并设置消息的显示类类型
 4.注册推送
 5.发起本地推送消息
 6.在AppDelegate.m里面对结果进行处理
 *****************************************************/
//本地推送通知
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //成功注册registerUserNotificationSettings:后，回调的方法
//    DLog(@"%@",notificationSettings);
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //收到本地推送消息后调用的方法
    DLog(@"%@",notification);
    [[AWVersionAgent sharedAgent] upgradeAppWithNotification:notification];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    //在非本App界面时收到本地消息，下拉消息会有快捷回复的按钮，点击按钮后调用的方法，根据identifier来判断点击的哪个按钮，notification为消息内容
    DLog(@"%@----%@",identifier,notification);
    completionHandler();//处理完消息，最后一定要调用这个代码块
}

#pragma mark -
//远程推送通知
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //向APNS注册成功，收到返回的deviceToken
    
    DLog(@"APNS OK device token = %@", deviceToken);
    if((![User sharedUser].deviceToken || [User sharedUser].deviceToken.length == 0) && deviceToken.length != 0) {
        [User sharedUser].deviceToken = deviceToken;
        if(![User sharedUser].isLogined) {
            return;
        }
        [Login hudAlertLogout];
        return;
    }
    [User sharedUser].deviceToken = deviceToken;
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //向APNS注册失败，返回错误信息error
    DLog(@"APNS error = %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //收到远程推送通知消息
    DLog(@"%@", userInfo);
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    //在没有启动本App时，收到服务器推送消息，下拉消息会有快捷回复的按钮，点击按钮后调用的方法，根据identifier来判断点击的哪个按钮

}

#pragma mark -
+ (void)setLoginVCToRootVCAnimate:(BOOL)animate {
    UIViewController *loginVC = ((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController;
    
    if([loginVC isKindOfClass:[RLBaseNavigationController class]]) {
        if([[loginVC.childViewControllers firstObject] isKindOfClass:[LoginVC class]]) {
            return;
        }
    }
    
    loginVC = [LoginVC new];
    
    RLBaseNavigationController *nav = [[RLBaseNavigationController alloc] initWithRootViewController:loginVC];
    if(animate) {
        [[self class] changeRootViewController:nav];
    }
    else {
        ((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController = nav;
    }
}

+ (void)setMainVCToRootVCAnimate:(BOOL)animate {
    
    UIViewController *vc = ((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController;
    
    if([vc isKindOfClass:[RLBaseNavigationController class]]) {
        if([[vc.childViewControllers firstObject] isKindOfClass:[MainVC class]]) {
            return;
        }
    }
    
    vc = [MainVC new];
    RLBaseNavigationController *mainNav = [[RLBaseNavigationController alloc] initWithRootViewController:vc];
    if(animate) {
        [[self class] changeRootViewController:mainNav];
    }
    else {
        ((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController = mainNav;
    }
}

#pragma mark - public methods
+ (void)changeRootViewController:(UIViewController *)vc {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).window;
        if(vc == nil || window.rootViewController == vc)
            return;
        
        CGPoint currentCenter;
        UIViewController *currentVC = window.rootViewController;
        [window setRootViewController:vc];

        currentCenter = currentVC.view.center;
        [vc.view.superview addSubview:currentVC.view];
        
        vc.view.center = CGPointMake(currentCenter.x, -currentCenter.y);
        [UIView animateWithDuration:.5f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            currentVC.view.center = CGPointMake(currentCenter.x, currentCenter.y+vc.view.frame.size.height);
            vc.view.center = currentCenter;
        } completion:^(BOOL finished) {
            for(UIViewController *tempVC in currentVC.childViewControllers) {
                [tempVC.view removeFromSuperview];
                [tempVC removeFromParentViewController];
            }
            
            [currentVC.view removeFromSuperview];
        }];
    });
}

@end
