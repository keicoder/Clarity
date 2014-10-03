//
//  MarkdownWebViewController.h
//  SwiftNote
//
//  Created by jun on 6/8/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;
@class LocalNote;

@interface MarkdownWebViewController : UIViewController

@property (nonatomic, strong) Note *currentNote;
@property (nonatomic, strong) LocalNote *currentLocalNote;

@end
