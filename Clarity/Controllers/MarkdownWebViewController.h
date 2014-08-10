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


@interface MarkdownWebViewController : UIViewController

@property (nonatomic, strong) LocalNote *currentLocalNote;
@property (nonatomic, strong) DropboxNote *currentDropboxNote;


#pragma mark - 노트 in Managed Object Context

//스토리보드 방식일 때
//- (void)dropboxNote:(DropboxNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
