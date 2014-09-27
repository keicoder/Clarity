//
//  DropboxAddEditViewController.h
//  Clarity
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"


@interface DropboxAddEditViewController : UIViewController

@property (strong, nonatomic) Note *currentNote;

- (void)note:(Note *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
