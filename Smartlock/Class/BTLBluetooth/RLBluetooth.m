//
//  RLBluetooth.m
//  Smartlock
//
//  Created by RivenL on 15/3/12.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLBluetooth.h"

#pragma mark -
#import "BTLcmdRequest.h"
#import "BTLcmdResponse.h"

@interface RLBluetooth ()
@property (nonatomic, readwrite, strong) RLCentralManager *manager;

@property (nonatomic, strong) RLPeripheral *currentConnectPeripheral;

@property (atomic, copy) void (^connectedCallback)(NSError *error);

@property (nonatomic, strong) RLPeripheralResponse *peripheralResponse;
@end

@implementation RLBluetooth
- (void)dealloc {
    self.manager = nil;
    self.connectedCallback = nil;
}

static RLBluetooth *_sharedBluetooth = nil;
+ (instancetype)sharedBluetooth {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBluetooth = [[RLBluetooth alloc] init];
    });
    
    return _sharedBluetooth;
}

+ (void)sharedRelease {
    if(_sharedBluetooth) {
        _sharedBluetooth.connectedCallback = nil;
        [_sharedBluetooth disconnectAllPeripherals];
        [_sharedBluetooth.manager stopScanForPeripherals];
        _sharedBluetooth = nil;
    }
}

- (instancetype)init {
    if(self = [super init]) {
        [self setupBLCentralManaer];
    }
    
    return self;
}

#pragma mark -
- (BOOL)bluetoothIsReady {
    return self.manager.centralReady;
}

- (BOOL)isSupportBluetoothLow {
    return self.manager.manager.state != CBCentralManagerStateUnsupported;
}

#pragma mark -
- (void)setupBLCentralManaer {
    self.manager = [RLCentralManager new];
}

- (void)scanPeripheralsWithCompletionBlock:(void (^)(NSArray *peripherals))completionCallback {
    if(![self isSupportBluetoothLow]) {
        if(completionCallback) {
            completionCallback(nil);
        }
        return;
    }
    if(![self bluetoothIsReady]) {
        if(completionCallback) {
            completionCallback(nil);
        }
        return;
    }
//    [self disconnectAllPeripherals];
    [self.manager scanForPeripheralsByInterval:1 completion:^(NSArray *peripherals) {
        if(completionCallback) {
            completionCallback(peripherals);
        }
    }];
}

- (void)removePeripherals {
    [self disconnectAllPeripherals];
}

- (void)connectPeripheral:(RLPeripheral *)peripheral withConnectedBlock:(void (^)(NSError *error))callback {
    __weak __typeof(self)weakSelf = self;
    if(callback) {
        self.connectedCallback = nil;
        self.connectedCallback = callback;
    }
    RLPeripheralConnectionCallback peripheralConnectionCallback = ^(NSError *error) {
        if(error) {
            if(weakSelf.connectedCallback) {
                weakSelf.connectedCallback(error);
            }
            self.connectedCallback = nil;
            DLog(@"error = %@", error);
            
            return ;
        }
        
        [weakSelf discoverPeripheralServicesWithPeripheral:peripheral];
    };
    self.currentConnectPeripheral = peripheral;
    if(peripheral.cbPeripheral.state == CBPeripheralStateDisconnected) {
        [peripheral connectWithCompletion:peripheralConnectionCallback];
    }
}

- (void)disconnectAllPeripherals {
    [self.manager stopScanForPeripherals];
    for(RLPeripheral *peripheral in self.manager.peripherals) {
        if(peripheral.cbPeripheral.state == CBPeripheralStateConnected || peripheral.cbPeripheral.state == CBPeripheralStateConnecting) {
            [self disconnectPeripheral:peripheral];
        }
    }
}

- (void)disconnectPeripheral:(RLPeripheral *)peripheral {
    if(!peripheral) return;
    
    self.connectedCallback = nil;
    
    for(RLService *service in peripheral.services) {
        for (RLCharacteristic *characteristic in [service characteristics]) {
            if(characteristic.cbCharacteristic.properties == CBCharacteristicPropertyNotify) {
                [characteristic setNotifyValue:NO completion:^(NSError *error) {
                    [peripheral disconnectWithCompletion:^(NSError *error) {
                        DLog(@"%@", error);
                    }];
                }];
                
                return ;
            }
        }
    }
    [peripheral disconnectWithCompletion:^(NSError *error) {
        DLog(@"%@", error);
    }];
}

