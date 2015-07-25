//
//  DeviceModel.m
//  Smartlock
//
//  Created by RivenL on 15/4/14.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "DeviceModel.h"

#import "RLSecurityPolicy.h"

@implementation DeviceModel
- (instancetype)initWithParameters:(NSDictionary *)parameters {
    if(self = [super init]) {
        self.ID = [parameters[@"id"] integerValue];
        self.status = [parameters[@"status"] integerValue];
        self.time = [parameters objectForKey:@"addTime"];
        self.ower = [parameters objectForKey:@"memberGid"];
        
        self.user = [[DeviceUser alloc] init];
        [self.user setWithParameters:[parameters objectForKey:@"member"]];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return @{};
}

#pragma mark -
+ (NSDictionary *)lockListParameters:(NSString *)accessToken {
    return @{@"accessToken":encryptedTokenToBase64(accessToken, [User sharedUser].certificazte)};
}
+ (NSDictionary *)modifyKeyNameParameters:(NSInteger)keyId gid:(NSString *)gid token:(NSString *)token keyName:(NSString *)keyName {
    return @{@"id":[RLTypecast integerToString:keyId], @"memberGid":gid, @"lockName":keyName, @"accessToken":encryptedTokenToBase64(token, [User sharedUser].certificazte)};
}

+ (NSDictionary *)keyListOfAdminParameters:(NSString *)token lockID:(NSUInteger)lockID {
    return @{@"accessToken":encryptedTokenToBase64(token, [User sharedUser].certificazte), @"bleLockId":[RLTypecast integerToString:lockID]};
}

+ (NSDictionary *)lockOrUnlockKeyParameters:(NSUInteger)keyID operation:(NSUInteger)operation token:(NSString *)token {
    return @{@"bleKeyId":[RLTypecast integerToString:keyID], @"flag":[RLTypecast integerToString:operation], @"accessToken":encryptedTokenToBase64(token, [User sharedUser].certificazte)};
}

+ (NSDictionary *)deleteKeyParameters:(NSUInteger)keyID token:(NSString *)token {
    return @{@"bleKeyId":[RLTypecast integerToString:keyID], @"accessToken":encryptedTokenToBase64(token, [User sharedUser].certificazte)};
}

+ (NSDictionary *)openLockParameters:(NSString *)recordList token:(NSString *)token {
    return @{@"dataList":recordList, @"accessToken":encryptedTokenToBase64(token, [User sharedUser].certificazte)};
}

@end
