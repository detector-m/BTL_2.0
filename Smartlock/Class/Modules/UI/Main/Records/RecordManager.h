//
//  RecordManager.h
//  Smartlock
//
//  Created by RivenL on 15/5/23.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyCoreDataManager.h"
#import "OpenLockRecord.h"

#import "DeviceManager.h"

@interface RecordManager : NSObject
#pragma mark -
+ (void)updateRecordsWithBlock:(void (^)(BOOL success))block;

+ (void)removeRecordsWithAddress:(NSString *)address;
+ (void)removeRecordsWithKeyID:(long long)keyID;
@end
