//
//  MyCoreDataManager.h
//  Smartlock
//
//  Created by RivenL on 15/4/29.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLCoreDataManager.h"
#import "MyDatabaseConstants.h"
#import "RLCoreDataManagerSubclass.h"

@interface MyCoreDataManager : RLCoreDataManager
//- (NSArray *)allRecordsSortByAttribute:(NSString *)attribute;
//- (NSArray *)allRecordsSortByAttribute:(NSString *)attribute where:(NSString *)key contains:(id)value;
//
//- (RecordTable *) insertRecordInRecordTable:(NSDictionary *)recordAttributes;
//- (RecordTable *) insertUpdateRecordInRecordTable:(NSDictionary *)recordAttributes;
//- (RecordTable *) updateRecord:(RecordTable *)record inRecordTable:(NSDictionary *)recordAttributes;
//- (BOOL) deleteTableRecord:(RecordTable *)record;
//
//
//- (BOOL) deleteAllTableRecord;

#pragma mark -
- (NSArray *)objectsSortByAttribute:(NSString *)attribute withTablename:(NSString *)tablename;
- (NSArray *)objectsSortByAttribute:(NSString *)attribute where:(NSString *)key contains:(id)value withTabelname:(NSString *)tablename;

- (NSInteger)objectsCountWithKey:(NSString *)key contains:(id)value withTablename:(NSString *)tablename;

- (id)insertObjectInObjectTable:(NSDictionary *)objectAttributes withTablename:(NSString *)tablename;
- (id)insertUpdateObjectInObjectTable:(NSDictionary *)objectAttributes updateOnExistKey:(NSString *)key withTablename:(NSString *)tablename;
- (id)updateObject:(id)object inObjectTable:(NSDictionary*)objectAttributes withTablename:(NSString *)tablename;
- (NSArray *)updateObjectsInObjectTable:(NSDictionary *)objectAttributes withKey:(NSString *)key contains:(id)value withTablename:(NSString *)tablename;

- (BOOL)deleteTableRecord:(id)object withTablename:(NSString *)tablename;;

- (BOOL)deleteAllTableObjectInTable:(NSString *)tablename;

#pragma mark - 
@end
