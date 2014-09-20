//
//  NoteDataManager.m
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//


#import "NoteDataManager.h"
#import <ParcelKit/ParcelKit.h>


@implementation NoteDataManager

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;


#pragma mark -
#pragma mark 싱글턴 모델

//참조: [NoteDataManager sharedNoteDataManager]

+ (instancetype)sharedNoteDataManager
{
    static dispatch_once_t pred;
    static NoteDataManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[NoteDataManager alloc] init];
    });
    return shared;
}


#pragma mark -
#pragma mark 코어데이터 스택

#pragma mark 모델

- (NSManagedObjectModel *)managedObjectModel
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Clarity" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    //NSLog (@"ManagedObjectModel URL: %@\n", modelURL);
    //NSLog (@"NSManaged Object Model > _managedObjectModel: %@\n", _managedObjectModel);
    return _managedObjectModel;
}


#pragma mark 영구 저장소 조율기: 노트 영구저장소 이원화 > 로컬 노트, 드랍박스 노트

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    //NSLog (@"NSFile Manager > Application Documents Directory:\n %@\n", applicationDocumentsDirectory);
    
    //노트 영구 저장소
    {
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Note.sqlite"];
        //        NSLog (@"NoteDataManager > Dropbox Persistent Store URL: %@\n", storeURL);
        
        NSError *error = nil;
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        //lightweight migrations
        NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                   NSInferMappingModelAutomaticallyOption : @(YES)};
        
        if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:options
                                                               error:&error] == NO)
        {
            [self showDropboxCoreDataError];
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    
//    //로컬 노트 영구 저장소
//    {
//        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"LocalNote.sqlite"];
//        //        NSLog (@"NoteDataManager > Local Persistent Store URL: %@\n", storeURL);
//        
//        NSError *error = nil;
//        
//        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//        
//        //lightweight migrations
//        NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
//                                   NSInferMappingModelAutomaticallyOption : @YES};
//        
//        if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
//                                                       configuration:nil
//                                                                 URL:storeURL
//                                                             options:options
//                                                               error:&error] == NO)
//        {
//            [self showLocalCoreDataError];
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
    
    //NSLog (@"NSPersistent Store Coordinator > _persistentStoreCoordinator: %@\n", _persistentStoreCoordinator);
    return _persistentStoreCoordinator;
}


#pragma mark 컨텍스트

- (NSManagedObjectContext *)managedObjectContext
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc]
                                 initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    //    NSLog (@"NoteDataManager > NSManaged Object Context > _managedObjectContext: %@\n", _managedObjectContext);
    return _managedObjectContext;
}


#pragma mark -
#pragma mark 파슬킷 드랍박스 싱크

- (void)setSyncEnabled:(BOOL)enabled
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    
    if (enabled) {
        if (self.syncManager == NO)
        {
            DBAccount *account = [accountManager linkedAccount];
            
            if (account)
            {
                //NSLog (@"DBAccount: %@\n", account);
                
                __weak typeof(self) weakSelf = self;
                [accountManager addObserver:self block:^(DBAccount *account) {
                    typeof(self) strongSelf = weakSelf; if (strongSelf == NO) return;
                    
                    if ([account isLinked] == NO)
                    {
                        [strongSelf setSyncEnabled:NO];
                        NSLog(@"Unlinked account: %@", account.description);
                    }
                }];
                
                DBError *dberror = nil;
                DBDatastore *datastore = [DBDatastore openDefaultStoreForAccount:account error:&dberror];
                
                if (datastore)
                {
                    //NSLog (@"DBDatastore: %@\n", datastore.description);
                    
                    self.syncManager = [[PKSyncManager alloc] initWithManagedObjectContext:self.managedObjectContext datastore:datastore];
                    [self.syncManager setTablesForEntityNamesWithDictionary:@{@"Note": @"notes"}];
                    //NSLog (@"PKSyncManager: %@\n", self.syncManager.description);
                    
                    NSError *error = nil;
                    if ([self addMissingSyncAttributeValueToCoreDataObjects:&error] == NO)
                    {
                        NSLog(@"Error adding missing sync attribute value to Core Data objects: %@", error);
                    }
                    else if ([[datastore getTables:nil] count] == 0)
                    {
                        //드랍박스 테이블 가져오기
                        if ([self updateDropboxFromCoreData:&error] == NO)
                        {
                            NSLog(@"Error updating Dropbox from Core Data: %@", error);
                        }
                    }
                }
                else
                {
                    NSLog(@"Error opening default datastore: %@", dberror);
                }
            }
        }
        
        [self.syncManager startObserving];
        
    } else
    {
        [self.syncManager stopObserving];
        self.syncManager = nil;
        [accountManager removeObserver:self];
    }
}


