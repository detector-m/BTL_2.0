//
//  RLLogin.m
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLLogin.h"

@implementation RLLogin

- (instancetype)init {
    if(self = [super init]) {
        self.location = [RLLocationManager sharedLocationManager].curLoction;
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return nil;
}
@end
