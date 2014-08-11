//
//  MainSidePanelViewController.m
//  SwiftNote
//
//  Created by jun on 6/5/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//  delete unused source path

#import "MainSidePanelViewController.h"

@interface MainSidePanelViewController ()

@end


@implementation MainSidePanelViewController


#pragma mark -
#pragma mark awakeFromNib

- (void)awakeFromNib
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"LeftViewNavigationController"]];
    [self chooseWhichViewLocatedInCenterView];  //어떤 뷰가 초기 뷰인지 확인
//    [self setRecognizesPanGesture:NO];
    
    self.navigationController.navigationBar.translucent = NO;
}


#pragma mark 유저 디폴트 > savedView 확인

- (void)chooseWhichViewLocatedInCenterView
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    BOOL isDropboxView = [[NSUserDefaults standardUserDefaults] boolForKey:kCURRENT_VIEW_IS_DROPBOX];
    BOOL isLocalView = [[NSUserDefaults standardUserDefaults] boolForKey:kCURRENT_VIEW_IS_LOCAL];
     
    if (isLocalView == YES && isDropboxView == NO) {
        [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"LocalNoteListViewNavigationController"]];
    }
    else if (isLocalView == NO && isDropboxView == YES)
    {
        [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxNoteListViewNavigationController"]];
    }
    else if (isLocalView == NO && isDropboxView == NO)
    {
        [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxNoteListViewNavigationController"]];
    }
    else if (isLocalView == YES && isDropboxView == YES)
    {
        [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxNoteListViewNavigationController"]];
    }
    else
    {
       [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxNoteListViewNavigationController"]];
    }
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
