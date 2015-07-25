//
//  RLCharacteristic.m
//  Smartlock
//
//  Created by RivenL on 15/3/13.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLCharacteristic.h"

@interface RLCharacteristic ()
/*----------------------------------------------------*/
@property (nonatomic, readwrite, strong) CBCharacteristic *cbCharacteristic;
/*----------------------------------------------------*/

@property (nonatomic, strong) NSMutableArray *notifyOperationStack;
@property (nonatomic, strong) NSMutableArray *readOperationStack;
@property (nonatomic, strong) NSMutableArray *writeOperationStack;

@property (nonatomic, strong) RLCharacteristicReadCallback updateCallback;
@end

@implementation RLCharacteristic
/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/
- (void)dealloc {
    self.cbCharacteristic = nil;
    [self.notifyOperationStack removeAllObjects], self.notifyOperationStack = nil;
    [self.readOperationStack removeAllObjects], self.readOperationStack = nil;
    [self.writeOperationStack removeAllObjects], self.writeOperationStack = nil;

    self.updateCallback = nil;
}

- (instancetype)initWithCharacteristic:(CBCharacteristic *)aCharacteristic
{
    if (self = [super init]) {
        self.cbCharacteristic = aCharacteristic;
    }
    return self;
}

/*----------------------------------------------------*/
#pragma mark - Getter/Setter -
/*----------------------------------------------------*/
- (NSMutableArray *)notifyOperationStack {
    if(!_notifyOperationStack) {
        _notifyOperationStack = [NSMutableArray new];
    }
    
    return _notifyOperationStack;
}
- (NSMutableArray *)readOperationStack {
    if(!_readOperationStack) {
        _readOperationStack = [NSMutableArray new];
    }
    
    return _readOperationStack;
}
- (NSMutableArray *)writeOperationStack {
    if(!_writeOperationStack) {
        _writeOperationStack = [NSMutableArray new];
    }
    return _writeOperationStack;
}

- (NSString *)UUIDString {
    return [self.cbCharacteristic.UUID representativeString];
}

/*----------------------------------------------------*/
#pragma mark - Public Methods -
/*----------------------------------------------------*/
- (void)setNotifyValue:(BOOL)notifyValue
            completion:(RLCharacteristicNotifyCallback)callback {
    [self setNotifyValue:notifyValue completion:callback onUpdate:nil];
}
- (void)setNotifyValue:(BOOL)notifyValue
            completion:(RLCharacteristicNotifyCallback)nCallback
              onUpdate:(RLCharacteristicReadCallback)rCallback {
    if(!nCallback) {
        nCallback = ^(NSError *error) {};
    }
    
    self.updateCallback = rCallback;
    [self push:nCallback toArray:self.notifyOperationStack];
    [self.cbCharacteristic.service.peripheral setNotifyValue:notifyValue forCharacteristic:self.cbCharacteristic];
}

- (BOOL)notifyValue {
    return _notified;
}

- (void)writeValue:(NSData *)data
        completion:(RLCharacteristicWriteCallback)wCallback {
    CBCharacteristicWriteType type = wCallback ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse;
    
    if(wCallback) {
        [self push:wCallback toArray:self.writeOperationStack];
    }
    [self.cbCharacteristic.service.peripheral writeValue:data forCharacteristic:self.cbCharacteristic type:type];
}
- (void)writeByte:(int8_t)byte completion:(RLCharacteristicWriteCallback)wCallback {
    [self writeValue:[NSData dataWithBytes:&byte length:1] completion:wCallback];
}

- (void)readValueWithCompletionBlock:(RLCharacteristicReadCallback)rCallback {
    // No need to read
    if(!rCallback)
        return;
    
    [self push:rCallback toArray:self.readOperationStack];
    [self.cbCharacteristic.service.peripheral readValueForCharacteristic:self.cbCharacteristic];
}

/*----------------------------------------------------*/
#pragma mark - Private Methods -
/*----------------------------------------------------*/
- (void)push:(id)anObject toArray:(NSMutableArray *)anArray {
    [anArray addObject:anObject];
}

- (id)popFromArray:(NSMutableArray *)anArray {
    id anObject = nil;
    if(anArray.count > 0) {
        anObject = [anArray objectAtIndex:0];
        [anArray removeObjectAtIndex:0];
    }
    
    return anObject;
}

/*----------------------------------------------------*/
#pragma mark - Handler Methods -
/*----------------------------------------------------*/
- (void)handleSetNotifiedWithError:(NSError *)error {
//    NSLog(@"Characteristic - %@ notify changed", self.cbCharacteristic.UUID);
    
    _notified = YES;
    if(error) {
        _notified = NO;
        NSLog(@"Characteristic - %@ notify changed with error - %@", self.cbCharacteristic.UUID, error);
    }
    
    RLCharacteristicNotifyCallback callback = [self popFromArray:self.notifyOperationStack];
    if(callback) {
        callback(error);
    }
}

- (void)handleWrittenValueWithError:(NSError *)error {
//    NSLog(@"Characteristic - %@ wrote", self.cbCharacteristic.UUID);
    
    if(error) {
        NSLog(@"Characteristic - %@ wrote with error - %@", self.cbCharacteristic.UUID, error);
    }
    
    RLCharacteristicWriteCallback callback = [self popFromArray:self.writeOperationStack];
    if(callback) {
        callback(error);
    }
}

- (void)handleReadValue:(NSData *)value error:(NSError *)error {
//    NSLog(@"Characteristic - %@ read value - %s", self.cbCharacteristic.UUID, [value bytes]);
    
    if(error) {
        NSLog(@"Characteristic - %@ read value - %s with error - %@", self.cbCharacteristic.UUID, [value bytes], error);
    }
    NSLog(@"%@", value);
    if(self.updateCallback) {
        self.updateCallback(value, error);
    }
    
    RLCharacteristicReadCallback callback = [self popFromArray:self.readOperationStack];
    if(callback) {
        callback(value, error);
    }
}
@end