- (void)discoverPeripheralServicesWithPeripheral:(RLPeripheral *)peripheral {
    __weak __typeof(self)weakSelf = self;
    
    RLPeripheralDiscoverServicesCallback discoverPeripheralServicesCallback = ^(NSArray *services, NSError *error) {
        if(error) {
            if(self.connectedCallback)
                self.connectedCallback(error);
            weakSelf.connectedCallback = nil;
            DLog(@"error = %@", error);
            
            return ;
        }
        
        for(RLService *service in services) {
            [weakSelf discoverServiceCharacteristicsWithService:service];
        }
    };
    
    [peripheral discoverServicesWithCompletion:discoverPeripheralServicesCallback];
}

- (void)discoverServiceCharacteristicsWithService:(RLService *)service {
    __weak __typeof(self)weakSelf = self;
    RLServiceDiscoverCharacteristicsCallback discoverServiceCharacteristicsCallback = ^(NSArray *characteristics, NSError *error) {
        if(error) {
            if(weakSelf.connectedCallback)
                weakSelf.connectedCallback(error);
            weakSelf.connectedCallback = nil;
            DLog(@"error = %@", error);
            return;
        }
    
        if(service == [weakSelf.currentConnectPeripheral.services lastObject]) {
            if(weakSelf.connectedCallback) {
                weakSelf.connectedCallback(nil);
            }
        }
    };
    
    [service discoverCharacteristicsWithCompletion:discoverServiceCharacteristicsCallback];
}

#pragma mark - set notify for character
- (void)openNotifyForPeripheral:(RLPeripheral *)peripheral
          withPeripheralRequest:(RLPeripheralRequest *)peripheralRequest
                     completion:(void(^)(NSError *error))notifyCompletion
                   onUpdateData:(void (^)(RLPeripheralResponse *peripheralRes, NSError *error))updateDataCallback
                 withDisconnect:(void(^)(NSError *error))disconnectCallback {
    
    __weak __typeof(self)weakSelf = self;
    RLService *service = [self serviceForUUIDString:@"1910" withPeripheral:peripheral];
    RLCharacteristic *characteristic = [self characteristicForNotifyWithService:service];
    if(characteristic.cbCharacteristic.isNotifying || characteristic.notified)
        return;
    [characteristic setNotifyValue:YES completion:^(NSError *error) {
        if(notifyCompletion) {
            notifyCompletion(error);
        }
        
        if(!error) {
            [peripheral setDisconnectCallbackBlock:disconnectCallback];
        }
        else {
            return ;
        }
        
        [weakSelf handlePeripheralRequestDataWithPeripheral:peripheral request:peripheralRequest];
        
    } onUpdate:^(NSData *data, NSError *error) {
        if(error || !data || data.length == 0) {
            if(updateDataCallback) {
                updateDataCallback(nil, error);
            }
            
            return ;
        }
        
        if(updateDataCallback) {
            updateDataCallback([weakSelf cmdResponseDataToPeripheralResponse:data], nil);
        }
    }];
}

- (void)connectPeripheralThanHandlePeripheral:(RLPeripheral *)peripheral
                        withPeripheralRequest:(RLPeripheralRequest *)peripheralRequest
                         connectionCompletion:(void(^)(NSError *error))connectionCompletion
                             notifyCompletion:(void(^)(NSError *error))notifyCompletion
                                 onUpdateData:(void (^)(RLPeripheralResponse *peripheralRes, NSError *error))updateDataCallback
                               withDisconnect:(void(^)(NSError *error))disconnectCallback {
    if(peripheral == nil)
        return;
    
    [self connectPeripheral:peripheral withConnectedBlock:^(NSError *error) {
        if(error) {
            if(connectionCompletion) {
                connectionCompletion(error);
            }
            return ;
        }
        
        [self openNotifyForPeripheral:peripheral withPeripheralRequest:peripheralRequest completion:notifyCompletion onUpdateData:updateDataCallback withDisconnect:disconnectCallback];
    }];
}

