//
//  Message.m
//  Smartlock
//
//  Created by RivenL on 15/5/15.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "Message.h"

#import "RLJSON.h"
#import "RLDate.h"

#pragma mark -
NSDictionary *messageDictionaryFromXMPPMessage(XMPPMessage *xmppMessage) {
    if(xmppMessage == nil)
        return nil;
    
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:@"1s前" forKey:@"time"];
    [muDic setObject:[NSNumber numberWithLongLong:timestampSince1970()] forKey:@"timestamp"];
    [muDic setObject:@"" forKey:@"title"];
    [muDic setObject:[[xmppMessage elementForName:@"body"] stringValue]?:@"" forKey:@"content"];
    [muDic setObject:[xmppMessage fromStr]?:@"" forKey:@"from"];
    [muDic setObject:[xmppMessage toStr]?:@"" forKey:@"to"];
    [muDic setObject:[[xmppMessage elementForName:@"backJson"] stringValue]?:@"" forKey:@"extension"];
    [muDic setObject:@0 forKey:@"id"];
    [muDic setObject:@NO forKey:@"isRead"];
    
    return muDic;
}

#pragma mark -
@implementation Message

@dynamic time;
@dynamic timestamp;
@dynamic title;
@dynamic content;
@dynamic from;
@dynamic to;
@dynamic extension;
@dynamic id;
@dynamic isRead;

//- (NSDictionary *)toDictionary; {
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setObject:self.time forKey:@"time"];
//    [dic setObject:self.timestamp forKey:@"timestamp"];
//    [dic setObject:self.title forKey:@"title"];
//    [dic setObject:self.content forKey:@"content"];
//    [dic setObject:self.from forKey:@"from"];
//    [dic setObject:self.to forKey:@"to"];
//    [dic setObject:self.extension forKey:@"extension"];
//    [dic setObject:self.id forKey:@"id"];
//    [dic setObject:self.isRead forKey:@"isRead"];
//    return dic;
//}

+ (NSInteger)messageType:(NSString *)jsonString {
    if(!jsonString)
        return -1;
    
    NSDictionary *backDic = [RLJSON JSONObjectWithString:jsonString];
    return [[backDic objectForKey:@"backCode"] integerValue];
}
+ (NSInteger)messageTypeWithXMPPMessage:(XMPPMessage *)xmppMessage {
    NSString *json = [[[xmppMessage elementForName:@"dqcc"] elementForName:@"backJson"] stringValue];
    
    return [self messageType:json];
    
}

+ (NSString *)messageDeviceTokenWithXMPPMessage:(XMPPMessage *)xmppMessage {
    NSString *json = [[[xmppMessage elementForName:@"dqcc"] elementForName:@"backJson"] stringValue];
    if(!json)
        return nil;
    
    NSDictionary *backDic = [RLJSON JSONObjectWithString:json];

    return [backDic objectForKey:@"data"];
}

+ (NSInteger)messageFlag:(NSString *)jsonString {
    if(!jsonString)
        return -1;
    NSDictionary *backDic = [RLJSON JSONObjectWithString:jsonString];

    return [[backDic objectForKey:@"flag"] integerValue];
}
+ (NSInteger)messageFlagWithXMPPMessage:(XMPPMessage *)xmppMessage {
    NSString *json = [[[xmppMessage elementForName:@"dqcc"] elementForName:@"flag"] stringValue];
    
    return [self messageFlag:json];
}
@end
