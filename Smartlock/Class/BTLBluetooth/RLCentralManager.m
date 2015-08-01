//
//  RLCentralManager.m
//  Smartlock
//
//  Created by RivenL on 15/3/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLCentralManager.h"
#import "RLPeripheral.h"

@interface RLCentralManager () <CBCentralManagerDelegate>
/*----------------------------------------------------*/
@property (nonatomic, readwrite, strong) CBCentralManager *manager;
/*----------------------------------------------------*/
@property (atomic, strong) NSMutableDictionary *operations;
@property (nonatomic, strong) dispatch_queue_t centralQueue;
@property (nonatomic, strong) NSMutableArray *scannedPeripherals;

@property (nonatomic, copy) RLCentralManagerDiscoverPeripheralsCallback scanBlock;

@property (nonatomic) CBCentralManagerState cbCentralManagerState;
@end

@implementation RLCentralManager
/*----------------------------------------------------*/
#pragma mark - LifeCycle -
/*----------------------------------------------------*/
- (void)dealloc {
    [self.manager stopScan], self.manager = nil;
    
    self.centralQueue = nil;
    [self.scannedPeripherals removeAllObjects], self.scannedPeripherals = nil;
    
    self.scanBlock = nil;
}

- (instancetype)init {
    if(self = [super init]) {
        self.centralQueue = dispatch_queue_create("com.RLBluetooth.RLCentralQueue", DISPATCH_QUEUE_SERIAL);
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:self.centralQueue options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
        self.cbCentralManagerState = self.manager.state;
        self.scannedPeripherals = [NSMutableArray new];
    }
    
    return self;
}

/*----------------------------------------------------*/
#pragma mark - Getter/Setter -
/*----------------------------------------------------*/
- (BOOL)isCentralReady {
    return self.manager.state == CBCentralManagerStatePoweredOn;
}

- (NSString *)centralNotReadyReason {
    return [self stateMessage];
}

- (NSArray *)peripherals {
    return self.scannedPeripherals;
}

/*----------------------------------------------------*/
#pragma mark - KVO -
/*----------------------------------------------------*/
+ (NSSet *)keyPathsForValuesAffectingCentralReady {
    return [NSSet setWithObject:@"cbCentralManagerState"];
}

+ (NSSet *)keyPathsForValuesAffectingCentralNotReadyReason {
    return [NSSet setWithObject:@"cbCentralManagerState"];
}

/*----------------------------------------------------*/
#pragma mark - Public Methods -
/*----------------------------------------------------*/
- (void)stopScanForPeripherals {
    self.scanning = NO;
    [self.manager stopScan];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScanForPeripherals) object:nil];
    
    if(self.scanBlock) {
        self.scanBlock(self.peripherals);
    }
    self.scanBlock = nil;
}

- (void)scanForPeripherals {
    [self scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options {
    [self.scannedPeripherals removeAllObjects];
    self.scanning = YES;
    [self.manager scanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (void)scanForPeripheralsByInterval:(NSUInteger)scanInterval completion:(RLCentralManagerDiscoverPeripheralsCallback)callback {
    [self scanForPeripheralsByInterval:scanInterval services:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES} completion:callback];
}
- (void)scanForPeripheralsByInterval:(NSUInteger)scanInterval services:(NSArray *)servicesUUIDS options:(NSDictionary *)options completion:(RLCentralManagerDiscoverPeripheralsCallback)callback {
    self.scanBlock = callback;
    [self scanForPeripheralsWithServices:servicesUUIDS options:options];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScanForPeripherals) object:nil];

    [self performSelector:@selector(stopScanForPeripherals) withObject:nil afterDelay:scanInterval];
}

- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers {
//    return nil;
    return [self wrappersByPeripherals:[self.manager retrievePeripheralsWithIdentifiers:identifiers]];
}

- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)sericeUUIDS {
    return [self wrappersByPeripherals:[self.manager retrieveConnectedPeripheralsWithServices:sericeUUIDS]];
}

/*----------------------------------------------------*/
#pragma mark - Private Methods -
/*----------------------------------------------------*/
- (NSString *)stateMessage {
    NSString *message = nil;
    switch (self.manager.state) {
        case CBCentralManagerStateUnsupported:
            message = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            message = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnknown:
            message = @"Central not initialized yet.";
            break;
        case CBCentralManagerStatePoweredOff: //蓝牙未打开，系统会自动提示打开，所以不用自行提示
            message = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            message = @"蓝牙已打开,请扫描外设";
            break;
        default:
            break;
    }
    return message;
}

- (RLPeripheral *)wrapperByPeripheral:(CBPeripheral *)peripheral {
    RLPeripheral *wrapper = nil;
    for(RLPeripheral *scanned in self.scannedPeripherals) {
        if(scanned.cbPeripheral == peripheral) {
            wrapper = scanned;
            break;
        }
    }
    
    if(!wrapper) {
        wrapper = [[RLPeripheral alloc] initWithPeripheral:peripheral manager:self];
        [self.scannedPeripherals addObject:wrapper];
        NSLog(@"-- \r\n 发现设备:uuids = %@ --",self.scannedPeripherals);
    }
    
    return wrapper;
}

- (NSArray *)wrappersByPeripherals:(NSArray *)peripherals {
    NSMutableArray *rlPeripherals = [NSMutableArray new];
    for(CBPeripheral *peripheral in peripherals) {
        [rlPeripherals addObject:[self wrapperByPeripheral:peripheral]];
    }
    
    return rlPeripherals;
}

//-------------------------------------------------------------------------//
#pragma mark - Central Manager Delegate
//-------------------------------------------------------------------------//
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.cbCentralManagerState = central.state;
    NSString *message = [self stateMessage];
    if(message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", message);
        });
    }
}

//发现设备
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![advertisementData[@"kCBAdvDataLocalName"] hasPrefix:PeripheralPreStr])
            return ;
        RLPeripheral *rlPeripheral = [self wrapperByPeripheral:peripheral];
        if(!rlPeripheral.RSSI) {
            rlPeripheral.RSSI = [RSSI integerValue];
        }
        else {
            // Calculating AVG RSSI
            rlPeripheral.RSSI = (rlPeripheral.RSSI + [RSSI integerValue]) / 2;
        }
        rlPeripheral.advertisingData = advertisementData;
        rlPeripheral.version = (PeripheralVersion)[[advertisementData[@"kCBAdvDataLocalName"] substringWithRange:NSMakeRange(PeripheralPreStr.length+2, 2)] integerValue];
    });
    
}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Did connect toperipheral: %@ name = %@", peripheral, peripheral.name);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self wrapperByPeripheral:peripheral] handleConnectionWithError:nil];
    });
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"%@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self wrapperByPeripheral:peripheral] handleConnectionWithError:error];
    });
}

//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"did disconnect peripheral %@ name = %@", peripheral, peripheral.name);
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        RLPeripheral *rlPeripheral = [weakSelf wrapperByPeripheral:peripheral];
        [rlPeripheral handleDisconnectWithError:error];
        [weakSelf.scannedPeripherals removeObject:rlPeripheral];
    });
}
@end