- (void)handlePeripheralRequestDataWithPeripheral:(RLPeripheral *)peripheral request:(RLPeripheralRequest *)request  {
    if(!peripheral || !request) return;
    RLService *service = [self serviceForUUIDString:@"1910" withPeripheral:peripheral];
    RLCharacteristic *characteristic = [self characteristicForUUIDString:@"fff2" withService:service];
    if(!characteristic) return;
    
    NSData *dataToWrite = nil;
    
    switch (request.cmdCode) {
        //设置管理员
        case 0x01: {
            long long userPwd = timestampSince1970();//[NSDate timeIntervalSinceReferenceDate]*1000;
            self.peripheralResponse = [[RLPeripheralResponse alloc] init];
            self.peripheralResponse.userPwd = userPwd;
            dataToWrite = [NSData dataWithBytes:&userPwd length:sizeof(userPwd)];
            request.cmdMode = 0x01;
        }
            break;
        //开锁
        case 0x02:
        case 0x03: {
            dataToWrite = [self dataToWriteWithPeripheralRequest:request];
        }
            break;
        case 0x04:
            return;
            break;
        case 0x05:
            return;
            break;
        //读取电压
        case 0x06: {
            long long userPwd = request.userPwd;
            dataToWrite = [NSData dataWithBytes:&userPwd length:sizeof(long long)];
            request.cmdMode = 0x00; //0x01->设置 0x00->读取
        }
            break;
            
        default:
            return;
    }
    
    if(!dataToWrite) return;
    [self writeDataToCharacteristic:characteristic cmdCode:request.cmdCode cmdMode:request.cmdMode withDatas:dataToWrite];
}

/*
    0->管理员
    1->非管理员
 */
- (NSData *)dataToWriteWithPeripheralRequest:(RLPeripheralRequest *)request {
    if(!request || request.cmdCode == 0x00) return nil;
    int len = 0;
    long long data = request.userPwd;
    
    Byte *dateData = nil;
    if(request.userType == 1) {
        if(request.cmdCode == 0x02) {
            request.cmdMode = 0x01; //非管理员
            dateData = dateToBytes(&len, request.invalidDate.length? request.invalidDate: @"2015-12-18");
        }
        else { return nil; }
    }
    else { //管理员
        if(request.cmdCode == 0x02) {
            request.cmdMode = 0x00; //管理员
        }
        else {
            request.cmdMode = 0x01;
        }
        dateData = dateNowToBytes(&len);
        self.peripheralResponse = [[RLPeripheralResponse alloc] init];
        self.peripheralResponse.timeData = [NSData dataWithBytes:dateData length:len];
    }
    
//    int size = sizeof(data)+len;
//    Byte *tempData = calloc(size, sizeof(Byte));
//
//    memcpy(tempData, dateData, len);
//    
//    Byte *temp = (Byte *)&(data);
//    for(NSInteger j = len; j<size; j++) {
//        tempData[j] = temp[j-len];
//    }
    
    int dataSize = sizeof(data);
    int size = dataSize+len;
    Byte *tempData = calloc(size, sizeof(Byte));
    append_bytes_to_bytes(tempData, dateData, len, (Byte *)&data, dataSize);

    NSData *writeData = [NSData dataWithBytes:tempData length:dataSize+len];
    free(tempData);
    
    return writeData;
}

#pragma mark -
- (void)writeDataToCharacteristic:(RLCharacteristic *)characteristic withData:(NSData *)data {
    [self writeDataToCharacteristic:characteristic cmdCode:0x00 cmdMode:0x00 withDatas:data];
}

