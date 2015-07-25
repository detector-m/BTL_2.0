//
//  RLNotificationManager.h
//  Smartlock
//
//  Created by RivenL on 15/4/26.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIUserNotificationSettings+Extension.h"

@interface RLNotificationManager : NSObject
+ (void)openNotificationPermission;
+ (void)openRemoteNotification;
#pragma mark -
//----------------------------------------//
//+ (void)messageNotification;
+ (void)scheduleMessageNotificationWithAlert:(NSString *)alert;
+ (void)removeMessageNotification;
//----------------------------------------//
@end
