//
//  MarkdownWebViewController.m
//  SwiftNote
//
//  Created by jun on 6/8/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//


#pragma mark - 마크다운 웹뷰

#define kMARKDOWN_WEBVIEW_BACKGROUND_COLOR                      [UIColor whiteColor] //[UIColor colorWithRed:0.91 green:0.925 blue:0.929 alpha:1] //[UIColor whiteColor]
#define kMARKDOWN_FLOATING_BUTTON_TINT_COLOR                    [UIColor whiteColor]
#define kMARKDOWN_FLOATING_BUTTON_ALPHA_OPAQUE                  1.0
#define kMARKDOWN_FLOATING_BUTTON_ALPHA_TRANSLUCENT             0.33
#define kMARKDOWN_FLOATING_BUTTON_ALPHA_TRANSPARENT             0.0
#define kMARKDOWN_BUTTON_ANIMATION_DURATION                     0.25
#define kMARKDOWN_BUTTON_ANIMATION_DELAY                        0.0
#define kMARKDOWN_BUTTON_ANIMATION_HIDE_HEIGHT                  54.0
#define kMARKDOWN_BUTTON_CORNER_RADIUS                          22.0
#define kMARKDOWN_BUTTON_WIDTH                                  44.0
#define kMARKDOWN_BUTTON_HEIGHT                                 44.0
#define kMARKDOWN_BUTTON_HIDE_ORIGIN_Y                          80.0
#define kMARKDOWN_BUTTON_CGAFFINE_SCALE_VALUE                   1.2
#define kMARKDOWN_BUTTON_FONT_SIZE                              20.0
#define kMARKDOWN_BUTTON_CORNER_RADIUS_V3                       22.0
#define kMARKDOWN_BUTTON_BACKGROUND_NORMAL_COLOR                [UIColor colorWithRed:0.196 green:0.239 blue:0.267 alpha:1]
#define kMARKDOWN_BUTTON_BACKGROUND_PRESSED_COLOR               [UIColor colorWithRed:0.396 green:0.484 blue:0.545 alpha:1.000]


#import "MarkdownWebViewController.h"
#import "MMMarkdown.h"
#import "SVModalWebViewController.h"
#import "SVWebViewController.h"
#import "Note.h"
#import "UIImage+MakeThumbnail.h"


@interface MarkdownWebViewController () <UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;         //컨텍스트
@property (strong, nonatomic) SVModalWebViewController *svModalWebViewController;   //sv 모달 웹뷰 컨트롤러
@property (strong, nonatomic) SVWebViewController *svWebViewController;             //sv 웹뷰 컨트롤러
@property (weak, nonatomic) IBOutlet UIWebView *markdownWebView;                    //마크다운 웹뷰
@property (strong, nonatomic) NSMutableString *htmlString;                          //마크다운 스트링
@property (strong, nonatomic) UIView *statusView;                                   //상태바 아래 플로팅 뷰
@property (assign) CGPoint tapPoint;                                                //탭 제스처

@end


@implementation MarkdownWebViewController
{
    BOOL _didTapped;                                                                //탭 제스처 상태 확인
}


#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = kAUTOMATICALLY_ADJUSTS_SCROLLVIEW_INSETS;
    [self assignAttributeToMarkdownWebView];                    //마크다운 웹뷰 속성
    [self makeMarkdownString];                                  //마크다운 스트링
    [self addTapGestureRecognizer];                             //탭 제스처
    [self addNavigationBarButtonItems];                         //내비게이션 바 버튼
    self.title = @"Preview";
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"HelpMessageMarkdownWebViewPopped" object:nil userInfo:nil];
}


#pragma mark - UIWebView Delegate (마크다운 웹 뷰 Finish Load)

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    aWebView = self.markdownWebView;
    aWebView.scrollView.maximumZoomScale = 20; // set as you want.
    aWebView.scrollView.minimumZoomScale = 1; // set as you want.
}


#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    self.markdownWebView.scrollView.maximumZoomScale = 20; // set similar to previous.
}


#pragma mark - 마크다운 웹 뷰 속성

- (void)assignAttributeToMarkdownWebView
{
    _didTapped = NO;                                            //탭 제스처 상태 초기화
    
    self.markdownWebView.delegate = self;                       //UIWebView 델리게이트
    self.markdownWebView.scrollView.delegate = self;            //UIScrollVieW 델리게이트
    self.markdownWebView.scrollView.scrollEnabled = YES;
    self.markdownWebView.scrollView.contentInset = UIEdgeInsetsMake(kMARKDOWNWEBVIEW_SCROLLVIEW_CONTENTINSET, 0, 0, 0);  //마크다운 웹뷰 인셋
}

#pragma mark 마크다운 스트링

- (void)makeMarkdownString
{
    NSError *error;
    self.htmlString = [[NSMutableString alloc] init];
    [self.htmlString appendString:[NSString stringWithFormat:@"<!DOCTYPE html>"
                                   "<html>"
                                   "<head>"
                                   "  <meta charset='UTF-8'/>"
                                   "  <style>%@</style>"
                                   "</head>", [self cssUTF8String]]];
    [self.htmlString appendString:[MMMarkdown HTMLStringWithMarkdown:[self markdownString] error:&error]];
    [self.markdownWebView loadHTMLString:self.htmlString baseURL:nil];
}


- (NSString *)cssUTF8String
{
    NSError *error = nil;
    NSString *filePath;
    if (iPad) {
        filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown_iPad" ofType:@"css"];
    } else {
        filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown" ofType:@"css"];
    }
    NSString *cssString = [NSString stringWithContentsOfFile:filePath
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    if (error != nil)
    {
        NSLog(@"Error: %@", error);
        return nil;
    }
    return cssString;
}


- (NSString *)markdownString
{
    NSError *error = nil;
    NSString *markdownString = @"";
    if ([self.currentNote.noteBody length] == 0) {
        markdownString = @"*No content*";
    }
    if ([self.currentNote.noteBody length] > 0) {
        markdownString = self.currentNote.noteBody;
    }
    if (error != nil)
    {
        NSLog(@"Error: %@", error);
        return nil;
    }
    return markdownString;
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
        
        self.svWebViewController = [[SVWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"%@", [request URL]]];      //SV 웹뷰
        [self.navigationController pushViewController:self.svWebViewController animated:YES]; //Push
        
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
    [self.markdownWebView addGestureRecognizer:tapGesture];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    self.tapPoint = [touch locationInView:self.markdownWebView];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;     //Simultaneous Gesture Recognize
}


#pragma mark - 내비게이션 바 버튼

- (void)addNavigationBarButtonItems
{
    UIBarButtonItem *barButtonItemShare = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemSharePressed:)];
    
    self.navigationItem.rightBarButtonItem = barButtonItemShare;
}


- (void)barButtonItemSharePressed:(id)sender
{
    [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{ }
                     completion:^(BOOL finished) {
                         NSString *noteStringForshare = self.htmlString;
                         NSArray *itemsToShare = @[noteStringForshare];
                         UIActivityViewController *activityViewController;
                         activityViewController = [[UIActivityViewController alloc]
                                                   initWithActivityItems:itemsToShare
                                                   applicationActivities:nil];
                         [self presentViewController:activityViewController
                                            animated:YES
                                          completion:nil];
                     }];
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
//    [self statusViewUp];
}


- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [self statusViewDown];
}


#pragma mark - 메모리 경고

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
    self.htmlString = nil;
}


@end
