//
//  RLRegister.m
//  Smartlock
//
//  Created by RivenL on 15/4/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLRegister.h"

@interface RLRegister ()
@property (nonatomic, readwrite, unsafe_unretained) id user;
@end

@implementation RLRegister
- (instancetype)init {
    if(self = [super init]) {
//        _user = [RLUser sharedUser];
        self.user = [RLUser sharedUser];
    }
    
    return self;
}
@end
