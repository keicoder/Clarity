//
//  NoteTitlePopinViewController.h
//  SwiftNote
//
//  Created by jun on 2014. 7. 12..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;


@interface NoteTitlePopinViewController : UIViewController

@property (nonatomic, strong) Note *currentNote;
@property (nonatomic, assign) BOOL isLocalNote;
@property (nonatomic, assign) BOOL isDropboxNote;
@property (nonatomic, assign) BOOL isiCloudNote;
@property (nonatomic, assign) BOOL isOtherCloudNote;

- (void)note:(Note *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