- (void)writeDataToCharacteristic:(RLCharacteristic *)characteristic cmdCode:(Byte)cmdCode cmdMode:(Byte)cmdMode withDatas:(NSData *)data {
    if(characteristic.cbCharacteristic.properties == CBCharacteristicPropertyWrite || CBCharacteristicPropertyWriteWithoutResponse == characteristic.cbCharacteristic.properties) {
        
        union btl_cmd_mode mode = {cmdMode};
        struct btl_cmd cmd = get_cmd(cmdCode, mode);
        cmd.btl_cmd_CRC = cmd_crc_check(&cmd);
        
        cmd.btl_cmd_data = (Byte *)[data bytes];
        cmd.btl_cmd_data_len = data.length;//sizeof(data);
        cmd.btl_cmd_CRC += cmd.btl_cmd_data_len;
        
        cmd.btl_cmd_CRC +=  bytes_crc_check(cmd.btl_cmd_data, cmd.btl_cmd_data_len);
        
        cmd.btl_cmd_fixation_len = get_cmd_fixationLen();
        NSInteger len = cmd.btl_cmd_data_len + cmd.btl_cmd_fixation_len;
        
        Byte *bytes = calloc(len, sizeof(Byte));
        
        wrapp_cmd_to_bytes(&cmd, bytes);
        
        int i;
        
#ifdef DEBUG
        NSMutableString *str = [NSMutableString stringWithString:@""];
        for(i=0; i<len; i++) {
            [str appendString:[NSString stringWithFormat:@"%02x", bytes[i]]];
        }
        
        DLog(@"str = %@", str);
#endif
#if 0
        NSInteger packages = len/BluetoothPackageSize + (len%BluetoothPackageSize ? 1 : 0);
        for(i = 0; i<packages; i++) {
            [characteristic writeValue:[NSData dataWithBytes:&bytes[i*BluetoothPackageSize] length:i+1<packages? BluetoothPackageSize : len-i*BluetoothPackageSize] completion:nil];
//            [NSThread sleepForTimeInterval:0.05];
        }
#else
        [characteristic writeValue:[NSData dataWithBytes:bytes length:len] completion:nil];
#endif
        free((void *)bytes);
        bytes = NULL;
    }
}

- (RLPeripheralResponse *)cmdResponseDataToPeripheralResponse:(NSData *)data {
    RLPeripheralResponse *peripheralRe = [[RLPeripheralResponse alloc] init];
    btl_cmd_response cmdResponse = cmd_response_with_bytes((Byte *)[data bytes], data.length);
    Byte crc = get_cmd_CRC_fromCmdBytes((Byte *)[data bytes], data.length);
    peripheralRe.isCRCOk = (crc == cmdResponse.btl_cmd_CRC);
    peripheralRe.cmdCode = cmdResponse.btl_cmd_code;
    peripheralRe.result = cmdResponse.btl_cmd_result.result;
    
    if(peripheralRe.cmdCode == 0x01) {
        peripheralRe.userPwd = self.peripheralResponse.userPwd;
    }
    
    if(peripheralRe.cmdCode == 0x02) {
        Byte powerCode = cmdResponse.btl_cmd_data[1];
        Byte updateTimeCode = cmdResponse.btl_cmd_data[0];
        
        peripheralRe.powerCode = powerCode;
        peripheralRe.updateTimeCode = updateTimeCode;
        peripheralRe.timeData = self.peripheralResponse.timeData;
    }
    
    if(peripheralRe.cmdCode == 0x03) {
        peripheralRe.timeData = self.peripheralResponse.timeData;
    }
    
    self.peripheralResponse = nil;
    return peripheralRe;
}


#pragma mark - BTLCommand

- (void)btlOpenNotifyForPeripheral:(RLPeripheral *)peripheral
          withPeripheralRequest:(RLPeripheralRequest *)peripheralRequest
                     completion:(void(^)(NSError *error))notifyCompletion
                   onUpdateData:(void (^)(RLPeripheralResponse *peripheralRes, NSError *error))updateDataCallback
                 withDisconnect:(void(^)(NSError *error))disconnectCallback {
    
    __weak __typeof(self)weakSelf = self;
    RLService *service = [self serviceForUUIDString:@"1910" withPeripheral:peripheral];
    RLCharacteristic *characteristic = [self characteristicForNotifyWithService:service];
    if(characteristic.cbCharacteristic.isNotifying)
        return;
    [characteristic setNotifyValue:YES completion:^(NSError *error) {
        if(notifyCompletion) {
            notifyCompletion(error);
        }
        
        if(!error) {
            [peripheral setDisconnectCallbackBlock:disconnectCallback];
        }
        else {
            return ;
        }
        
        [weakSelf btlHandlePeripheralRequestDataWithPeripheral:peripheral request:peripheralRequest];
        
    } onUpdate:^(NSData *data, NSError *error) {
        if(error || !data || data.length == 0) {
            if(updateDataCallback) {
                updateDataCallback(nil, error);
            }
            
            return ;
        }
        
        if(updateDataCallback) {
            updateDataCallback([weakSelf btlCmdResponseDataToPeripheralResponse:data], nil);
        }
    }];
}

