//
//  WelcomeViewController.m
//  SwiftNote
//
//  Created by jun on 2014. 6. 26..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import "WelcomeViewController.h"
#import "WelcomePage.h"
#import "BackgroundLayer.h"                                     //그라디언트 효과
#import "FRLayeredNavigationController/FRLayeredNavigation.h"


@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *welcomeImageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonDismiss;

@end


@implementation WelcomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kBLACK_COLOR;
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.buttonDismiss.alpha = 0.0;
    
    if (self.welcomePage == nil)
    {
        self.welcomePage = [WelcomePage allPages][0];
    }
    
//    CAGradientLayer *bgLayer = [BackgroundLayer menuGradient];
//    bgLayer.frame = self.view.bounds;
//    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    self.welcomeImageView.image = self.welcomePage.welcomeImage;
    self.textLabel.text = [[NSString alloc] initWithString:self.welcomePage.text];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.buttonDismiss.alpha = 0.0;
}


- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.buttonDismiss.alpha = 1.0;
                     }
                     completion:^(BOOL finished) { }];
}


#pragma mark  버튼 액션

- (IBAction)buttonDismissPressed:(id)sender
{
//    [self showStatusBar];
//    [self showNavigationBar];
    [self.layeredNavigationController popViewControllerAnimated:YES];
}


#pragma mark - 모달 뷰인지 확인

- (BOOL)isModal
{
    return self.presentingViewController.presentedViewController == self || self.navigationController.presentingViewController.presentedViewController == self.navigationController || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
