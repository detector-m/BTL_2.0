//
//  RLLogin.h
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLLocation.h"
#import "RLLocationManager.h"

@interface RLLogin : NSObject
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, unsafe_unretained) RLLocation *location;
@property (nonatomic, weak) NSData *deviceToken;

- (NSDictionary *)toDictionary;
@end
