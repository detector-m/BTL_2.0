//
//  ExcuteVC.m
//  Smartlock
//
//  Created by RivenL on 15/4/26.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "ExcuteVC.h"

#import "RLTypecast.h"

@implementation ExcuteVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textField = [[RLTitleTextField alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width-20, 50)];
    self.textField.title.text = @"指令";
    [self.view addSubview:self.textField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(50, self.textField.frame.origin.y+self.textField.frame.size.height+10, self.view.frame.size.width-100, 50);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickExcute) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"执行" forState:UIControlStateNormal];
    [self.view addSubview:button];
}

- (void)clickExcute {
#if 0
//    Byte bytes[] = {0x55, 0x01, 0x01, 0x00, 0x0b, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0xa4, 0x66};
    Byte bytes[] = {0x55, 0x01, 0x01, 0x00, 0x20, 0x3c, 0xbd, 0xec, 0x37, 0xd6, 0xa2, 0x40, 0x4f, 0x96, 0xa0, 0x83, 0xa3, 0xaa, 0x5d, 0x73, 0x82, 0x3c, 0xbd, 0xec, 0x37, 0xd6, 0xa2, 0x40, 0x4f, 0x96, 0xa0, 0x83, 0xa3, 0xaa, 0x5d, 0x73, 0x82, 0x74, 0x66};
//    Byte bytes[] = { 0x55, 0x01, 0x01, 0x00, 0x0b, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0xa4, 0x66};
//    Byte bytes[] = {0x55, 0x01, 0x01, 0x00, 0x0b, 0x05, 0x10, 0x90, 0xDD, 0xB2, 0xF3, 0x49, 0x04, 0x98, 0x02, 0x28, 0xCC, 0x66};
    
    Byte temp = 0;
    int i;
    NSMutableString *str = [NSMutableString stringWithString:@""];
    for( i=0; i<37; i++) {
        temp += bytes[i];
    }
    bytes[i] = temp;
    
    NSInteger length = sizeof(bytes);
    for(i=0; i<length; i++) {
        [str appendString:[NSString stringWithFormat:@"%x", bytes[i]]];
    }
    
    self.textField.textField.text = str;
    
    for(i=0; i<length; i++) {
        [self.ch writeValue:[NSData dataWithBytes:&bytes[i] length:1] completion:nil];
        [NSThread sleepForTimeInterval:0.1];
    }
//    if(self.ch.cbCharacteristic.isNotifying) {
//        
//    }
#else
//    Byte bytes[] = {0x55, 0x01, 0x01, 0x00, 0x20, 0x3c, 0xbd, 0xec, 0x37, 0xd6, 0xa2, 0x40, 0x4f, 0x96, 0xa0, 0x83, 0xa3, 0xaa, 0x5d, 0x73, 0x82, 0x3c, 0xbd, 0xec, 0x37, 0xd6, 0xa2, 0x40, 0x4f, 0x96, 0xa0, 0x83, 0xa3, 0xaa, 0x5d, 0x73, 0x82, 0x74, 0x66};
    Byte data[] = {0x3c, 0xbd, 0xec, 0x37, 0xd6, 0xa2, 0x40, 0x4f, 0x96, 0xa0, 0x83, 0xa3, 0xaa, 0x5d, 0x73, 0x82, 0x3c, 0xbd, 0xec, 0x37, 0xd6, 0xa2, 0x40, 0x4f, 0x96, 0xa0, 0x83, 0xa3, 0xaa, 0x5d, 0x73, 0x82};
    
    struct BL_cmd cmd = {0};
    cmd.ST = 0x55;
    cmd.CRC += cmd.ST;
    cmd.cmd_code = 0x01;
    cmd.CRC += cmd.cmd_code;
    cmd.union_mode.connection = 0x01;
    cmd.CRC += cmd.union_mode.connection;
    cmd.result.keep = 0x00;
    cmd.CRC += cmd.result.keep;
    cmd.END = 0x66;
    
    cmd.data = data;
    cmd.data_len = sizeof(data);
    cmd.CRC += cmd.data_len;
    
    cmd.CRC += CMDDatasCRCCheck(cmd.data, cmd.data_len);
    
    cmd.fixation_len = BLcmdFixationLen();
    NSInteger len = cmd.data_len + cmd.fixation_len;
    
//    NSInteger len = cmd.data_len + sizeof(cmd) - sizeof(Byte *);
    Byte *bytes = calloc(len, sizeof(UInt8));
    
    wrappCMDToBytes(&cmd, bytes);
    int i;
//    Byte temp = 0;
//    for( i=0; i<len-2; i++) {
//        temp += bytes[i];
//    }
//    bytes[i] = temp;
//    NSLog(@"%02x", temp);
    NSMutableString *str = [NSMutableString stringWithString:@""];
    NSInteger length = len;//sizeof(bytes);
//    NSLog(@"%@", [NSData dataWithBytes:bytes length:len]);
    
    for(i=0; i<length; i++) {
        [str appendString:[NSString stringWithFormat:@"%02x", bytes[i]]];
    }
    
    self.textField.textField.text = str;
    
    for(i=0; i<length; i++) {
        [self.ch writeValue:[NSData dataWithBytes:&bytes[i] length:1] completion:nil];
        [NSThread sleepForTimeInterval:0.1];
    }
    
    NSLog(@"str = %@", str);
    free((void *)bytes);
#endif
}
@end
