//
//  SVModalWebViewController.m
//
//  Created by Oliver Letterer on 13.08.11.
//  Copyright 2011 Home. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"
#import "SVWebViewController.h"

@interface SVModalWebViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) SVWebViewController *webViewController;
@property (assign) CGPoint tapPoint;                            //탭 제스처

@end


@implementation SVModalWebViewController
{
    BOOL _didTapped;                                            //탭 제스처 상태 확인
}


#pragma mark - Initialization


- (id)initWithAddress:(NSString*)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL *)URL {
    self.webViewController = [[SVWebViewController alloc] initWithURL:URL];
    if (self = [super initWithRootViewController:self.webViewController]) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self.webViewController
                                                                                    action:@selector(doneButtonClicked:)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.webViewController.navigationItem.leftBarButtonItem = doneButton;
        else
            self.webViewController.navigationItem.rightBarButtonItem = doneButton;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _didTapped = NO;                                            //탭 제스처 상태 초기화
//    [self styleUI];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    self.webViewController.title = self.title;
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [[UINavigationBar appearance] setBarTintColor:kNAVIGATIONBAR_DROPBOX_SETTINGS_VIEW_BAR_TINT_COLOR]; //kNAVIGATIONBAR_SVWEB_VIEW_BAR_TINT_COLOR
//    [[UINavigationBar appearance] setTintColor:kWHITE_COLOR];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kDARK_TEXT_COLOR}];
//    self.navigationController.navigationBar.tintColor = kWHITE_COLOR;
}


- (void)viewWillDisappear:(BOOL)animated
{
//    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [[UINavigationBar appearance] setTintColor:kWHITE_COLOR];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kWHITE_COLOR}];
//    self.navigationController.navigationBar.tintColor = kWHITE_COLOR;
}


- (void)doneButtonClicked:(id)sender
{
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    [[UINavigationBar appearance] setTintColor:kWHITE_COLOR];
    //    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kWHITE_COLOR}];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{ }];
}


#pragma mark - 상태바, 내비게이션 바 등 스타일

- (void)styleUI
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];                 //상태 바 속성
    self.navigationController.navigationBar.topItem.title = @"About";                                   //내비게이션 바 타이틀
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.761 green:0.635 blue:0.506 alpha:1];
    [[UINavigationBar appearance] setTintColor:kWHITE_COLOR];
    //[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kWHITE_COLOR}];
}


#pragma mark -
#pragma mark 탭 제스처

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
}


- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    NSLog (@"Tap gesture recognized");
    
    if ( _didTapped == NO)
    {
        _didTapped = YES;
        [self hideStatusBar];
        [self hideNavigationBar];
    }
    else
    {
        _didTapped = NO;
        [self showStatusBar];
        [self showNavigationBar];
    }
}


#pragma mark 제스처 Recognizer 델리게이트

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    self.tapPoint = [touch locationInView:self.view];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;     //Simultaneous Gesture Recognize
}


#pragma mark - 상태바, 내비게이션바 컨트롤

- (void)hideNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)showNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}


- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

@end
