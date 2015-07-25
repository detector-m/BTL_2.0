//
//  BTLCommand.h
//  Smartlock
//
//  Created by RivenL on 15/7/24.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

extern Byte *btlCmdDateToBytes(int * const len, NSString * const dateString);
extern Byte *btlCmdDateNowToBytes(int * const len);

#pragma mark -

union cmd_mode {
    Byte cmd_common;
    Byte cmd_connection;
    Byte cmd_user_type;
    Byte cmd_broadcast_name_len;
    Byte cmd_keep;
};

union cmd_cmdFlag {
    Byte cmd_keep;    //发送时
    Byte cmd_result;  //响应时
};

@interface BTLCommand : NSObject {
    Byte _cmd_ST;
    
    Byte _cmd_code;
    union cmd_mode _cmd_mode;
    
    union cmd_cmdFlag _cmd_cmdFlag;
    
//    Byte _cmd_data_len;
//    Byte *_cmd_data;
    NSData *_cmd_data;
    
    Byte _cmd_CRC;
    Byte _cmd_END;
    
//    Byte _cmd_fixation_len;
}

+ (Byte)cmdFixationLen;

- (NSData *)toData;
- (Byte)cmd_ST;
- (Byte)cmd_CRC;
- (Byte)cmd_END;
- (Byte)cmd_code;

- (Byte)cmdBytesCRCCheckWithBytes:(const Byte *)data len:(int)length;
- (Byte)cmdCRCCheck;

- (void)setCmdData:(NSData *)data;
- (NSData *)cmdData;
@end
