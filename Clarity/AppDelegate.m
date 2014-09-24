//
//  AppDelegate.m
//  Clarity
//
//  Created by jun on 8/10/14.
//  Copyright (c) 2014 lovejunsoft. All rights reserved.
//

#import "AppDelegate.h"
#import "NoteDataManager.h"
#import "LeftViewController.h"
#import "FRLayeredNavigationController/FRLayeredNavigation.h"

@interface AppDelegate () <FRLayeredNavigationControllerDelegate>

@property (nonatomic, strong) UIStoryboard *storyboard;
@property (nonatomic, strong) FRLayeredNavigationController *layeredNavigationController;

@end


@implementation AppDelegate

#pragma mark - didFinishLaunchingWithOptions

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self applicationDocumentsDirectory];
    
    if (iPad) {
        self.storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle: nil];
        LeftViewController *controller = (LeftViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        self.layeredNavigationController = [(FRLayeredNavigationController *)[FRLayeredNavigationController alloc] initWithRootViewController:navigationController configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
            layeredNavigationItem.width = kFRLAYERED_NAVIGATION_ITEM_WIDTH_LEFT;
            layeredNavigationItem.nextItemDistance = 0;
            layeredNavigationItem.hasChrome = NO;
            layeredNavigationItem.hasBorder = NO;
            layeredNavigationItem.displayShadow = YES;
        }];
        self.layeredNavigationController.delegate = self;
        self.window.rootViewController = self.layeredNavigationController;
    }
    
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"mew6arv9f06qgva" secret:@"umw2fac5kt92i3z"];
    [DBAccountManager setSharedManager:accountManager];
    if ([accountManager linkedAccount]) {
        [[NoteDataManager sharedNoteDataManager] setSyncEnabled:YES];
    }
    
    [self styleUI];
    return YES;
}


#pragma mark 드랍박스 연결

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        return YES;
    }
    return NO;
}


#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
//    NSLog(@"applicationDocumentsDirectory: %@\n", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - 유저 인터페이스

- (void)styleUI
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window.backgroundColor = kWINDOW_BACKGROUND_COLOR;
    self.window.tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setBarTintColor:kWINDOW_BACKGROUND_COLOR];
    [[UINavigationBar appearance] setTintColor:kWHITE_COLOR];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:kWHITE_COLOR, NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Medium" size:18.0]};
}


#pragma mark - Application's State

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationWillResignActiveNotification" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}


@end
