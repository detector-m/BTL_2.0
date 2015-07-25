//
//  RLPeripheral.h
//  Smartlock
//
//  Created by RivenL on 15/3/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLCentralManager.h"

#import "RLService.h"
#import "RLCharacteristic.h"

#define PeripheralPreStr @"YJLOCK"
/*----------------------------------------------------*/
#pragma mark - Callback types 
typedef void (^RLPeripheralConnectionCallback)(NSError *error);
typedef void (^RLPeripheralDiscoverServicesCallback)(NSArray *services, NSError *error);
typedef void (^RLperipheralRSSIValueCallback)(NSNumber *RSSI, NSError *error);;
/*----------------------------------------------------*/

@interface RLPeripheral : NSObject
/*----------------------------------------------------*/
#pragma mark -
@property (nonatomic, readonly, strong) CBPeripheral *cbPeripheral;
@property (nonatomic, readonly, strong) RLCentralManager *manager;

@property (nonatomic, readonly, getter=isDiscoveringServices) BOOL discoveringServices;
@property (nonatomic, readonly, strong) NSArray *services;

@property (nonatomic, readonly, weak) NSString *UUIDString;
@property (nonatomic, readonly, weak) NSString *name;
@property (nonatomic, readonly, weak) NSString *advName;

@property (nonatomic, readonly, assign) BOOL watchDogRaised;

@property (nonatomic, assign) NSInteger RSSI;

@property (nonatomic, strong) NSDictionary *advertisingData;
/*----------------------------------------------------*/

/*----------------------------------------------------*/
#pragma mark - methods
- (instancetype)initWithPeripheral:(CBPeripheral *)aPeripheral
                           manager:(RLCentralManager *)manager;

- (void)disconnectWithCompletion:(RLPeripheralConnectionCallback)callback;
- (void)connectWithCompletion:(RLPeripheralConnectionCallback)callback;
- (void)connectwithTimeout:(NSUInteger)watchDogInterval completion:(RLPeripheralConnectionCallback)callback;

- (void)discoverServicesWithCompletion:(RLPeripheralDiscoverServicesCallback)callback;
- (void)discoverServices:(NSArray *)serviceUUIDs completion:(RLPeripheralDiscoverServicesCallback)callback;

- (void)readRSSIValueCompletion:(RLperipheralRSSIValueCallback)callback;

- (void)handleConnectionWithError:(NSError *)error;
- (void)handleDisconnectWithError:(NSError *)error;
/*----------------------------------------------------*/

#pragma mark -
- (void)setDisconnectCallbackBlock:(RLPeripheralConnectionCallback)block;
@end
