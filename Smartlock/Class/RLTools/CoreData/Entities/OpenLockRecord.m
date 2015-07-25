//
//  OpenLockRecord.m
//  Smartlock
//
//  Created by RivenL on 15/5/23.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "OpenLockRecord.h"
#import "RLDate.h"

NSDictionary *createOpenLockRecord(NSUInteger keyID, NSUInteger lockID) {
    return @{@"keyID":[NSNumber numberWithLongLong:keyID], @"lockID":[NSNumber numberWithLongLong:lockID], @"timeinterval":[NSNumber numberWithLongLong: timestampSince1970WithReal()*1000], @"isUpdate":@NO};
}

extern NSString *openLockRecordToString(NSDictionary *record) {
    return [NSString stringWithFormat:@"%lld:%lld", [record[@"keyID"] longLongValue], [record[@"timeinterval"] longLongValue]];
}

@implementation OpenLockRecord

@dynamic keyID;
@dynamic lockID;
@dynamic timeinterval;
@dynamic isUpdate;

- (NSString *)toString {
    return [NSString stringWithFormat:@"%lld:%lld", [self.keyID longLongValue], [self.timeinterval longLongValue]];
}
@end
