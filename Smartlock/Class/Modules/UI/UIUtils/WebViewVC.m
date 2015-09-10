//
//  WebViewVC.m
//  Smartlock
//
//  Created by RivenL on 15/5/18.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "WebViewVC.h"
#import "AFNetworkReachabilityManager.h"
#import "CustomURLCache.h"

@interface WebViewVC ()
@end
@implementation WebViewVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    self.webView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _offsetEdge = 5;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachable:) name:AFNetworkingReachabilityDidChangeNotification object:nil];

    [self setupWebView];
}

- (void)setupWebView {
    CGRect frame = self.view.frame;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(_offsetEdge, 0, frame.size.width-_offsetEdge*2, frame.size.height)];
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    [self.view addSubview:self.webView];
    [self loadRequest];
}

- (void)loadRequest {
    if(!self.isWebViewLoaded && !self.isWebViewLoading) {
        self.isWebViewLoading = YES;
        [self.webView loadRequest:[self requestForWebContent:self.url]];
    }
}

- (NSURLRequest *)requestForWebContent:(NSString *)aUrl {
    DLog(@"%@", aUrl);
//    aUrl = @"http://www.baidu.com";
    NSURL *destUrl = [NSURL URLWithString:[aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:destUrl];
    return request;
}

#pragma mark ----------- network status changed
- (void)networkReachable:(id)sender {
    NSNotification *notification = sender;
    NSDictionary *dic = notification.userInfo;

    NSInteger status = [[dic objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if(status > 0) {
        [self loadRequest];
    }
    else {
        [self.webView stopLoading];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.isWebViewLoaded = NO;
    self.isWebViewLoading = YES;
    [RLHUD hudStatusBarProgress];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.isWebViewLoaded = YES;
    self.isWebViewLoading = NO;
    
    [RLHUD hideStatusBarProgress];
    
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width];
    [webView stringByEvaluatingJavaScriptFromString:meta];
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"error=%@", error);
    self.isWebViewLoaded = NO;
    self.isWebViewLoading = NO;
    [RLHUD hideStatusBarProgress];
}
@end
