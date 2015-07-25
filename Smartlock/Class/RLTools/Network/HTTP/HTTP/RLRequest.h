//
//  RLRequest.h
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLResponse.h"
#import "RLHTTPAPIClient.h"
#import "RLTypecast.h"

@interface RLRequest : NSObject
@property (nonatomic, assign) NSUInteger requestID;
@property (nonatomic, strong) NSString *requestDescription;

//+ (NSURLSessionDataTask *)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block;
+ (NSURLSessionDataTask *)requestWithUrl:(NSString *)url withParameters:(NSDictionary *)parameters andBlock:(void (^)(id responseObject, NSError *error)) block;
@end
