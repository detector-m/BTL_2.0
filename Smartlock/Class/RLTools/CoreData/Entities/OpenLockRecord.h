//
//  OpenLockRecord.h
//  Smartlock
//
//  Created by RivenL on 15/5/23.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSDictionary *createOpenLockRecord(NSUInteger keyID, NSUInteger lockID);

extern NSString *openLockRecordToString(NSDictionary *record);
@interface OpenLockRecord : NSManagedObject

@property (nonatomic, retain) NSNumber * keyID;
@property (nonatomic, retain) NSNumber * lockID;
@property (nonatomic, retain) NSNumber * timeinterval;
@property (nonatomic, retain) NSNumber * isUpdate;

- (NSString *)toString;
@end
