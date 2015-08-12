//
//  BannerDetailVC.m
//  Smartlock
//
//  Created by RivenL on 15/8/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BannerDetailVC.h"

@interface BannerDetailVC ()

@end

@implementation BannerDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
    
    [RLHUD hudProgressWithBody:nil onView:webView timeout:4.0f];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [super webViewDidFinishLoad:webView];
    
    [RLHUD hideProgress];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [super webView:webView didFailLoadWithError:error];
    
    [RLHUD hideProgress];
}
@end
