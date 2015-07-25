//
//  KeyEntity.m
//  Smartlock
//
//  Created by RivenL on 15/5/25.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "KeyEntity.h"
#import "LockEntity.h"

#import "MyCoreDataManager.h"

NSDictionary *keyEntityDictionaryFromKeyModel(KeyModel *key) {
    if(key == nil)
        return nil;
    
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:[NSNumber numberWithInteger:key.ID] forKey:@"keyID"];
    [muDic setObject:[NSNumber numberWithInteger:key.lockID] forKey:@"lockID"];
    [muDic setObject:[NSNumber numberWithInteger:key.type] forKey:@"type"];
    [muDic setObject:[NSNumber numberWithInteger:key.status] forKey:@"status"];
    [muDic setObject:[NSNumber numberWithInteger:key.userType] forKey:@"userType"];
    [muDic setObject:[NSNumber numberWithInteger:key.validCount] forKey:@"useCount"];
    [muDic setObject:key.name?:@"" forKey:@"name"];
    [muDic setObject:key.caption?:@"" forKey:@"caption"];
    [muDic setObject:key.ower?:@"" forKey:@"ownUser"];
    [muDic setObject:key.invalidDate?:@"" forKey:@"endDate"];
    
    LockEntity *lock = (LockEntity *)[[MyCoreDataManager sharedManager] insertRecordForTable:NSStringFromClass([LockEntity class]) attributes:lockEntityDictionaryFromLockModel(key.keyOwner)];
    [muDic setObject:lock forKey:@"ownLock"];
    
    return muDic;
}

@implementation KeyEntity

@dynamic caption;
@dynamic endDate;
@dynamic keyID;
@dynamic lockID;
@dynamic name;
@dynamic ownUser;
@dynamic status;
@dynamic type;
@dynamic useCount;
@dynamic userType;
@dynamic ownLock;

@end
