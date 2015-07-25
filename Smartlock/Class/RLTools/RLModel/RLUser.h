//
//  RLUser.h
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLLogin.h"

typedef NS_ENUM(NSInteger, GenderType) {
    kGenderNone,
    kGenderFemale,
    kGenderMale
};

@interface RLUser : NSObject <NSCoding>
@property (nonatomic, readonly, assign) NSUInteger ID;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readwrite, copy) NSString *nickname;
@property (nonatomic, readwrite, copy) NSString *phone;
@property (nonatomic, readwrite, assign) GenderType gender;
@property (nonatomic, readwrite, assign) NSUInteger age;

@property (nonatomic, unsafe_unretained) RLLocation *location;

@property (nonatomic, copy) NSString *sessionToken;
@property (nonatomic, strong) NSData *deviceToken;
@property (nonatomic, weak) NSString *deviceTokenString;
@property (nonatomic, assign) BOOL isLogined;

+ (instancetype)sharedUser;
+ (BOOL)saveArchiver;
+ (id)loadArchiver;
+ (void)removeArchiver;

- (void)setWithUser:(id)user;
- (void)setWithParameters:(NSDictionary *)parameters;

#pragma mark -
+ (BOOL)getVoiceSwitch;
+ (void)setVoiceSwitch:(BOOL)on;

+ (BOOL)getAutoOpenLockSwitch;
+ (void)setAutoOpenLockSwitch:(BOOL)on;
@end
