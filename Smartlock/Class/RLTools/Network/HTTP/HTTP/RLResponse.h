//
//  RLResponse.h
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLResponse : NSObject
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *resDescription;

@property (nonatomic, assign) NSUInteger errorCode;

@property (nonatomic, readonly, assign) BOOL success;

- (instancetype)initWithResponseObject:(id)responseObject;

- (void)checkStatus;
@end
