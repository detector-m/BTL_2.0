//
//  ViewController.m
//  Smartlock
//
//  Created by RivenL on 15/3/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) CBCentralManager *manager;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) NSTimer *connectTimer;
@property (nonatomic, strong) CBPeripheral *currentPeripheral;

@property (nonatomic, strong) NSMutableArray *servers;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"test";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.peripherals = [NSMutableArray new];
    self.servers = [NSMutableArray new];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60.0f;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)scanForPeripherals {
    [self scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
}

- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options {
    [self.manager scanForPeripheralsWithServices:serviceUUIDs
                                         options:options];
}

-(void)scan {
    NSLog(@"开始扫描。。");
    [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey :@NO}];
    
    //30秒以后停止
    double delayInSeconds = 30.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds*NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.manager stopScan];//停止扫描
        NSLog(@"停止扫描。。");
    });
}

-(BOOL)connect:(CBPeripheral*)peripheral{
    NSLog(@"connectstart");
    _currentPeripheral = nil;
    [self.manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    
   // 开一个定时器监控连接超时的情况
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectTimeout:) userInfo:peripheral repeats:NO];
    
    return YES;
}

- (void)connectTimeout:(id)sender {

}

-(void)disConnect
{
    if (_currentPeripheral != nil)
    {
        NSLog(@"disConnectstart");
        [_manager cancelPeripheralConnection:_currentPeripheral];
    }
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state){
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已打开,请扫描外设");
            [self scan];//扫描
            break;
        case CBCentralManagerStateUnsupported:
//            [AlertUtilsshowAlert:@"您的设备不支持蓝牙或蓝牙4.0"];
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"未授权");
            break;
        caseCBCentralManagerStatePoweredOff://蓝牙未打开，系统会自动提示打开，所以不用自行提示
        default:
            break;
    }
}

//发现设备
-(void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber *)RSSI{
    if (![_peripherals containsObject:peripheral]) {
        [_peripherals addObject:peripheral];
        NSLog(@"发现设备:%@",_peripherals);
        [self.tableView reloadData];
    }
}

//连接外设成功
- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral {
    [self.connectTimer invalidate];//停止时钟
    
    NSLog(@"Did connect toperipheral: %@", peripheral);
    self.currentPeripheral = peripheral;
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];//发现服务
}

//连接外设失败
-(void)centralManager:(CBCentralManager*)central didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSError *)error
{
    NSLog(@"%@",error);
}


//已发现服务
-(void) peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error{
    
    for (CBService*s in peripheral.services){
        [_servers addObject:s];
    }
    for (CBService*s in peripheral.services){
        NSLog(@"服务 UUID: %@(%@)",s.UUID.data,s.UUID);
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError *)error{
    NSLog(@"发现特征的服务:%@ (%@)",service.UUID.data ,service.UUID);
    
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"特征UUID: %@ (%@)",c.UUID.data,c.UUID);
        //        if ([c.UUID isEqual:[CBUUIDUUIDWithString:@"2A06"]]) {//设置
        //           _writeCharacteristic = c;
        //       }
        //        if ([c.UUID isEqual:[CBUUIDUUIDWithString:@"2A19"]]) {//读取
        //           [_peripheral readValueForCharacteristic:c];
        //       }
        //
        //       if ([c.UUID isEqual:[CBUUIDUUIDWithString:@"FFA1"]]) {
        //           [_peripheral readRSSI];
        //       }
        //       [_nCharacteristics addObject:c];
    }
}

#pragma mark - 
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 3;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return self.peripherals.count;
    }
    else if(section == 1) {
        
    }
    
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
    if(peripheral.state == CBPeripheralStateConnected) {
        
    }
    else {
        [self connect:peripheral];
    }
}
@end
