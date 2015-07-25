//
//  RLBTLResponse.h
//  GlobalVillage
//
//  Created by RivenL on 15/7/9.
//  Copyright (c) 2015年 dqcc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLPeripheralResponse : NSObject
@property (nonatomic, assign) BOOL isCRCOk;
@property (nonatomic, assign) Byte cmdCode;
@property (nonatomic, assign) Byte result;

@property (nonatomic, assign) Byte powerCode;
@property (nonatomic, assign) Byte updateTimeCode;

@property (nonatomic, assign) long long userPwd;

@property (nonatomic, strong) NSData *timeData;
@end
