//
//  BTLcmdResponse.m
//  Smartlock
//
//  Created by RivenL on 15/7/24.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BTLcmdResponse.h"

static Byte BL_responseData[240] = {0};

@implementation BTLcmdResponse
- (instancetype)initWithcmdResponseData:(NSData *)cmdResData {
    if(self = [super init]) {
        Byte *bytes = (Byte *)cmdResData.bytes;
        int length = cmdResData.length;
        if(bytes) {
            int i=0;
            _cmd_ST = bytes[i++];
            _cmd_code = bytes[i++];
            _cmd_mode.cmd_common = bytes[i++];
            _cmd_cmdFlag.cmd_result = bytes[i++];
            Byte data_len = bytes[i++];
            _cmd_data = [NSData dataWithBytes:&bytes length:data_len];
            memset(BL_responseData, 0, sizeof(BL_responseData));
            for(NSInteger j=i; i<j+data_len; i++) {
                BL_responseData[i-j] = bytes[i];
            }

            _cmd_CRC = bytes[length-2];
            _cmd_END = bytes[length-1];
        }
    }
    
    return self;
}

- (Byte)cmd_cmdResponseResult {
    return _cmd_cmdFlag.cmd_result;
}
@end
