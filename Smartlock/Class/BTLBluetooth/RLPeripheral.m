//
//  RLPeripheral.m
//  Smartlock
//
//  Created by RivenL on 15/3/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLPeripheral.h"

/*notifications*/
NSString * const kRLPeripheralDidConnect = @"RLPeripheralDidConnect";
NSString * const kRLPeripheralDidDisconnect = @"RLPeripheralDidDisconnect";

/*error domains*/
NSString *kRLperipheralConnectionErrorDomain = @"RLPeripheralConnectionErrorDomain";

//error codes
const NSInteger kConnectionTimeoutErrorCode = 408;
const NSInteger kConnectionMissingErrorCode = 409;

NSString * const kConnectionTimeoutErrorMessage = @"BLE Device can't be connected by given interval";
NSString * const kConnectionMissingErrorMessage = @"BLE Device is not connected";


@interface RLPeripheral () <CBPeripheralDelegate>
/*----------------------------------------------------*/
@property (nonatomic, readwrite, strong) CBPeripheral *cbPeripheral;
@property (nonatomic, readwrite, strong) RLCentralManager *manager;

@property (nonatomic, readwrite, getter=isDiscoveringServices) BOOL discoveringServices;
@property (nonatomic, readwrite, strong) NSArray *services;

@property (nonatomic, readwrite, assign) BOOL watchDogRaised;
/*----------------------------------------------------*/

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

@property (atomic, copy) RLPeripheralConnectionCallback connectionBlock;
@property (atomic, copy) RLPeripheralConnectionCallback disconnectBlock;
@property (atomic, copy) RLPeripheralDiscoverServicesCallback discoverServicesBlock;
@property (atomic, copy) RLperipheralRSSIValueCallback RSSIValueBlock;
@end

@implementation RLPeripheral
/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/
- (void)dealloc {
    self.connectionBlock = nil;
    self.disconnectBlock = nil;
    self.discoverServicesBlock = nil;
    self.RSSIValueBlock = nil;
}

- (instancetype)initWithPeripheral:(CBPeripheral *)aPeripheral manager:(RLCentralManager *)manager
{
    if (self = [super init]) {
        self.cbPeripheral = aPeripheral;
        self.cbPeripheral.delegate = self;
        self.manager = manager;
    }
    return self;
}

/*----------------------------------------------------*/
#pragma mark - Getter/Setter -
/*----------------------------------------------------*/
- (BOOL)isConnected {
    return self.cbPeripheral.state == CBPeripheralStateConnected;
}

- (NSString *)UUIDString {
    return [self.cbPeripheral.identifier UUIDString];
}

- (NSString *)name {
//    return self.cbPeripheral.name;
    return self.advName;
}

- (NSString *)advName {
    return self.advertisingData[@"kCBAdvDataLocalName"];
}

/*----------------------------------------------------*/
#pragma mark - Overide Methods -
/*----------------------------------------------------*/
- (NSString *)description {
    NSString *org = [super description];
    
    return [org stringByAppendingFormat:@" UUIDString: %@", self.UUIDString];
}

/*----------------------------------------------------*/
#pragma mark - Public Methods -
/*----------------------------------------------------*/
- (void)disconnectWithCompletion:(RLPeripheralConnectionCallback)callback {
    self.disconnectBlock = callback;
    [self.manager.manager cancelPeripheralConnection:self.cbPeripheral];
}
- (void)connectWithCompletion:(RLPeripheralConnectionCallback)callback {
    self.watchDogRaised = NO;
    self.connectionBlock = callback;
    [self.manager.manager connectPeripheral:self.cbPeripheral options:nil];
}
- (void)connectwithTimeout:(NSUInteger)watchDogInterval completion:(RLPeripheralConnectionCallback)callback {
    [self connectWithCompletion:callback];
    [self performSelector:@selector(connectionWatchDogFired) withObject:nil afterDelay:watchDogInterval];
}

- (void)discoverServicesWithCompletion:(RLPeripheralDiscoverServicesCallback)callback {
    [self discoverServices:nil completion:callback];
}
- (void)discoverServices:(NSArray *)serviceUUIDs completion:(RLPeripheralDiscoverServicesCallback)callback {
    self.discoverServicesBlock = callback;
    if(self.isConnected) {
        self.discoveringServices = YES;
        [self.cbPeripheral discoverServices:serviceUUIDs];
    }
    else if(self.discoverServicesBlock) {
        self.discoverServicesBlock(nil, [self connectionErrorWithCode:kConnectionMissingErrorCode message:kConnectionMissingErrorMessage]);

        self.discoverServicesBlock = nil;
    }
}

