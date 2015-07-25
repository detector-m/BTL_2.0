//
//  LockEntity.m
//  Smartlock
//
//  Created by RivenL on 15/5/25.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "LockEntity.h"
#import "KeyEntity.h"

NSDictionary *lockEntityDictionaryFromLockModel(LockModel *lock) {
    if(lock == nil)
        return nil;
    
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:[NSNumber numberWithInteger:lock.ID] forKey:@"lockID"];
    [muDic setObject:[NSNumber numberWithLongLong:lock.pwd] forKey:@"pwd"];
    [muDic setObject:[NSNumber numberWithInteger:lock.type] forKey:@"type"];
    [muDic setObject:[NSNumber numberWithInteger:lock.status] forKey:@"status"];
    [muDic setObject:lock.name?:@"" forKey:@"name"];
    [muDic setObject:lock.caption?:@"" forKey:@"caption"];
    [muDic setObject:lock.ower?:@"" forKey:@"ownUser"];
    [muDic setObject:lock.address?:@"" forKey:@"address"];

    return muDic;
}

@implementation LockEntity

@dynamic address;
@dynamic caption;
@dynamic lockID;
@dynamic name;
@dynamic ownUser;
@dynamic pwd;
@dynamic status;
@dynamic type;
@dynamic oneKey;

@end
