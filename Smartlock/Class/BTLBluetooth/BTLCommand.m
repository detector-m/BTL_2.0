//
//  BTLCommand.m
//  Smartlock
//
//  Created by RivenL on 15/7/24.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BTLCommand.h"
static Byte date[6] = {0};
#pragma mark -
NSDate *btlCmdDateFromString(NSString *dateString) {
    if(!dateString || dateString.length == 0) {
        return nil;
    }
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    dateformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateformatter dateFromString:dateString];
    
    return date;
}

#pragma mark -
NSDateComponents *btlCmdDateComponentsWithDate(NSDate *date) {
    if(!date)
        return nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    return dateComponents;
}

NSDateComponents *btlCmdDateComponentsNow() {
    NSDate *date = [NSDate date];
    
    return btlCmdDateComponentsWithDate(date);
}

void btlCmdfillDateDatas(Byte *dateDatas, int len, NSDateComponents *dateComponents) {
    int i = 0;
    dateDatas[i++] = dateComponents.year - 2000;
    dateDatas[i++] = dateComponents.month;
    dateDatas[i++] = dateComponents.day;
    dateDatas[i++] = dateComponents.hour;
    dateDatas[i++] = dateComponents.minute;
    dateDatas[i] = dateComponents.second;
}

Byte *btlCmdDateToBytes(int * const len, NSString * const dateString) {
    if(!len || !dateString || dateString.length == 0)
        return NULL;
    NSDateComponents *dateComponents = btlCmdDateComponentsWithDate(btlCmdDateFromString(dateString));
    *len = sizeof(date);
    btlCmdfillDateDatas(date, *len, dateComponents);
    
    return date;
}

Byte *btlCmdDateNowToBytes(int * const len) {
    if(!len)
        return NULL;
    NSDateComponents *dateComponents = btlCmdDateComponentsNow();
    *len = sizeof(date);
    
    btlCmdfillDateDatas(date, *len, dateComponents);
    
    return date;
}

@implementation BTLCommand
+ (Byte)cmdFixationLen {
    return 7;
}

- (instancetype)initWithCmdCode:(Byte)cmdCode withCmdMode:(union cmd_mode)cmdMode {
    if(self = [super init]) {
        _cmd_ST = 0x55;
        _cmd_code = cmdCode;
        _cmd_mode.cmd_common = cmdMode.cmd_common;
        _cmd_cmdFlag.cmd_keep = 0x00;
        _cmd_END = 0x66;
        
//        _cmd_fixation_len = [[self class] cmdFixationLen];
    }
    
    return self;
}

- (Byte)cmd_ST {
    return _cmd_ST;
}
- (Byte)cmd_CRC {
    return [self cmdCRCCheck];
}
- (Byte)cmd_END {
    return _cmd_END;
}
- (Byte)cmd_code {
    return _cmd_code;
}

- (void)setCmdData:(NSData *)data {
    _cmd_data = data;
}

- (NSData *)cmdData {
    return _cmd_data;
}

- (Byte)cmdCRCCheck {
    Byte crc = 0x00;
    
    crc += _cmd_ST;
    crc += _cmd_code;
    crc += _cmd_mode.cmd_connection;
    crc += _cmd_cmdFlag.cmd_keep;
    
    crc += _cmd_data.length;
    
    crc += [self cmdBytesCRCCheckWithBytes:(Byte *)_cmd_data.bytes len:(int)_cmd_data.length];
    
    _cmd_CRC = crc;
    return crc;
}

- (Byte)cmdBytesCRCCheckWithBytes:(const Byte *)data len:(int)length {
    if(!data || !length) {
        return 0x00;
    }
    Byte crcTemp = 0x00;
    for(int i=0; i<length; i++) {
        crcTemp += data[i];
    }
    
    return crcTemp;
}

- (NSData *)toData {
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&_cmd_ST length:1];
    [data appendBytes:&_cmd_code length:1];
    [data appendBytes:&(_cmd_mode.cmd_common) length:1];
    [data appendBytes:&(_cmd_cmdFlag.cmd_result) length:1];
    Byte dataLen = _cmd_data.length;
    [data appendBytes:&dataLen length:1];
    [data appendData:_cmd_data];
    [data appendBytes:&_cmd_CRC length:1];
    [data appendBytes:&_cmd_END length:1];
    
    return data;
}

@end
