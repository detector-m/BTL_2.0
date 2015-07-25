//
//  RLRequest.m
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLRequest.h"

#import "RLHUD.h"

@implementation RLRequest

+ (NSURLSessionDataTask *)requestWithUrl:(NSString *)url withParameters:(NSDictionary *)parameters andBlock:(void (^)(id responseObject, NSError * error)) block {
    return [[RLHTTPAPIClient sharedClient] POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [RLHUD hideProgress];
        if(block) {
            RLResponse *response = [[RLResponse alloc] initWithResponseObject:responseObject];
            if(response.success || response.status > 0) {
                block(responseObject, nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [RLHUD hideProgress];
        if(block) {
            DLog(@"%@", error);
            block(@"Error", error);
            if(error.code == NSURLErrorNotConnectedToInternet) {
                return ;
            }
            [RLHUD hudAlertErrorWithBody:@"网络有问题！请检查网络"];
        }
    }];
}
@end
