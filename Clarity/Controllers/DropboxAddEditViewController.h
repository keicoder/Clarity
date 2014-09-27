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
@property (nonatomic, strong) UIToolbar *keyboardAccessoryToolBar;

- (void)note:(Note *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)addKeyboardAccessoryToolBar;
- (void)previousCharacterButtonPressed:(id)sender;
- (void)nextCharacterButtonPressed:(id)sender;
- (void)hideKeyboardButtonPressed:(id)sender;
- (void)hashButtonPressed:(id)sender;
- (void)asteriskButtonPressed:(id)sender;
- (void)tabButtonPressed:(id)sender;
- (void)selectWordButonPressed:(id)sender;


@end
