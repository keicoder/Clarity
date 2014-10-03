//
//  LocalAddEditViewController.h
//  Clarity
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalNote.h"


@interface LocalAddEditViewController : UIViewController

@property (strong, nonatomic) LocalNote *currentNote;

- (void)note:(LocalNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
