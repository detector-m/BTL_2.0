//
//  CBUUID+StringExtraction.h
//  Smartlock
//
//  Created by RivenL on 15/3/16.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBUUID (StringExtraction)
- (NSString *)representativeString;
@end
