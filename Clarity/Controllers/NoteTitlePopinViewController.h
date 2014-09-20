//
//  NoteTitlePopinViewController.h
//  SwiftNote
//
//  Created by jun on 2014. 7. 12..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalNote;
@class DropboxNote;
@class Note;


@interface NoteTitlePopinViewController : UIViewController

@property (nonatomic, strong) LocalNote *currentLocalNote;
@property (nonatomic, strong) DropboxNote *currentDropboxNote;
@property (nonatomic, strong) Note *currentNote;
@property (nonatomic, assign) BOOL isLocalNote;
@property (nonatomic, assign) BOOL isDropboxNote;
@property (nonatomic, assign) BOOL isiCloudNote;
@property (nonatomic, assign) BOOL isOtherCloudNote;

#pragma mark - 노트 in Managed Object Context
- (void)localNote:(LocalNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)dropboxNote:(DropboxNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)note:(Note *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
