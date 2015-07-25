//
//  KeyEntity.h
//  Smartlock
//
//  Created by RivenL on 15/5/25.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "KeyModel.h"

extern NSDictionary *keyEntityDictionaryFromKeyModel(KeyModel *key);

@class LockEntity;

@interface KeyEntity : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * endDate;
@property (nonatomic, retain) NSNumber * keyID;
@property (nonatomic, retain) NSNumber * lockID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ownUser;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * useCount;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) LockEntity *ownLock;

@end