- (void)readRSSIValueCompletion:(RLperipheralRSSIValueCallback)callback {
    self.RSSIValueBlock = callback;
    if(self.isConnected) {
        [self.cbPeripheral readRSSI];
    }
    else if (self.RSSIValueBlock){
        self.RSSIValueBlock(nil, [self connectionErrorWithCode:kConnectionMissingErrorCode message:kConnectionMissingErrorMessage]);
        self.RSSIValueBlock = nil;
    }
}

/*----------------------------------------------------*/
#pragma mark - Handler Methods -
/*----------------------------------------------------*/
- (void)handleConnectionWithError:(NSError *)error {
    // connection was made, canceling watchdog
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionWatchDogFired) object:nil];
    
    if(self.connectionBlock) {
        self.connectionBlock(error);
    }
    self.connectionBlock = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kRLPeripheralDidConnect object:self userInfo:@{@"error" : error ? : [NSNull null]}];
}
- (void)handleDisconnectWithError:(NSError *)error {
    if(self.disconnectBlock) {
        self.disconnectBlock(error);
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRLPeripheralDidDisconnect object:self userInfo:@{@"error" : error ? : [NSNull null]}];
    }
    
    self.disconnectBlock = nil;
}

/*----------------------------------------------------*/
#pragma mark - Error Generators -
/*----------------------------------------------------*/
- (NSError *)connectionErrorWithCode:(NSInteger)code message:(NSString *)msg {
    return [NSError errorWithDomain:kRLperipheralConnectionErrorDomain code:code userInfo:nil];
}

/*----------------------------------------------------*/
#pragma mark - Private Methods -
/*----------------------------------------------------*/
- (void)connectionWatchDogFired {
    self.watchDogRaised = YES;
    __weak RLPeripheral *weakSelf = self;
    [self disconnectWithCompletion:^(NSError *error) {
        __strong RLPeripheral *strongSelf = weakSelf;
        if(strongSelf.connectionBlock) {
            strongSelf.connectionBlock([self connectionErrorWithCode:kConnectionTimeoutErrorCode message:kConnectionTimeoutErrorMessage]);
        }
        self.connectionBlock = nil;
    }];
}

- (void)updateServiceWrappers {
    NSMutableArray *updateServices = [NSMutableArray new];
    for(CBService *service in self.cbPeripheral.services) {
        [updateServices addObject:[[RLService alloc] initWithService:service]];
    }
    self.services = updateServices;
}

- (RLService *)wrapperByServices:(CBService *)service {
    RLService *wrapper = nil;
    for(RLService *discovered in self.services) {
        if(discovered.cbService == service) {
            wrapper = discovered;
            break;
        }
    }
    
    return wrapper;
}

#pragma mark -
- (void)setDisconnectCallbackBlock:(RLPeripheralConnectionCallback)block {
    self.disconnectBlock = block;
}
/*----------------------------------------------------*/
#pragma mark - CBPeripheral Delegate -
/*----------------------------------------------------*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.discoveringServices = NO;
        [self updateServiceWrappers];
        
//        for(RLService *aService in self.services) {
//            NSLog(@"service discovered - %@", aService.cbService);
//        }
        
        if(self.discoverServicesBlock) {
            self.discoverServicesBlock(self.services, error);
        }
        self.discoverServicesBlock = nil;
    });
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self wrapperByServices:service] handleDiscoveredCharacteristics:service.characteristics error:error];
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic: (CBCharacteristic *)characteristic error:(NSError *)error {
    NSData *value = [characteristic.value copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self wrapperByServices:characteristic.service] wrapperByCharacteristic:characteristic] handleReadValue:value error:error];
    });
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self wrapperByServices:characteristic.service] wrapperByCharacteristic:characteristic] handleWrittenValueWithError:error];
    });
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self wrapperByServices:characteristic.service] wrapperByCharacteristic:characteristic] handleSetNotifiedWithError:error];
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.RSSIValueBlock) {
            self.RSSIValueBlock(peripheral.RSSI, error);
        }
        self.RSSIValueBlock = nil;
    });
}
@end
