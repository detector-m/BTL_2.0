//
//  RLPeripheralRequest.h
//  GlobalVillage
//
//  Created by RivenL on 15/7/10.
//  Copyright (c) 2015年 dqcc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLPeripheralRequest : NSObject
@property (nonatomic, assign) Byte cmdCode;
@property (nonatomic, assign) Byte cmdMode;

#pragma mark -
@property (nonatomic, assign) NSInteger userType;
@property (nonatomic, assign) long long userPwd;

@property (nonatomic, strong) NSString *invalidDate; //截至日期
@end
