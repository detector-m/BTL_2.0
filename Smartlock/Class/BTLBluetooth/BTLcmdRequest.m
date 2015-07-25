//
//  BTLcmdRequest.m
//  Smartlock
//
//  Created by RivenL on 15/7/24.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BTLcmdRequest.h"

@implementation BTLcmdRequest
- (instancetype)initWithCmdCode:(Byte)cmdCode withCmdMode:(Byte)cmdMode {
    if(self = [super init]) {
        _cmd_ST = 0x55;
        _cmd_code = cmdCode;
        _cmd_mode.cmd_common = cmdMode;
        _cmd_cmdFlag.cmd_keep = 0x00;
        _cmd_END = 0x66;
        
    }
    
    return self;
}
@end
