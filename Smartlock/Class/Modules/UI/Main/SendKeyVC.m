//
//  SendKeyVC.m
//  Smartlock
//
//  Created by RivenL on 15/5/5.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "SendKeyVC.h"

#import "RLHTTPAPIClient.h"
#import "RLSecurityPolicy.h"

@implementation SendKeyVC
//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        NSString *requestUrl = [NSString stringWithFormat:@"/bleLock/initSendKey.jhtml?accessToken=%@", encryptedTokenToBase64([User sharedUser].sessionToken, [User sharedUser].certificazte)/*[User sharedUser].sessionToken*/];
//        self.url = [kRLHTTPAPIBaseURLString stringByAppendingString:requestUrl];
//    }
//    
//    return self;
//}

- (void)viewDidLoad {
    NSString *requestUrl = [NSString stringWithFormat:@"/bleLock/initSendKey.jhtml?accessToken=%@", encryptedTokenToBase64([User sharedUser].sessionToken, [User sharedUser].certificazte)/*[User sharedUser].sessionToken*/];
    if(self.lockID.length) {
        requestUrl = [requestUrl stringByAppendingFormat:@"&bleLockId=%@", self.lockID];
    }
    if(self.phone.length) {
        requestUrl = [requestUrl stringByAppendingFormat:@"&mobile=%@", self.phone];
    }
    self.url = [kRLHTTPAPIBaseURLString stringByAppendingString:requestUrl];
    
    [super viewDidLoad];
}

@end
