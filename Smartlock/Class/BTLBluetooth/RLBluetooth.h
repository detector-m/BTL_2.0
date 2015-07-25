//
//  RLBluetooth.h
//  Smartlock
//
//  Created by RivenL on 15/3/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLCharacteristic.h"
#import "RLPeripheral.h"
#import "BluetoothLockCommand.h"
#import "RLPeripheralRequest.h"
#import "RLPeripheralResponse.h"
#import "RLDate.h"

@interface RLBluetooth : NSObject
@property (nonatomic, readonly, weak) NSArray *peripherals;

@property (nonatomic, readonly, strong) RLCentralManager *manager;

#pragma mark -
+ (instancetype)sharedBluetooth;
+ (void)sharedRelease;

#pragma mark -
- (BOOL)bluetoothIsReady;
- (BOOL)isSupportBluetoothLow;

#pragma mark -
- (void)scanPeripheralsWithCompletionBlock:(void (^)(NSArray *peripherals))completionCallback;
//- (void)removePeripherals;

- (void)connectPeripheral:(RLPeripheral *)peripheral withConnectedBlock:(void (^)(NSError *error))callback;
- (void)disconnectAllPeripherals;
- (void)disconnectPeripheral:(RLPeripheral *)peripheral;

- (void)discoverPeripheralServicesWithPeripheral:(RLPeripheral *)peripheral;
- (void)discoverServiceCharacteristicsWithService:(RLService *)service;

#pragma mark - set notify for character 
- (void)openNotifyForPeripheral:(RLPeripheral *)peripheral withPeripheralRequest:(RLPeripheralRequest *)peripheralRequest completion:(void(^)(NSError *error))notifyCompletion  onUpdateData:(void (^)(RLPeripheralResponse *peripheralRes, NSError *error))updateDataCallback withDisconnect:(void(^)(NSError *error))disconnectCallback;

- (void)connectPeripheralThanHandlePeripheral:(RLPeripheral *)peripheral withPeripheralRequest:(RLPeripheralRequest *)peripheralRequest connectionCompletion:(void(^)(NSError *error))connectionCompletion notifyCompletion:(void(^)(NSError *error))notifyCompletion  onUpdateData:(void (^)(RLPeripheralResponse *peripheralRes, NSError *error))updateDataCallback withDisconnect:(void(^)(NSError *error))disconnectCallback;

#pragma mark -
- (void)writeDataToCharacteristic:(RLCharacteristic *)characteristic withData:(NSData *)data;
- (void)writeDataToCharacteristic:(RLCharacteristic *)characteristic cmdCode:(Byte)cmdCode cmdMode:(Byte)cmdMode withDatas:(NSData *)data;

#pragma mark btl
#pragma mark - set notify for character
- (void)btlOpenNotifyForPeripheral:(RLPeripheral *)peripheral withPeripheralRequest:(RLPeripheralRequest *)peripheralRequest completion:(void(^)(NSError *error))notifyCompletion  onUpdateData:(void (^)(RLPeripheralResponse *peripheralRes, NSError *error))updateDataCallback withDisconnect:(void(^)(NSError *error))disconnectCallback;

- (void)btlConnectPeripheralThanHandlePeripheral:(RLPeripheral *)peripheral withPeripheralRequest:(RLPeripheralRequest *)peripheralRequest connectionCompletion:(void(^)(NSError *error))connectionCompletion notifyCompletion:(void(^)(NSError *error))notifyCompletion  onUpdateData:(void (^)(RLPeripheralResponse *peripheralRes, NSError *error))updateDataCallback withDisconnect:(void(^)(NSError *error))disconnectCallback;


#pragma mark -
- (RLPeripheral *)peripheralForName:(NSString *)name;
- (RLPeripheral *)peripheralForUUIDString:(NSString *)uuidString;
- (RLService *)serviceForUUIDString:(NSString *)uuidString withPeripheral:(RLPeripheral *)peripheral;
- (RLCharacteristic *)characteristicForUUIDString:(NSString *)uuidString withService:(RLService *)service;
- (RLCharacteristic *)characteristicForNotifyWithService:(RLService *)service;

#pragma mark - appmethod
- (RLCharacteristic *)characteristicForNotifyWithPeripheralName:(NSString *)peripheralName;

@end
