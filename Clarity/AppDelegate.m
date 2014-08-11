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


@interface AppDelegate ()

@property (nonatomic, strong) UIStoryboard *storyboard;

@end


@implementation AppDelegate


#pragma mark - didFinishLaunchingWithOptions

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self applicationDocumentsDirectory];
//    [NSManagedObjectModel mergedModelFromBundles:nil];
    
    //드랍박스 어카운트
    //Dropbox App Folder : 'ClarityApp'
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"mew6arv9f06qgva" secret:@"umw2fac5kt92i3z"];
    [DBAccountManager setSharedManager:accountManager];
    if ([accountManager linkedAccount])
    {
        [[NoteDataManager sharedNoteDataManager] setSyncEnabled:YES];
    }
    
    [self styleUI];                                 //유저 인터페이스
    
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


#pragma mark - 유저 인터페이스

- (void)styleUI
{
//    #define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
//    {
//        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.window.bounds), 20)];
//        view.backgroundColor=kTOOLBAR_DROPBOX_LIST_VIEW_BACKGROUND_COLOR;
//        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [self.window.rootViewController.view addSubview:view];
//    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent]; //상태 바 속성
    self.window.backgroundColor = kWINDOW_BACKGROUND_COLOR;                             //윈도 배경 색상
    self.window.tintColor = [UIColor whiteColor];                                       //윈도 틴트 색상
    [[UINavigationBar appearance] setBarTintColor:kWINDOW_BACKGROUND_COLOR];            //냅바 색상
    [[UINavigationBar appearance] setTintColor:kWHITE_COLOR];                           //냅바 버튼 색상
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:kWHITE_COLOR, NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Medium" size:18.0]};
}


#pragma mark - 기기 방향 지원

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window  // iOS 6 autorotation fix
{
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    NSLog(@"applicationDocumentsDirectory: %@\n", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Application's State

- (void)applicationWillResignActive:(UIApplication *)application
{
    
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}


#pragma mark 로고 뷰 (사용 안 함)

- (void)addLogoImageView
{
    //100 by 100
    UIImage *logo = [UIImage imageNamed:@"penColor64"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logo];
    CGFloat windowWidth = CGRectGetWidth(self.window.bounds);
    CGFloat windowHeight = CGRectGetHeight(self.window.bounds);
    CGFloat imageViewWidth = CGRectGetWidth(logoImageView.bounds);
    CGFloat imageViewHeight = CGRectGetHeight(logoImageView.bounds);
    logoImageView.frame = CGRectMake((windowWidth - imageViewWidth) / 2, (windowHeight - imageViewHeight) / 2, imageViewWidth, imageViewHeight);
    
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windowWidth, windowHeight)];
    [aView addSubview:logoImageView];
    
    [self.window addSubview:aView];
    [self.window setAutoresizesSubviews:YES];
    [aView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
}

@end
