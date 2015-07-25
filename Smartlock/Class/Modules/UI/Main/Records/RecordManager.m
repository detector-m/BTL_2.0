//
//  RecordManager.m
//  Smartlock
//
//  Created by RivenL on 15/5/23.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RecordManager.h"
#import "KeyEntity.h"

@implementation RecordManager
+ (void)updateRecordsWithBlock:(void (^)(BOOL success))block {
    NSArray *records = [[MyCoreDataManager sharedManager] objectsSortByAttribute:nil where:@"isUpdate" contains:@NO withTabelname:NSStringFromClass([OpenLockRecord class])];
    if(!records.count)
        return;
    NSString *recordsListString = @"";
//    [RecordManager removeRecordsWithKeyID:[((OpenLockRecord *)[records firstObject]).keyID longLongValue]];
    for(OpenLockRecord *record in records) {
        DLog(@"%@", record);
        recordsListString = [recordsListString stringByAppendingString:record.toString];
        recordsListString = [recordsListString stringByAppendingString:@","];
    }
    recordsListString = [recordsListString stringByReplacingCharactersInRange:NSMakeRange(recordsListString.length-1, 1) withString:@""];
    
    [DeviceManager openLock:recordsListString token:[User sharedUser].sessionToken withBlock:^(DeviceResponse *response, NSError *error) {
        [[MyCoreDataManager sharedManager] updateObjectsInObjectTable:@{@"isUpdate":@YES} withKey:@"isUpdate" contains:@NO withTablename:NSStringFromClass([OpenLockRecord class])];
        if(block) {
            block(YES);
        }
    }];
}

+ (void)removeRecordsWithAddress:(NSString *)address {
    NSArray *array = [[MyCoreDataManager sharedManager] objectsSortByAttribute:nil withTablename:NSStringFromClass([KeyEntity class])];
    for(KeyEntity *key in array) {
        LockEntity *lock = key.ownLock;
        if([lock.address isEqualToString:address]) {
            [self removeRecordsWithKeyID:[key.keyID longLongValue]];
            return;
        }
    }
}
+ (void)removeRecordsWithKeyID:(long long)keyID {
    NSArray *records = [[MyCoreDataManager sharedManager] objectsSortByAttribute:nil where:@"keyID" contains:[NSNumber numberWithLongLong:keyID] withTabelname:NSStringFromClass([OpenLockRecord class])];
    for(OpenLockRecord *record in records) {
        [[MyCoreDataManager sharedManager] deleteRecord:record];
    }
}

@end
