//
//  DropboxSettingsTableViewController.m
//  Toado
//
//  Created by Jonathan Younger on 7/17/13.
//  Copyright (c) 2013 Overcommitted, LLC. All rights reserved.
//

#import "DropboxSettingsTableViewController.h"
#import "NoteDataManager.h"


@interface DropboxSettingsTableViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *syncSwitch;

@end


@implementation DropboxSettingsTableViewController


#pragma mark -
#pragma mark 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Link";
    [self configureViewAndTableView];
}


#pragma mark - 뷰 life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.syncSwitch.on = [[DBAccountManager sharedManager] linkedAccount] != nil;
    [self saveCurrentView];
}


#pragma mark 뷰 및 테이블 뷰 속성

- (void)configureViewAndTableView
{
    self.tableView.separatorColor = [UIColor colorWithWhite:0.333 alpha:0.300];
}


#pragma mark - 유저 디폴트 > 현재 뷰 저장

- (void)saveCurrentView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:kCURRENT_VIEW_IS_DROPBOX];
    [standardUserDefaults synchronize];
}


#pragma mark - 스위치 액션

- (IBAction)toggleSyncAction:(id)sender
{
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    DBAccount *account = [accountManager linkedAccount];

    if ([sender isOn]) {
        if (!account) {
            [accountManager addObserver:self block:^(DBAccount *account) {
                if ([account isLinked]) {
                    [[NoteDataManager sharedNoteDataManager] setSyncEnabled:YES];
                }
            }];
            
            [[DBAccountManager sharedManager] linkFromController:self];
        }
    } 
    else 
    {
        [[NoteDataManager sharedNoteDataManager] setSyncEnabled:NO];
        [account unlink];
    }
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
