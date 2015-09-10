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

#import "SendKeyWithABVC.h"

@implementation SendKeyVC
- (void)viewDidLoad {
    self.offsetEdge = 5;
    NSString *requestUrl = [NSString stringWithFormat:@"/bleLock/initSendKey.jhtml?accessToken=%@", encryptedTokenToBase64([User sharedUser].sessionToken, [User sharedUser].certificazte)/*[User sharedUser].sessionToken*/];
    if(self.lockID.length) {
        requestUrl = [requestUrl stringByAppendingFormat:@"&bleLockId=%@", self.lockID];
    }
    if(self.phone.length) {
        requestUrl = [requestUrl stringByAppendingFormat:@"&mobile=%@", self.phone];
    }
    self.url = [kRLHTTPAPIBaseURLString stringByAppendingString:requestUrl];
    
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button setImage:[UIImage imageNamed:@"ContactForSendKey.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.title = NSLocalizedString(@"发送钥匙", nil);
}


- (void)clickItem:(UIBarButtonItem *)item {
    SendKeyWithABVC *vc = [[SendKeyWithABVC alloc] init];
    vc.vc = self;
//    vc.lockId = self.lockId;
//    vc.filterItems = self.table.datas;
    vc.title = NSLocalizedString(@"通讯录", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

@end
