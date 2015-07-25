//
//  WebViewVC.h
//  Smartlock
//
//  Created by RivenL on 15/5/18.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BaseVC.h"

@interface WebViewVC : BaseVC <UIWebViewDelegate>
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIWebView *webView;

#pragma mark -
@property (assign) BOOL isWebViewLoaded;
@property (assign) BOOL isWebViewLoading;

#pragma mark -
- (void)loadRequest;
@end