- (void)btlConnectPeripheralThanHandlePeripheral:(RLPeripheral *)peripheral
                        withPeripheralRequest:(RLPeripheralRequest *)peripheralRequest
                         connectionCompletion:(void(^)(NSError *error))connectionCompletion
                             notifyCompletion:(void(^)(NSError *error))notifyCompletion
                                 onUpdateData:(void (^)(RLPeripheralResponse *peripheralRes, NSError *error))updateDataCallback
                               withDisconnect:(void(^)(NSError *error))disconnectCallback {
    if(peripheral == nil)
        return;
    
    [self connectPeripheral:peripheral withConnectedBlock:^(NSError *error) {
        if(error) {
            if(connectionCompletion) {
                connectionCompletion(error);
            }
            return ;
        }
        
        [self btlOpenNotifyForPeripheral:peripheral withPeripheralRequest:peripheralRequest completion:notifyCompletion onUpdateData:updateDataCallback withDisconnect:disconnectCallback];
    }];
}

- (void)btlHandlePeripheralRequestDataWithPeripheral:(RLPeripheral *)peripheral request:(RLPeripheralRequest *)request  {
    if(!peripheral || !request) return;
    RLService *service = [self serviceForUUIDString:@"1910" withPeripheral:peripheral];
    RLCharacteristic *characteristic = [self characteristicForUUIDString:@"fff2" withService:service];
    if(!characteristic) return;
    
    NSData *dataToWrite = nil;
    
    switch (request.cmdCode) {
            //设置管理员
        case 0x01: {
            long long userPwd = timestampSince1970();//[NSDate timeIntervalSinceReferenceDate]*1000;
            self.peripheralResponse = [[RLPeripheralResponse alloc] init];
            self.peripheralResponse.userPwd = userPwd;
            dataToWrite = [NSData dataWithBytes:&userPwd length:sizeof(userPwd)];
            request.cmdMode = 0x01;
        }
            break;
            //开锁
        case 0x02:
        case 0x03: {
            dataToWrite = [self dataToWriteWithPeripheralRequest:request];
        }
            break;
        case 0x04:
            return;
            break;
        case 0x05:
            return;
            break;
            //读取电压
        case 0x06: {
            long long userPwd = request.userPwd;
            dataToWrite = [NSData dataWithBytes:&userPwd length:sizeof(long long)];
            request.cmdMode = 0x00; //0x01->设置 0x00->读取
        }
            break;
            
        default:
            return;
    }
    
    if(!dataToWrite) return;
    BTLcmdRequest *cmdRequest = [[BTLcmdRequest alloc] initWithCmdCode:request.cmdCode withCmdMode:request.cmdMode];
    [cmdRequest setCmdData:dataToWrite];
    [self btlCmdWriteDataToCharacteristic:characteristic withCmdRequest:cmdRequest];
}

/*
 0->管理员
 1->非管理员
 */
- (NSData *)btlCmdDataToWriteWithPeripheralRequest:(RLPeripheralRequest *)request {
    if(!request || request.cmdCode == 0x00) return nil;
    int len = 0;
    long long data = request.userPwd;
    
    Byte *dateData = nil;
    if(request.userType == 1) {
        if(request.cmdCode == 0x02) {
            request.cmdMode = 0x01; //非管理员
            dateData = btlCmdDateToBytes(&len, request.invalidDate.length? request.invalidDate: @"2015-12-18");
        }
        else { return nil; }
    }
    else { //管理员
        if(request.cmdCode == 0x02) {
            request.cmdMode = 0x00; //管理员
        }
        else {
            request.cmdMode = 0x01;
        }
        dateData = btlCmdDateNowToBytes(&len);
        self.peripheralResponse = [[RLPeripheralResponse alloc] init];
        self.peripheralResponse.timeData = [NSData dataWithBytes:dateData length:len];
    }
    
    int size = sizeof(data)+len;
    Byte *tempData = calloc(size, sizeof(Byte));
    memcpy(tempData, dateData, len);
    
    Byte *temp = (Byte *)&(data);
    for(NSInteger j = len; j<size; j++) {
        tempData[j] = temp[j-len];
    }
    
    NSData *writeData = [NSData dataWithBytes:tempData length:size];
    free(tempData);
    
    return writeData;
}

