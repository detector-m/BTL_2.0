//
//  SendKeyVC.h
//  Smartlock
//
//  Created by RivenL on 15/5/5.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "WebViewVC.h"

@interface SendKeyVC : WebViewVC
//@property (nonatomic, assign)
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *lockID;
@end
