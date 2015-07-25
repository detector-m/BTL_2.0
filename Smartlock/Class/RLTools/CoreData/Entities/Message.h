//
//  Message.h
//  Smartlock
//
//  Created by RivenL on 15/5/15.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#pragma mark -
#import "XMPPManager.h"
#import "RLDate.h"

/*
 值     类型
 101    踢下线
 102    钥匙被冻结
 103    钥匙被解冻
 104    钥匙过期
 105	版本更新
 106	广播
 107	收到新钥匙
 */

extern NSDictionary *messageDictionaryFromXMPPMessage(XMPPMessage *xmppMessage);

#pragma mark -

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSString * extension;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * isRead;

#pragma mark -
+ (NSInteger)messageType:(NSString *)jsonString;
+ (NSInteger)messageTypeWithXMPPMessage:(XMPPMessage *)xmppMessage;

+ (NSString *)messageDeviceTokenWithXMPPMessage:(XMPPMessage *)xmppMessage;
//报文flag：flag=1 需要重新加载；flag=0 无需重新加载
+ (NSInteger)messageFlag:(NSString *)jsonString;
+ (NSInteger)messageFlagWithXMPPMessage:(XMPPMessage *)xmppMessage;
@end