#pragma mark Add Missing Sync Attribute Value To Core Data Objects

- (BOOL)addMissingSyncAttributeValueToCoreDataObjects:(NSError **)error
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [managedObjectContext setUndoManager:nil];
    
    NSString *syncAttributeName = self.syncManager.syncAttributeName;
    //    NSLog (@"addMissingSyncAttributeValueToCoreDataObjects > syncAttributeName: %@\n", syncAttributeName);
    
    NSArray *entityNames = [self.syncManager entityNames];
    
    for (NSString *entityName in entityNames)
    {
        //        NSLog (@"addMissingSyncAttributeValueToCoreDataObjects > entityName: %@\n", entityName);
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == nil", syncAttributeName]];
        [fetchRequest setFetchBatchSize:25];
        
        NSArray *objects = [managedObjectContext executeFetchRequest:fetchRequest error:error];
        //NSLog (@"managedObjects: %@\n", objects);
        
        if (objects)
        {
            for (NSManagedObject *managedObject in objects)
            {
                NSLog (@"managedObject: %@\n", managedObject.description);
                
                if ([managedObject valueForKey:syncAttributeName] == NO)
                {
                    [managedObject setValue:[PKSyncManager syncID] forKey:syncAttributeName];
                    
                    NSLog (@"managedObject setValue:[PKSyncManager syncID] forKey:syncAttributeName]: %@\n", managedObject.description);
                }
            }
        }
        else
        {
            return NO;
        }
    }
    
    if ([managedObjectContext hasChanges])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(syncManagedObjectContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:managedObjectContext];
        
        BOOL saved = [managedObjectContext save:error];
        kLOGBOOL(saved);
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:managedObjectContext];
        return saved;
    }
    
    return YES;
}


#pragma mark Update Dropbox From Core Data

- (BOOL)updateDropboxFromCoreData:(NSError **)error
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    __block BOOL result = YES;
    
    NSManagedObjectContext *managedObjectContext = self.syncManager.managedObjectContext;
    DBDatastore *datastore = self.syncManager.datastore;
    NSString *syncAttributeName = self.syncManager.syncAttributeName;
    NSLog (@"syncAttributeName: %@\n", syncAttributeName.description);
    
    NSDictionary *tablesByEntityName = [self.syncManager tablesByEntityName];
    NSLog (@"tablesByEntityName: %@\n", tablesByEntityName.description);
    
    [tablesByEntityName enumerateKeysAndObjectsUsingBlock:^(NSString *entityName, NSString *tableId, BOOL *stop) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        NSLog (@"fetchRequest: %@\n", fetchRequest.description);
        [fetchRequest setFetchBatchSize:25];
        
        NSArray *managedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:error];
        if (managedObjects) {
            for (NSManagedObject *managedObject in managedObjects) {
                DBTable *table = [datastore getTable:tableId];
                NSLog (@"DBTable: %@\n", table.description);
                
                DBError *dberror = nil;
                DBRecord *record = [table getOrInsertRecord:[managedObject valueForKey:syncAttributeName] fields:nil inserted:NULL error:&dberror];
                if (record)
                {
                    NSLog (@"DBRecord: %@\n", record.description);
                    [record pk_setFieldsWithManagedObject:managedObject syncAttributeName:syncAttributeName];
                }
                else
                {
                    if (error) {
                        *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
                    }
                    result = NO;
                    *stop = YES;
                }
            }
        }
        else
        {
            *stop = YES;
        }
    }];
    
    if (result)
    {
        DBError *dberror = nil;
        
        if ([datastore sync:&dberror])
        {
            NSLog (@"DBDatastore sync dictionary: %@\n", [datastore sync:&dberror]);
            return YES;
        }
        else
        {
            if (error) *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
            return NO;
        }
    } else {
        return NO;
    }
}


#pragma mark Sync Managed Object Context Did Save

- (void)syncManagedObjectContextDidSave:(NSNotification *)notification
{
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}


#pragma mark -
#pragma mark 코어데이터 에러 대책

#pragma mark  showCoreDataError

- (void)showLocalCoreDataError
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error!"
                          message:@"Local Note can't continue.\nPress the Home button to close Note."
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil];
    [alert show];
}


- (void)showDropboxCoreDataError
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error!"
                          message:@"Dropbox Note can't continue.\nPress the Home button to close Note."
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil];
    [alert show];
}


@end