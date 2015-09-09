//
//  BluetoothLockCommand.m
//  Smartlock
//
//  Created by RivenL on 15/5/6.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BluetoothLockCommand.h"

Byte get_cmd_CRC_fromCmdBytes(Byte *bytes, NSInteger len) {
    if(!len || len < 2 || !bytes) {
        return 0x00;
    }
    
    return bytes[len-2];
}
Byte get_cmd_ST_fromCmdBytes(Byte *bytes, NSInteger len) {
    if(!len || !bytes) {
        return 0x00;
    }
    
    return bytes[0];
}
Byte get_cmd_END_fromCmdBytes(Byte *bytes, NSInteger len) {
    if(!len || len < 1 || !bytes) {
        return 0x00;
    }
    
    return bytes[len-1];
}

Byte *append_bytes_to_bytes(Byte *dest_bytes, Byte *o1, int o1Len, Byte *o2, int o2Len) {
    if(dest_bytes) {
        Byte *o_dest_bytes = dest_bytes;
        if(o1) {
            memcpy(o_dest_bytes, o1, o1Len);
            o_dest_bytes += o1Len;
        }
        
        if(o2) {
            memcpy(o_dest_bytes, o2, o2Len);
        }
    }
    return dest_bytes;
}


Byte get_cmd_fixationLen() {
    return 7;
}

struct btl_cmd get_cmd(Byte cmdCode, union btl_cmd_mode mode) {
    struct btl_cmd cmd = {0};
    
    cmd.btl_cmd_ST = 0x55;
    cmd.btl_cmd_code = cmdCode;
    cmd.btl_cmd_mode.common = mode.common;
    cmd.btl_cmd_result.keep = 0x00;
    cmd.btl_cmd_END = 0x66;
    
    cmd.btl_cmd_fixation_len = get_cmd_fixationLen();
    
    return cmd;
}

Byte cmd_crc_check(struct btl_cmd *cmd) {
    Byte crc = 0x00;
    if(!cmd)
        return crc;
    
    crc += cmd->btl_cmd_ST;
    crc += cmd->btl_cmd_code;
    crc += cmd->btl_cmd_mode.connection;
    crc += cmd->btl_cmd_result.keep;
    
    crc += cmd->btl_cmd_data_len;
    
    crc += bytes_crc_check(cmd->btl_cmd_data, cmd->btl_cmd_data_len);
    
    return crc;
}

Byte bytes_crc_check(const Byte *data, NSInteger length) {
    if(!data || !length) {
        return 0x00;
    }
    Byte crcTemp = 0x00;
    for(NSInteger i=0; i<length; i++) {
        crcTemp += data[i];
    }
    
    return crcTemp;
}


Byte *wrapp_cmd_to_bytes(struct btl_cmd *cmd, Byte bytes[]) {
    if(!cmd || !bytes)
        return NULL;
    NSInteger i=0;
    bytes[i++] = cmd->btl_cmd_ST;
    bytes[i++] = cmd->btl_cmd_code;
    bytes[i++] = cmd->btl_cmd_mode.common;
    bytes[i++] = cmd->btl_cmd_result.keep;
    bytes[i++] = cmd->btl_cmd_data_len;
    for(NSInteger j=i; i<j+cmd->btl_cmd_data_len; i++) {
        bytes[i] = cmd->btl_cmd_data[i-j];
    }
    bytes[i++] = cmd->btl_cmd_CRC;
    bytes[i] = cmd->btl_cmd_END;
    
    return bytes;
}

BOOL wrapp_cmd_datas_to_bytes(long long int *data, Byte bytes[], NSInteger len) {
    if(!data || !bytes || sizeof(long long int) != len) {
        return NO;
    }
    
    bytes = (UInt8 *)&data;
    
    return YES;
}

BOOL free_cmd_data(const Byte *data) {
    if(data) {
        free((void *)data);
    }
    
    return YES;
}

static Byte date[6] = {0};
#pragma mark -
NSDate *btl_dateFromString(NSString *dateString) {
    if(!dateString || dateString.length == 0) {
        return nil;
    }
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
//    [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    dateformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateformatter dateFromString:dateString];
    
    return date;
}

#pragma mark -
NSDateComponents *btl_dateComponentsWithDate(NSDate *date) {
    if(!date)
        return nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    return dateComponents;
}

NSDateComponents *btl_dateComponentsNow() {
    NSDate *date = [NSDate date];
    
    return btl_dateComponentsWithDate(date);
}

void fillDateDatas(Byte *dateDatas, int len, NSDateComponents *dateComponents) {
    int i = 0;
    dateDatas[i++] = dateComponents.year - 2000;
    dateDatas[i++] = dateComponents.month;
    dateDatas[i++] = dateComponents.day;
    dateDatas[i++] = dateComponents.hour;
    dateDatas[i++] = dateComponents.minute;
    dateDatas[i] = dateComponents.second;
}

Byte *dateToBytes(int * const len, NSString * const dateString) {
    if(!len || !dateString || dateString.length == 0)
        return NULL;
    NSDateComponents *dateComponents = btl_dateComponentsWithDate(btl_dateFromString(dateString));
    *len = sizeof(date);
    fillDateDatas(date, *len, dateComponents);
    
    return date;
}

Byte *dateNowToBytes(int * const len) {
    if(!len)
        return NULL;
    NSDateComponents *dateComponents = btl_dateComponentsNow();
    *len = sizeof(date);
    
    fillDateDatas(date, *len, dateComponents);
    
    return date;
}

#pragma mark -
//cmd response
static Byte btl_cmd_responseData[240] = {0};
btl_cmd_response cmd_response_with_bytes(Byte *bytes, NSInteger length) {
    btl_cmd_response response = {0};
    if(bytes && length) {
        NSInteger i=0;
        response.btl_cmd_ST = bytes[i++];
        response.btl_cmd_code = bytes[i++];
        response.btl_cmd_mode.common = bytes[i++];
        response.btl_cmd_result.result = bytes[i++];
        response.btl_cmd_data_len = bytes[i++];
        memset(btl_cmd_responseData, 0, sizeof(btl_cmd_responseData));
        for(NSInteger j=i; i<j+response.btl_cmd_data_len; i++) {
            btl_cmd_responseData[i-j] = bytes[i];
        }
        response.btl_cmd_data = btl_cmd_responseData;
        response.btl_cmd_CRC = bytes[length-2];
        response.btl_cmd_END = bytes[length-1];
        response.btl_cmd_fixation_len = get_cmd_fixationLen();
    }
    return response;
}

Byte cmd_response_crc_check(const Byte *data, NSInteger length) {
    return bytes_crc_check(data, length);
}