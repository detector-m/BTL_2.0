//
//  DeviceResponse.h
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "BaseResponse.h"
#import "KeyModel.h"

@interface DeviceResponse : BaseResponse
@property (nonatomic, strong) NSMutableArray *list;
@end
