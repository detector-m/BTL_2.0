//
//  RLResponse.m
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLResponse.h"
#import "Login.h"

@implementation RLResponse
- (instancetype)initWithResponseObject:(id)responseObject {
    if(self = [super init]) {
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resDic = responseObject;
            self.resDescription = [resDic objectForKey:@"message"];
            self.status = [[resDic objectForKey:@"status"] integerValue];
        }
        else if([responseObject isKindOfClass:[NSArray class]] ) {
            
        }
        else if([responseObject isKindOfClass:[NSNumber class]]) {
            
        }
        else if ([responseObject isKindOfClass:[NSString class]]) {
            self.resDescription = responseObject;
            if([responseObject integerValue] != 0) {
                self.status = 1;
            }
        }
        
        [self checkStatus];
        [self dealStatus];
    }
    
    return self;
}

- (void)dealStatus {
    if(self.status == 0) {
        _success = YES;
        return;
    }
    
    DLog(@"status=%ld message = %@", (long)self.status, self.resDescription);
}

#pragma mark -
- (void)checkStatus {
    switch (self.status) {
        case 0:     //成功
            break;
            
        case -999: //用户没有登录，返回登录页面
            [Login hudAlertLogout];
            break;
            
        case -998: //访问的请求参数错误
            [RLHUD hudAlertErrorWithBody:@"请重新登录！"];
            break;
            
        case -500: //服务器内部错误
            [RLHUD hudAlertErrorWithBody:@"用户名或密码错误"];
            break;
        default:
            
            break;
    }
}

@end
