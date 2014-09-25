//
//  OpenSourceLicencesViewController.m
//  SwiftNoteiPad
//
//  Created by jun on 2014. 8. 6..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//


#pragma mark - 웹뷰
#define kSTATUS_BAR_kABOUT_WEB_VIEW_BACKGROUND_COLOR         [UIColor colorWithRed:0.318 green:0.761 blue:0.82 alpha:1]
#define kABOUT_WEBVIEW_BACKGROUND_COLOR                      [UIColor colorWithRed:0.91 green:0.925 blue:0.929 alpha:1]
#define kABOUT_BUTTON_BACKGROUND_NORMAL_COLOR                [UIColor colorWithRed:0.133 green:0.102 blue:0.192 alpha:0.500]
#define kABOUT_FLOATING_BUTTON_TINT_COLOR                    [UIColor colorWithWhite:1.000 alpha:1.0]
#define kABOUT_FLOATING_BUTTON_ALPHA_OPAQUE                  1.0
#define kABOUT_FLOATING_BUTTON_ALPHA_TRANSLUCENT             0.9
#define kABOUT_FLOATING_BUTTON_ALPHA_TRANSPARENT             0.0
#define kABOUT_BUTTON_ANIMATION_DURATION                     0.25
#define kABOUT_BUTTON_ANIMATION_DELAY                        0.0
#define kABOUT_BUTTON_ANIMATION_HIDE_HEIGHT                  54.0
#define kABOUT_BUTTON_CORNER_RADIUS                          22.0
#define kABOUT_BUTTON_WIDTH                                  44.0
#define kABOUT_BUTTON_HEIGHT                                 44.0
#define kABOUT_BUTTON_HIDE_ORIGIN_Y                          80.0
#define kABOUT_BUTTON_CGAFFINE_SCALE_VALUE                   1.2
#define kABOUT_BUTTON_FONT_SIZE                              20.0
#define kABOUT_BUTTON_CORNER_RADIUS_V3                       22.0


#import "OpenSourceLicencesViewController.h"
#import "SVWebViewController.h"


@interface OpenSourceLicencesViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) SVWebViewController *svWebViewController;

@end


@implementation OpenSourceLicencesViewController
{
    BOOL _didTapped;
}


#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Open Sources";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self assignWebViewAttribute];
    [self loadLocalFileIntoAWebView];
    [self addTapGestureRecognizer];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self showStatusBar];
    [self showNavigationBar];
}


#pragma mark - 로컬 파일 웹뷰로 가져오기

- (void)loadLocalFileIntoAWebView
{
    NSString *path;
    if (iPad) {
        path = [[NSBundle mainBundle] pathForResource:@"ClarityiPad_OpenSourceLicences_iPad" ofType:@"html" inDirectory:nil];
    } else {
        path = [[NSBundle mainBundle] pathForResource:@"ClarityiPad_OpenSourceLicences" ofType:@"html" inDirectory:nil];
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


#pragma mark 웹 뷰 속성

- (void)assignWebViewAttribute
{
    self.webView.delegate = self;
    _didTapped = NO;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(kWEBVIEW_SCROLLVIEW_CONTENTINSET, 0, 0, 0);
}


#pragma mark - SV 웹 뷰

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ( navigationType == UIWebViewNavigationTypeLinkClicked )
    {
        if ( _didTapped == NO)
        {
            
        }
        else
        {
            _didTapped = NO;
            [self showStatusBar];
            [self showNavigationBar];
        }
        //SV 웹뷰
        self.svWebViewController = [[SVWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@", [request URL]]];
        [self.navigationController pushViewController:self.svWebViewController animated:YES];
        return NO;
    }
    return YES;
}


#pragma mark - 탭 제스처

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [self.webView addGestureRecognizer:tapGesture];
}


- (void)handleTap:(UITapGestureRecognizer *)gesture
{
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;     //Simultaneous Gesture Recognize
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


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
