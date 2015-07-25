//
//  MessageContentVC.h
//  Smartlock
//
//  Created by RivenL on 15/5/8.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BaseTableVC.h"
#import "NotificationMessage.h"

@interface MessageContentVC : BaseTableVC
@property (nonatomic, weak) NotificationMessage *message;
@end
