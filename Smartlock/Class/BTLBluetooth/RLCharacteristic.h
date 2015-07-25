//
//  RLCharacteristic.h
//  Smartlock
//
//  Created by RivenL on 15/3/13.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLService.h"
/*----------------------------------------------------*/
#pragma mark - Callback types
typedef void (^RLCharacteristicReadCallback)(NSData *data, NSError *error);
typedef void (^RLCharacteristicNotifyCallback)(NSError *error);
typedef void (^RLCharacteristicWriteCallback)(NSError *error);
/*----------------------------------------------------*/

@interface RLCharacteristic : NSObject
/*----------------------------------------------------*/
@property (nonatomic, readonly, strong) CBCharacteristic *cbCharacteristic;

@property (nonatomic, readonly, weak) NSString *UUIDString;

@property (nonatomic, readonly, assign) BOOL notified;
/*----------------------------------------------------*/

/*----------------------------------------------------*/
#pragma mark - method
- (instancetype)initWithCharacteristic:(CBCharacteristic *)aCharacteristic;

- (void)setNotifyValue:(BOOL)notifyValue
            completion:(RLCharacteristicNotifyCallback)callback;
- (void)setNotifyValue:(BOOL)notifyValue
            completion:(RLCharacteristicNotifyCallback)nCallback
              onUpdate:(RLCharacteristicReadCallback)rCallback;

- (void)writeValue:(NSData *)data
        completion:(RLCharacteristicWriteCallback)wCallback;
- (void)writeByte:(int8_t)byte
       completion:(RLCharacteristicWriteCallback)wCallback;

- (void)readValueWithCompletionBlock:(RLCharacteristicReadCallback)rCallback;

/************* used for input events ************/
- (void)handleSetNotifiedWithError:(NSError *)error;
- (void)handleWrittenValueWithError:(NSError *)error;
- (void)handleReadValue:(NSData *)value error:(NSError *)error;
/*----------------------------------------------------*/
@end
