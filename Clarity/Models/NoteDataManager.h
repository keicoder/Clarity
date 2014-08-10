//
//  NoteDataManager.h
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NoteDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedNoteDataManager;

- (void)setSyncEnabled:(BOOL)enabled;

@end
