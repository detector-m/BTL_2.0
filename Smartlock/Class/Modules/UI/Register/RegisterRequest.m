//
//  RegisterRequest.m
//  Smartlock
//
//  Created by RivenL on 15/4/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RegisterRequest.h"

@implementation RegisterRequest
+ (void)verifyPhone:(NSString *)phone withBlock:(void (^)(id, NSError *))block {
#if 1
    NSDictionary *parameters = [RegisterModel verifyPhoneParametersWithPhone:phone];
    NSString *urlString = [[kRLHTTPAPIBaseURLString stringByAppendingString:@"/verifty/isMobileUse.jhtml"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    urlString = [[urlString stringByAppendingString:[NSString stringWithFormat:@"?%@=%@", [parameters allKeys].firstObject, [parameters objectForKey:[parameters allKeys].firstObject]]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0f];
    NSString *bodyString = [NSString stringWithFormat:@"%@=%@", [parameters allKeys].firstObject, [parameters objectForKey:[parameters allKeys].firstObject]];
    NSLog(@"%@?%@", urlString, bodyString);
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(data.length > 0 && connectionError == nil) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(dataString.length > 10) {
                block(@"2", connectionError);
            }
            else {
                block(dataString, connectionError);
            }
        }
        else {
            block(@"2", connectionError);
        }
    }];
#else
//    NSDictionary *parameters = [RegisterModel verifyPhoneParametersWithPhone:phone];
    NSString *urlString = @"http://www.dqcc.com.cn/new_img/fee643eb-1702-40f1-8445-62ade2531584.jpg";
    //    urlString = [[urlString stringByAppendingString:[NSString stringWithFormat:@"?%@=%@", [parameters allKeys].firstObject, [parameters objectForKey:[parameters allKeys].firstObject]]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0f];
//    NSString *bodyString = [NSString stringWithFormat:@"%@=%@", [parameters allKeys].firstObject, [parameters objectForKey:[parameters allKeys].firstObject]];
//    NSLog(@"%@?%@", urlString, bodyString);
//    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(data.length > 0 && connectionError == nil) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(dataString.length > 10) {
                block(@"2", connectionError);
            }
            else {
                block(dataString, connectionError);
            }
        }
        else {
            block(@"2", connectionError);
        }
    }];
    
#endif
}
+ (void)getAuthcode:(NSString *)phone withBlock:(void (^)(id, NSError *))block {
#if 0
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL isok = NO;
        NSDictionary *parameters = @{phone:@"number"};
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        [self requestWithUrl:@"verifty/isMobileUse.jhtml"  withParameters:parameters andBlock:^(id responseObject, NSError *error) {
            dispatch_semaphore_signal(sema);
            if(error) {
                block(responseObject, error);
            }
            else {
                if([responseObject integerValue] == 0) {
                    isok = YES;
                    block(@"10000", error);
                    return ;
                }
                block(responseObject, error);
            }
        }];
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        sema = nil;
        
        if(isok) {
            parameters = [RegisterModel getAuthcodeParametersWithPhone:phone];
            [self requestWithUrl:@"verifty/sendMobileAuthcode.jhtml"  withParameters:parameters andBlock:block];
        }
    });
#endif
    
    NSDictionary *parameters = [RegisterModel getAuthcodeParametersWithPhone:phone];
    [self requestWithUrl:@"verifty/sendMobileAuthcode.jhtml"  withParameters:parameters andBlock:block];
}

+ (void)verifyAuthcode:(NSString *)phone authcode:(NSString *)authcode withBlock:(void (^)(id, NSError *))block {
    NSDictionary *parameters = [RegisterModel verifyAuthcodeParametersWithPhone:phone andAuthcode:authcode];
    
    [self requestWithUrl:@"verifty/isMobileAuthcodeRight.jhtml"  withParameters:parameters andBlock:block];
}

+ (void)register:(RegisterModel *)aRegister withBlock:(void (^)(RegisterResponse *, NSError *))block {
    NSDictionary *parameters = aRegister.toDictionary;//[RegisterModel getAuthcodeParametersWithPhone:phone];
    
    [self requestWithUrl:@"member/regist.jhtml"  withParameters:parameters andBlock:block];
}
@end

@implementation RegisterRequest (FindPassword)
+ (void)findPassword:(FindPasswordModel *)findPasswordModel withBlock:(void (^)(RegisterResponse *, NSError *))block {
    NSDictionary *parameters = [findPasswordModel toDictionary];
    
    [self requestWithUrl:@"member/findPassword.jhtml" withParameters:parameters andBlock:block];
}
@end

