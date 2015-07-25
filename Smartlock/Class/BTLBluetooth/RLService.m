//
//  RLService.m
//  Smartlock
//
//  Created by RivenL on 15/3/13.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLService.h"
#import "RLCharacteristic.h"

@interface RLService ()
/*----------------------------------------------------*/
@property (nonatomic, readwrite, strong) CBService *cbService;

@property (nonatomic, readwrite, getter=isDiscoveringCharacteristics, assign) BOOL discoveringCharacteristics;
/*----------------------------------------------------*/

@property (nonatomic, copy) RLServiceDiscoverCharacteristicsCallback discoverCharBlock;
@end

@implementation RLService
/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/
- (void)dealloc {
    self.discoverCharBlock = nil;
}

- (instancetype)initWithService:(CBService *)service {
    if(self = [super init]) {
        self.cbService = service;
    }
    
    return self;
}

/*----------------------------------------------------*/
#pragma mark - Getter/Setter -
/*----------------------------------------------------*/

- (NSString *)UUIDString
{
    return [self.cbService.UUID representativeString];
}

/*----------------------------------------------------*/
#pragma mark - Public Methods -
/*----------------------------------------------------*/
- (void)discoverCharacteristicsWithCompletion:(RLServiceDiscoverCharacteristicsCallback)callback {
    [self discoverCharacteristicsWithUUIDs:nil completion:callback];
}
- (void)discoverCharacteristicsWithUUIDs:(NSArray *)uuids completion:(RLServiceDiscoverCharacteristicsCallback)callback {
    self.discoverCharBlock = callback;
    self.discoveringCharacteristics = YES;
    [self.cbService.peripheral discoverCharacteristics:uuids forService:self.cbService];
}

- (RLCharacteristic *)wrapperByCharacteristic:(CBCharacteristic *)aChar {
    RLCharacteristic *wrapper = nil;
    for(RLCharacteristic *discovered in self.characteristics) {
        if(discovered.cbCharacteristic == aChar) {
            wrapper = discovered;
            break;
        }
    }
    
    return wrapper;
}

/*----------------------------------------------------*/
#pragma mark - Private Methods -
/*----------------------------------------------------*/
- (void)updateCharacteristicWrappers {
    NSMutableArray *updateCharacteristics = [NSMutableArray new];
    for(CBCharacteristic *characteristic in self.cbService.characteristics) {
        [updateCharacteristics addObject:[[RLCharacteristic alloc] initWithCharacteristic:characteristic]];
    }
    
    self.characteristics = updateCharacteristics;
}

/*----------------------------------------------------*/
#pragma mark - Handler Methods -
/*----------------------------------------------------*/
- (void)handleDiscoveredCharacteristics:(NSArray *)characteristics error:(NSError *)error {
    self.discoveringCharacteristics = NO;
    [self updateCharacteristicWrappers];
    
//    for(RLCharacteristic *aChar in self.characteristics) {
//        NSLog(@"Characteristic discovered - %@", aChar.cbCharacteristic.UUID);
//    }
    
    if(self.discoverCharBlock) {
        self.discoverCharBlock(self.characteristics, error);
    }
    self.discoverCharBlock = nil;
}
@end
