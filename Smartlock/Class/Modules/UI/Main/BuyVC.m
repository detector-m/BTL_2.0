//
//  BuyVC.m
//  Smartlock
//
//  Created by RivenL on 15/5/20.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BuyVC.h"
#import "RLHTTPAPIClient.h"

#define ShopLockPage @"shopLock.jsp"
@implementation BuyVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        NSString *requestUrl = [kRLHTTPMobileBaseURLString stringByAppendingString:ShopLockPage];
        self.url = requestUrl;
    }
    
    return self;
}
@end
