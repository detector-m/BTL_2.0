//
//  RLNotificationManager.m
//  Smartlock
//
//  Created by RivenL on 15/4/26.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLNotificationManager.h"

@implementation RLNotificationManager
+ (void)openNotificationPermission {
    // message category
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
//        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];    
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound];
        
        return;
    }
    UIMutableUserNotificationCategory *messageCategory = [UIMutableUserNotificationCategory new];
    messageCategory.identifier = @"Message";
    [messageCategory setActions:nil forContext:UIUserNotificationActionContextDefault];
    [messageCategory setActions:nil forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:messageCategory, nil];
    UIUserNotificationType notificationType = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAll;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}
+ (void)openRemoteNotification {
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound];
        
        return;
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark -
#define MessageNotificationType @"MessageNotificationType"
//----------------------------------------//
+ (void)messageNotification {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    localNotification.alertBody = @"Email Based Notification";
    localNotification.category = @"Email";  // This should match categories identifier which we have defined in App delegate
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

+ (void)scheduleMessageNotificationWithAlert:(NSString *)alert {
    // We are not active, so use a local notification instead
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.applicationIconBadgeNumber = (++[UIApplication sharedApplication].applicationIconBadgeNumber);
        //        localNotification.alertAction = @"Ok";
    localNotification.alertBody = alert;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    NSDictionary *infoDic = @{@"type":MessageNotificationType};
    localNotification.userInfo = infoDic;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

+ (void)removeMessageNotification {
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //获取当前所有的本地通知
    if (!notificaitons || notificaitons.count <= 0) {
        return;
    }
    for (UILocalNotification *notify in notificaitons) {
        if ([[notify.userInfo objectForKey:@"type"] isEqualToString:MessageNotificationType]) {
            //取消一个特定的通知
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
        }
    }
}
//----------------------------------------//

@end
