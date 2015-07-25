//
//  RLService.h
//  Smartlock
//
//  Created by RivenL on 15/3/13.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLPeripheral.h"
#import "CBUUID+StringExtraction.h"

@class RLCharacteristic;
/*----------------------------------------------------*/
#pragma mark - Callback types
typedef void (^RLServiceDiscoverCharacteristicsCallback)(NSArray *characteristics, NSError *error);
/*----------------------------------------------------*/

@interface RLService : NSObject
/*----------------------------------------------------*/
@property (nonatomic, readonly, strong) CBService *cbService;
@property (nonatomic, readonly, weak) CBPeripheral *cbPeripheral;
@property (nonatomic, readonly, weak) NSString *UUIDString;
@property (nonatomic, readonly, getter=isDiscoveringCharacteristics, assign) BOOL discoveringCharacteristics;
@property (nonatomic, strong) NSArray *characteristics;
/*----------------------------------------------------*/

/*----------------------------------------------------*/
#pragma mark - methods
- (instancetype)initWithService:(CBService *)service;

- (void)discoverCharacteristicsWithCompletion:(RLServiceDiscoverCharacteristicsCallback)callback;
- (void)discoverCharacteristicsWithUUIDs:(NSArray *)uuids completion:(RLServiceDiscoverCharacteristicsCallback)callback;

- (void)handleDiscoveredCharacteristics:(NSArray *)characteristics error:(NSError *)error;
- (RLCharacteristic *)wrapperByCharacteristic:(CBCharacteristic *)aChar;
/*----------------------------------------------------*/
@end
