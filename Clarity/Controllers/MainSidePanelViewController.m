//
//  MainSidePanelViewController.m
//  SwiftNote
//
//  Created by jun on 6/5/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//  delete unused source path

#import "MainSidePanelViewController.h"
#import "LocalNoteListViewController.h"
#import "DropboxNoteListViewController.h"


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

- (UINavigationController *)defaultNavigationController
{
    DropboxNoteListViewController *controller = (DropboxNoteListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxNoteListViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    return navigationController;
}


- (void)chooseWhichViewLocatedInCenterView
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    
    BOOL isDropboxView = [[NSUserDefaults standardUserDefaults] boolForKey:kCURRENT_VIEW_IS_DROPBOX];
    BOOL isLocalView = [[NSUserDefaults standardUserDefaults] boolForKey:kCURRENT_VIEW_IS_LOCAL];
     
    if (isLocalView == YES && isDropboxView == NO) {
        LocalNoteListViewController *controller = (LocalNoteListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LocalNoteListViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        self.centerPanel = navigationController;
    }
    else if (isLocalView == NO && isDropboxView == YES)
    {
        UINavigationController *navigationController = [self defaultNavigationController];
        self.centerPanel = navigationController;
    }
    else if (isLocalView == NO && isDropboxView == NO)
    {
        UINavigationController *navigationController = [self defaultNavigationController];
        self.centerPanel = navigationController;
    }
    else if (isLocalView == YES && isDropboxView == YES)
    {
        UINavigationController *navigationController = [self defaultNavigationController];
        self.centerPanel = navigationController;
    }
    else
    {
        UINavigationController *navigationController = [self defaultNavigationController];
        self.centerPanel = navigationController;
    }
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
