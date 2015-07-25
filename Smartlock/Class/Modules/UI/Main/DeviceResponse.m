//
//  DeviceResponse.m
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "DeviceResponse.h"

@implementation DeviceResponse
- (instancetype)initWithResponseObject:(id)responseObject {
    if(self = [super initWithResponseObject:responseObject]) {
        if(self.status == 0) {
            NSDictionary *resDic = responseObject;
            [self parserLockList:[resDic objectForKey:@"bleKeys"]];
        }
    }
    
    return self;
}

- (void)parserLockList:(NSArray *)list {
    if(!list) {
        return;
    }
    self.list = [NSMutableArray new];
    KeyModel *key = nil;
    
//    DLog(@"%@", list);
    for(NSDictionary *dicKey in list) {
        key = [[KeyModel alloc] initWithParameters:dicKey];
        [self.list addObject:key];
    }
}
@end