- (void)btlCmdWriteDataToCharacteristic:(RLCharacteristic *)characteristic withCmdRequest:(BTLcmdRequest *)cmdRequest {
    if(characteristic.cbCharacteristic.properties == CBCharacteristicPropertyWrite || CBCharacteristicPropertyWriteWithoutResponse == characteristic.cbCharacteristic.properties) {
        [cmdRequest cmdCRCCheck];
        [characteristic writeValue:cmdRequest.toData completion:nil];
    }
}

- (RLPeripheralResponse *)btlCmdResponseDataToPeripheralResponse:(NSData *)data {
    RLPeripheralResponse *peripheralRe = [[RLPeripheralResponse alloc] init];
    BTLcmdResponse *cmdResponse = [[BTLcmdResponse alloc] initWithcmdResponseData:data];

    Byte crc = [cmdResponse cmdBytesCRCCheckWithBytes:(Byte *)[data bytes] len:(int)data.length];
    peripheralRe.isCRCOk = (crc == [cmdResponse cmd_CRC]);
    peripheralRe.cmdCode = [cmdResponse cmd_code];
    peripheralRe.result = [cmdResponse cmd_cmdResponseResult];
    
    if(peripheralRe.cmdCode == 0x01) {
        peripheralRe.userPwd = self.peripheralResponse.userPwd;
    }
    
    if(peripheralRe.cmdCode == 0x02) {
        Byte powerCode = ((Byte *)[[cmdResponse cmdData] bytes])[1];//cmdResponse.data[1];
        Byte updateTimeCode = ((Byte *)[[cmdResponse cmdData] bytes])[0];
        
        peripheralRe.powerCode = powerCode;
        peripheralRe.updateTimeCode = updateTimeCode;
        peripheralRe.timeData = self.peripheralResponse.timeData;
    }
    
    if(peripheralRe.cmdCode == 0x03) {
        peripheralRe.timeData = self.peripheralResponse.timeData;
    }
    
    self.peripheralResponse = nil;
    return peripheralRe;
}



#pragma mark - 
- (RLPeripheral *)peripheralForName:(NSString *)name {
    for(RLPeripheral *peripheral in self.peripherals) {
        if([peripheral.name isEqualToString:name]) {
            return peripheral;
        }
    }
    return nil;
}

- (RLPeripheral *)peripheralForUUIDString:(NSString *)uuidString {
    for(RLPeripheral *peripheral in self.peripherals) {
        if([peripheral.UUIDString isEqualToString:uuidString]) {
            return peripheral;
        }
    }
    return nil;
}

- (RLService *)serviceForUUIDString:(NSString *)uuidString withPeripheral:(RLPeripheral *)peripheral {
    if(peripheral == nil)
        return nil;
    
    for(RLService *service in peripheral.services) {
        if([service.UUIDString isEqualToString:uuidString]) {
            return service;
        }
    }
    return nil;
}
- (RLCharacteristic *)characteristicForUUIDString:(NSString *)uuidString withService:(RLService *)service {
    
    if(!service) {
        return nil;
    }
    
    for(RLCharacteristic *characteristic in service.characteristics) {
        if([characteristic.UUIDString isEqualToString:uuidString])
            return characteristic;
    }
    
    return nil;
}

- (RLCharacteristic *)characteristicForNotifyWithService:(RLService *)service {
    if(!service) {
        return nil;
    }
    
    for(RLCharacteristic *characteristic in service.characteristics) {
        if(characteristic.cbCharacteristic.properties == CBCharacteristicPropertyNotify)
            return characteristic;
    }
    
    return nil;
}


#pragma mark - public methods
- (NSArray *)peripherals {
    return self.manager.peripherals;
}

#pragma mark - app method
- (RLCharacteristic *)characteristicForNotifyWithPeripheralName:(NSString *)peripheralName {
    RLPeripheral *peripheral = [self peripheralForName:peripheralName];
    RLService *service = [self serviceForUUIDString:@"1910" withPeripheral:peripheral];
    RLCharacteristic *characteristic = [self characteristicForNotifyWithService:service];
    
    return characteristic;
}

@end
