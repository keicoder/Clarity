//
//  WelcomePageViewController.m
//  SwiftNote
//
//  Created by jun on 2014. 6. 26..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import "WelcomePageViewController.h"
#import "WelcomePage.h"
#import "WelcomeViewController.h"
#import "BackgroundLayer.h"                                                         //그라디언트 효과


@interface WelcomePageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) NSArray *welcomePages;
@property (nonatomic, strong) WelcomeViewController *controller;

@end


@implementation WelcomePageViewController


#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    self.view.backgroundColor = kBLACK_COLOR;
    
    self.welcomePages = [WelcomePage allPages];
    self.controller = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    self.controller.welcomePage = self.welcomePages[0];
    
    [self setViewControllers:@[self.controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.dataSource = self;
    self.delegate = self;
    
    self.controller.pageControl.numberOfPages = 5;
    self.controller.pageControl.currentPage = 0;
    self.controller.pageControl.enabled = NO;
    [self.view addSubview:self.controller.pageControl];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];          //상태 바 속성
    [self hideNavigationBar];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];     //상태 바 속성
    [self showNavigationBar];
}


#pragma mark - UIPageViewController DataSource



- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    WelcomeViewController *oldViewController = (WelcomeViewController *)viewController;
    int newIndex = oldViewController.welcomePage.index + 1;
    if (newIndex > self.welcomePages.count - 1) return nil;
    
    WelcomeViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    newViewController.welcomePage = self.welcomePages[newIndex];
    return newViewController;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    WelcomeViewController *oldViewController = (WelcomeViewController *)viewController;
    int newIndex = oldViewController.welcomePage.index - 1;
    if (newIndex < 0) return nil;
    
    WelcomeViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    newViewController.welcomePage = self.welcomePages[newIndex];
    return newViewController;
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    WelcomeViewController *controller = (WelcomeViewController *)pageViewController.viewControllers[0];
    return controller.welcomePage.index;
}


#pragma mark - UIPageViewController Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSInteger index = [self presentationIndexForPageViewController:pageViewController];
    self.controller.pageControl.currentPage = index;
}


- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers NS_AVAILABLE_IOS(6_0)
{
    
}


#pragma mark 내비게이션 및 상태 바 컨트롤

- (void)showNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)hideNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}


- (void)hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}


#pragma mark - 메모리 경고

- (void)didReceiveMemoryWarning
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Warning Invoked");
}


@end
