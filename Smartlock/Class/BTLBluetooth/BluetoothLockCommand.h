//
//  BluetoothLockCommand.h
//  Smartlock
//
//  Created by RivenL on 15/5/6.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BluetoothPackageSize (20)
/*cmd*/
union btl_cmd_mode {
    Byte common;
    Byte connection;
    Byte user_type;
    Byte broadcast_name_len;
    Byte keep;
};
struct btl_cmd {
    Byte btl_cmd_ST;
    
    Byte btl_cmd_code;
    union btl_cmd_mode btl_cmd_mode;
    
    union btl_cmd_result {
        Byte keep;
        Byte result;
    }btl_cmd_result;
    
    Byte btl_cmd_data_len;
    Byte *btl_cmd_data;
    
    Byte btl_cmd_CRC;
    Byte btl_cmd_END;
    
    Byte btl_cmd_fixation_len;
};

extern Byte get_cmd_CRC_fromCmdBytes(Byte *bytes, NSInteger len);
extern Byte get_cmd_ST_fromCmdBytes(Byte *bytes, NSInteger len);
extern Byte get_cmd_END_fromCmdBytes(Byte *bytes, NSInteger len);

extern Byte *append_bytes_to_bytes(Byte *dest_bytes, Byte *o1, int o1Len, Byte *o2, int o2Len);

extern Byte get_cmd_fixationLen();
extern struct btl_cmd get_cmd(Byte cmdCode, union btl_cmd_mode mode);
extern Byte cmd_crc_check(struct btl_cmd *cmd);
extern Byte bytes_crc_check(const Byte *data, NSInteger length);
extern Byte *wrapp_cmd_to_bytes(struct btl_cmd *cmd, Byte bytes[]);
extern BOOL wrapp_cmd_datas_to_bytes(long long int *data, Byte bytes[], NSInteger len);
extern BOOL free_cmd_data(const Byte *data);

extern Byte *dateToBytes(int * const len, NSString * const dateString);
extern Byte *dateNowToBytes(int * const len);

//cmd response
typedef struct btl_cmd btl_cmd_response;

extern btl_cmd_response cmd_response_with_bytes(Byte *bytes, NSInteger length);
extern Byte cmd_response_crc_check(const Byte *data, NSInteger length);