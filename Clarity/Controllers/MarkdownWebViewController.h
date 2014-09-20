//
//  MarkdownWebViewController.h
//  SwiftNote
//
//  Created by jun on 6/8/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropboxNote;
@class LocalNote;
@class Note;

@interface MarkdownWebViewController : UIViewController

@property (nonatomic, strong) LocalNote *currentLocalNote;
@property (nonatomic, strong) DropboxNote *currentDropboxNote;
@property (nonatomic, strong) Note *currentNote;

@end
