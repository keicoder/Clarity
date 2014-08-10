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

@interface NoteTitlePopinViewController : UIViewController

@property (nonatomic, strong) LocalNote *currentLocalNote;
@property (nonatomic, strong) DropboxNote *currentDropboxNote;
@property (nonatomic, assign) BOOL isLocalNote;
@property (nonatomic, assign) BOOL isDropboxNote;                

#pragma mark - 노트 in Managed Object Context
- (void)localNote:(LocalNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)dropboxNote:(DropboxNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
