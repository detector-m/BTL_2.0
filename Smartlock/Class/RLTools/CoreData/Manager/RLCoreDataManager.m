//
//  RLCoreDataManager.m
//  Smartlock
//
//  Created by RivenL on 15/4/28.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "RLCoreDataManager.h"

@interface RLCoreDataManager ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator  *persistentSotoreCoordinator;
@end

@implementation RLCoreDataManager
- (void)dealloc {

}

#pragma mark - Abstract method exceptions
+ (NSURL *)modelURL {
    NSString *selector = NSStringFromSelector(_cmd);
    [NSException raise:NSInternalInconsistencyException format:@"%@ is abstract method You must override %@ method in %@ class and must not call [super %@].", selector, selector, NSStringFromClass([self class]), selector];
    
    return nil;
}

//static NSString *_identifier = nil;
//+ (void)setIdentifier:(NSString *)identifier {
//
//    _identifier = [NSString stringWithString:identifier];
//}
//
//+ (NSString *)identifier {
//    if(_identifier == nil)
//        _identifier = @"default";
//    return _identifier;
//}

+ (instancetype)sharedManager {
    static NSMutableDictionary *_sharedDictionary = nil;
    id sharedObject = nil;
    
    if(_sharedDictionary == nil) {
        _sharedDictionary = [[NSMutableDictionary alloc] init];
    }
    
    sharedObject = [_sharedDictionary objectForKey:NSStringFromClass([self class])];
    
    if(sharedObject == nil) {
        if(![NSStringFromClass([self class]) isEqualToString:NSStringFromClass([RLCoreDataManager class])]) {
            sharedObject = [[self alloc] init];
            
            [_sharedDictionary setObject:sharedObject forKey:NSStringFromClass([self class])];
        }
        else {
            [NSException raise:NSInternalInconsistencyException format:@"You must subclass %@",NSStringFromClass([RLCoreDataManager class])];
            return nil;
        }
    }
    
    return sharedObject;
}

#pragma mark -
- (instancetype)init {
    if(self = [super init]) {
        _identifier = @"default";
        [self setupCoredataManager];
    }
    
    return self;
}

- (void)setupCoredataManager {
    if(self.managedObjectModel)
        [self save];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[self class] modelURL]];
    
    //initializing persistentstorecoordinator with managedObjectModel
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@.sqlite", NSStringFromClass([self class]), _identifier]];
    
    NSError *error = nil;
    self.persistentSotoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if(![self.persistentSotoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"PersistentStore Error: %@, %@", error, [error userInfo]);
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        abort();
    }
    
    // initializing managedObjectContext with persistentStoreCoordinator
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentSotoreCoordinator];
}

#pragma mark -
- (void)setIdentifier:(NSString *)identifier {
    if(!identifier)
        return;
    _identifier = identifier;
    [self setupCoredataManager];
}
#pragma mark -
- (BOOL)save {
    NSError *error = nil;
    BOOL ret = [self.managedObjectContext save:&error];
    return ret;
}

- (NSArray *)tableNames {
    NSDictionary *entities = [self.managedObjectModel entitiesByName];
    
    return [entities allKeys];
}

- (NSDictionary *)attributesForTable:(NSString *)tableName {
    NSEntityDescription *description = [[self.managedObjectModel entitiesByName] objectForKey:tableName];
    NSDictionary *properties = [description propertiesByName];
    NSArray *allKeys = properties.allKeys;
    
    NSMutableDictionary *attributeDictionary = [[NSMutableDictionary alloc] init];
    for(NSString *key in allKeys) {
        if([[properties objectForKey:key] attributeType] ==     NSTransformableAttributeType) {
            [attributeDictionary setObject:@"id" forKey:key];
        }
        else {
            NSString *attributeClassName = [[properties objectForKey:key] attributeValueClassName];
            if(attributeClassName) {
                [attributeDictionary setObject:attributeClassName forKey:key];
            }
        }
    }
    
    return attributeDictionary;
}

#pragma mark - Fetch Records
- (NSArray *)allObjectsFromTable:(NSString *)tableName wherePredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor {
    //creating fetch request object for fetching records.
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:tableName];
#if 1
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesSubentities:YES];
    [fetchRequest setReturnsObjectsAsFaults:NO];
#endif
    
#if TARGET_IPHONE_SIMULATOR
    [fetchRequest setReturnsObjectsAsFaults:NO];
#endif
    
    if(predicate) {
        [fetchRequest setPredicate:predicate];
    }
    if(descriptor) {
        [fetchRequest setSortDescriptors:@[descriptor]];
    }
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (NSArray *)allObjectsFromTable:(NSString *)tableName sortDescriptor:(NSSortDescriptor *)descriptor {
    return [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:descriptor];
}

- (NSArray *)allObjectsFromTable:(NSString *)tableName wherePredicate:(NSPredicate *)predicate {
    return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:nil];
}

- (NSArray *)allObjectsFromTable:(NSString *)tableName {
    return [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:nil];
}

