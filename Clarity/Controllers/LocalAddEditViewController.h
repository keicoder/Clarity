//
//  LocalAddEditViewController.h
//  SwiftNote
//
//  Created by jun on 6/5/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalNote.h"


@interface LocalAddEditViewController : UIViewController

@property (strong, nonatomic) LocalNote *currentNote;
@property (nonatomic, assign) BOOL isSearchResultNote;
@property (nonatomic, assign) BOOL isNewNote;
@property (nonatomic, assign) BOOL isDropboxNote;
@property (nonatomic, assign) BOOL isLocalNote;
@property (nonatomic, assign) BOOL isiCloudNote;
@property (nonatomic, assign) BOOL isOtherCloudNote;

- (void)note:(LocalNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
