//
//  DropboxAddEditViewController.h
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxNote.h"


@interface DropboxAddEditViewController : UIViewController

@property (strong, nonatomic) DropboxNote *currentNote;
@property (nonatomic, assign) BOOL isSearchResultNote;
@property (nonatomic, assign) BOOL isNewNote;
@property (nonatomic, assign) BOOL isDropboxNote;
@property (nonatomic, assign) BOOL isLocalNote;
@property (nonatomic, assign) BOOL isiCloudNote;
@property (nonatomic, assign) BOOL isOtherCloudNote;

- (void)note:(DropboxNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;   //스토리보드

@end
