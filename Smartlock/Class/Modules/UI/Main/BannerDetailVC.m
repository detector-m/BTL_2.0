//
//  BannerDetailVC.m
//  Smartlock
//
//  Created by RivenL on 15/8/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BannerDetailVC.h"
#import "CustomURLCache.h"

@interface BannerDetailVC ()

@end

@implementation BannerDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadRequest {
    if(!self.isWebViewLoaded && !self.isWebViewLoading) {
        self.isWebViewLoading = YES;
        [self.webView loadRequest:[self requestForWebContent:self.url]];
    }
}

- (NSURLRequest *)requestForWebContent:(NSString *)aUrl {
    NSURL *destUrl = [NSURL URLWithString:[aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:destUrl];
    if(!request.URL.absoluteString.length)
        [[CustomURLCache sharedURLCache] removeCachedResponseForRequest:request];
    return request;
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
