//
//  RLCentralManager.h
//  Smartlock
//
//  Created by RivenL on 15/3/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/*----------------------------------------------------*/
#pragma mark - Callback types
typedef void (^RLCentralManagerDiscoverPeripheralsCallback)(NSArray *peripherals);
/*----------------------------------------------------*/

@interface RLCentralManager : NSObject
@property (nonatomic, getter=isScanning) BOOL scanning;
@property (nonatomic, readonly, getter=isCentralReady, assign) BOOL centralReady;
//@property (nonatomic, )
@property (nonatomic, readonly, weak) NSString *centralNotReadyReason;
@property (nonatomic, readonly, weak) NSArray *peripherals;
@property (nonatomic, readonly, strong) CBCentralManager *manager;

+ (NSSet *)keyPathsForValuesAffectingCentralReady;
+ (NSSet *)keyPathsForValuesAffectingCentralNotReadyReason;

- (void)stopScanForPeripherals;
- (void)scanForPeripherals;
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs
                               options:(NSDictionary *)options;
- (void)scanForPeripheralsByInterval:(NSUInteger)scanInterval
                          completion:(RLCentralManagerDiscoverPeripheralsCallback)callback;
- (void)scanForPeripheralsByInterval:(NSUInteger)scanInterval
                            services:(NSArray *)servicesUUIDS
                             options:(NSDictionary *)options
                          completion:(RLCentralManagerDiscoverPeripheralsCallback)callback;

- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDS;
@end
