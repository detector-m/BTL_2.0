//
//  RLHTTPAPIClient.m
//  Smartlock
//
//  Created by RivenL on 15/4/9.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLHTTPAPIClient.h"

//NSString * const kRLHTTPAPIBaseURLString = @"http://192.168.1.250:8080/mobile/api/v20";
//NSString * const kRLHTTPMobileBaseURLString = @"http://192.168.1.250:8080/mobile/";
NSString * const kRLHTTPAPIBaseURLString = @"http://www.dqcc.com.cn/mobile/api/v20";
NSString * const kRLHTTPMobileBaseURLString = @"http://www.dqcc.com.cn/mobile/";

@implementation RLHTTPAPIClient
+ (instancetype)sharedClient {
    static RLHTTPAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kRLHTTPAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}
@end
