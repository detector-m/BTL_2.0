//
//  LockEntity.h
//  Smartlock
//
//  Created by RivenL on 15/5/25.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "LockModel.h"

@class LockModel;
extern NSDictionary *lockEntityDictionaryFromLockModel(LockModel *lock);
@class KeyEntity;

@interface LockEntity : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSNumber * lockID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ownUser;
@property (nonatomic, retain) NSNumber * pwd;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) KeyEntity *oneKey;

@end
