//
//  RLUser.m
//  Smartlock
//
//  Created by RivenL on 15/4/10.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLUser.h"
#import "RLUtilitiesMethods.h"

NSString *kVoiceSwitchKey = @"voiceSwitchKey";
NSString *kAutoOpenlockSwitchKey = @"autoOpenlockSwitchKey";

#pragma mark -

@implementation RLUser

+ (instancetype)sharedUser {
    static id _user = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _user = [[[self class] alloc] init];
    });
    
    return _user;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _ID = [aDecoder decodeIntegerForKey:@"ID"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.gender = [aDecoder decodeIntegerForKey:@"gender"];
        self.age = [aDecoder decodeIntegerForKey:@"age"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.sessionToken = [aDecoder decodeObjectForKey:@"sessionToken"];
        self.deviceToken = [aDecoder decodeObjectForKey:@"deviceToken"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeInteger:self.gender forKey:@"gender"];
    [aCoder encodeInteger:self.age forKey:@"age"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.sessionToken forKey:@"sessionToken"];
    [aCoder encodeObject:self.deviceToken forKey:@"deviceToken"];
}

#pragma mark - 
- (void)setWithUser:(id)aUser {
    if(aUser == nil)
        return;
    __typeof(self)user = aUser;
    
    _ID = user.ID;
    _name = user.name;
    self.nickname = user.nickname;
    self.phone = user.phone;
    self.gender = user.gender;
    self.age = user.age;
    self.location = user.location;
    self.sessionToken = user.sessionToken;
    self.deviceToken = user.deviceToken;
}

- (void)setWithParameters:(NSDictionary *)parameters {

}

#pragma mark - 
- (NSString *)deviceTokenString {
    return hexStringFromData(self.deviceToken);
}

#pragma mark -
+ (BOOL)saveArchiver {
    //获取路径和保存文件
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filename = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"user.dat"];
    
    // 确定存储路径，一般是Document目录下的文件
    if(![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        if(![[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil]) {
            return NO;
        }
    }
    
    id user = [RLUser sharedUser];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:user forKey:@"User"];
    [archiver finishEncoding];
    [data writeToFile:filename atomically:YES];
    
    return YES;
}
+ (id)loadArchiver {
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filename = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"user.dat"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return nil;
    }
    
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:filename];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    id user = [unarchiver decodeObjectForKey:@"User"];
    [unarchiver finishDecoding];
    return user;
}

+ (void)removeArchiver {
    //删除归档文件
    //获取路径和保存文件
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filename = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"user.dat"];

    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager isDeletableFileAtPath:filename]) {
        [defaultManager removeItemAtPath:filename error:nil];
    }
}

#pragma mark -
+ (BOOL)getVoiceSwitch {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *voiceSwitch = [userDefault objectForKey:kVoiceSwitchKey];
    if(voiceSwitch == nil)
        return NO;
    
    return voiceSwitch.boolValue;
}
+ (void)setVoiceSwitch:(BOOL)on {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *voiceSwitch = [userDefault objectForKey:kVoiceSwitchKey];
    if(voiceSwitch == nil) {
    }
    else if(on == voiceSwitch.boolValue)
        return;
    
    [userDefault setObject:[NSNumber numberWithBool:on] forKey:kVoiceSwitchKey];
    [userDefault synchronize];
}

+ (BOOL)getAutoOpenLockSwitch {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *aSwitch = [userDefault objectForKey:kAutoOpenlockSwitchKey];
    if(aSwitch == nil)
        return NO;
    
    return aSwitch.boolValue;
}

+ (void)setAutoOpenLockSwitch:(BOOL)on {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *aSwitch = [userDefault objectForKey:kAutoOpenlockSwitchKey];
    if(aSwitch == nil) {
    }
    else if(on == aSwitch.boolValue)
        return;
    
    [userDefault setObject:[NSNumber numberWithBool:on] forKey:kAutoOpenlockSwitchKey];
    [userDefault synchronize];
}
@end