#pragma mark -
/*** Key Value predicate ***/
- (NSArray *)allObjectsFromTable:(NSString *)tableName where:(NSString *)key equals:(id)value sortDescriptor:(NSSortDescriptor *)descriptor {
    if(key && value) {
        if([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDate class]]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ == %@", key, value];
            
            return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:descriptor];
        }
        else {
            NSArray *allObjects = [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:descriptor];
            NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
            
            for(NSManagedObject *object in allObjects) {
                if([[object valueForKey:key] isEqual:value]) {
                    [filteredArray addObject:object];
                }
            }
            
            return filteredArray;
        }
    }
    else {
        return [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:descriptor];
    }
}

- (NSArray *)allObjectsFromTable:(NSString *)tableName where:(NSString *)key equals:(id)value {
    return [self allObjectsFromTable:tableName where:key equals:value sortDescriptor:nil];
}

- (NSArray *)allObjectsFromTable:(NSString *)tableName where:(NSString *)key contains:(id)value sortDescriptor:(NSSortDescriptor *)descriptor {
    NSPredicate *predicate;
    if(key && value) {
        NSString *predicateString = [NSString stringWithFormat:@"self.%@ contains[c] \"%@\"", key, value];
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    
    return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:descriptor];
}

- (NSArray *)allObjectsFromTable:(NSString *)tableName where:(NSString *)key contains:(id)value {
    return [self allObjectsFromTable:tableName where:key contains:value sortDescriptor:nil];
}

/*First/Last object*/
- (NSManagedObject *)firstObjectFromTable:(NSString *)tableName {
    return [[self allObjectsFromTable:tableName] firstObject];
}

- (NSManagedObject *)lastObjectFromTable:(NSString *)tableName {
    return [[self allObjectsFromTable:tableName] lastObject];
}

#pragma mark - Insert & Update Records 
//Update object
- (NSManagedObject *)updateRecord:(NSManagedObject *)object withAttribute:(NSDictionary *)dictionary {
    NSArray *allKeys = [dictionary allKeys];
    
    for(NSString *aKey in allKeys) {
        id value = [dictionary objectForKey:aKey];
        [object setValue:value forKey:aKey];
    }
    
    [self save];
    
    return object;
}

//Insert objects
- (NSManagedObject *)insertRecordInTable:(NSString *)tableName withAttribute:(NSDictionary *)dictionary {
    //creating NSManagedObject for inserting records
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    
    return [self updateRecord:object withAttribute:dictionary];
}

- (NSManagedObject *)firstObjectFromTable:(NSString *)tableName createIfNotExist:(BOOL)create {
    NSManagedObject *object = [self firstObjectFromTable:tableName];
    
    if(object == nil && create == YES) {
        object = [self insertRecordInTable:tableName withAttribute:nil];
    }
    
    return object;
}

- (NSManagedObject *)lastObjectFromTable:(NSString *)tableName createIfNotExist:(BOOL)create {
    NSManagedObject *object = [self lastObjectFromTable:tableName];
    
    if(object == nil && create == YES) {
        object = [self insertRecordInTable:tableName withAttribute:nil];
    }
    
    return object;
}

#pragma mark -
- (NSManagedObject *)firstObjectFromTable:(NSString *)tableName where:(NSString *)key equals:(id)value {
    return [[self allObjectsFromTable:tableName where:key equals:value] firstObject];
}

- (NSManagedObject *)firstObjectFromTable:(NSString *)tableName wherePredicate:(NSPredicate *)predicate {
    return [[self allObjectsFromTable:tableName wherePredicate:predicate] firstObject];
}

- (NSManagedObject *)lastObjectFromTable:(NSString *)tableName where:(NSString *)key equals:(id)value {
    return [[self allObjectsFromTable:tableName where:key equals:value] lastObject];
}

- (NSManagedObject *)lastObjectFromTable:(NSString *)tableName wherePredicate:(NSPredicate *)predicate {
    return [[self allObjectsFromTable:tableName wherePredicate:predicate] firstObject];
}

- (NSManagedObject *)insertRecordInTable:(NSString *)tableName withAttribute:(NSDictionary *)dictionary updateOnExistKey:(NSString *)key equals:(id)value {
    NSManagedObject *object = [self firstObjectFromTable:tableName where:key equals:value];
    
    if(object) {
        return [self updateRecord:object withAttribute:dictionary];
    }
    else {
        return [self insertRecordInTable:tableName withAttribute:dictionary];
    }
}

#pragma mark - Delete Records
//Delete all records in table.
- (BOOL)flushTable:(NSString *)tableName {
    NSArray *records = [self allObjectsFromTable:tableName];
    
    for(NSManagedObject *object in records) {
        [self.managedObjectContext deleteObject:object];
    }
    
    return [self save];
}

// Delete object
- (BOOL)deleteRecord:(NSManagedObject *)object {
    [self.managedObjectContext deleteObject:object];
    
    return [self save];
}

#pragma mark -
- (NSManagedObject *)insertRecordForTable:(NSString *)tableName  {
    //creating NSManagedObject for inserting records
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    
    return object;
}

- (NSManagedObject *)insertRecordForTable:(NSString *)tableName attributes:(NSDictionary *)attributes {
    NSManagedObject *object = [self insertRecordForTable:tableName];
    
    NSArray *allKeys = [attributes allKeys];
    
    for(NSString *aKey in allKeys) {
        id value = [attributes objectForKey:aKey];
        [object setValue:value forKey:aKey];
    }
    
    return object;
}
@end
