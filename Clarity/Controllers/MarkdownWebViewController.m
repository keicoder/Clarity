//
//  MarkdownWebViewController.m
//  Clarity
//
//  Created by jun on 6/8/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//


#pragma mark - 마크다운 웹뷰

#define kMARKDOWN_WEBVIEW_BACKGROUND_COLOR                      [UIColor whiteColor]
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
#import "Note.h"
#import "UIImage+MakeThumbnail.h"
#import "TOWebViewController.h"


@interface MarkdownWebViewController () <UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) TOWebViewController *toWebViewController;
@property (weak, nonatomic) IBOutlet UIWebView *markdownWebView;
@property (strong, nonatomic) NSMutableString *htmlString;
@property (assign) CGPoint tapPoint;

@end


@implementation MarkdownWebViewController
{
    BOOL _didTapped;
}

#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    [super viewDidLoad];
    _didTapped = NO;
    [self addTapGestureRecognizer];
}


- (void)viewWillAppear:(BOOL)animated
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    [super viewWillAppear:animated];
    self.title = @"Preview";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self assignAttributeToMarkdownWebView];
    [self makeMarkdownString];
    [self addNavigationBarButtonItems];
}


- (void)viewWillDisappear:(BOOL)animated
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    [super viewWillDisappear:animated];
    self.title = @"";
    self.htmlString = nil;
    self.toWebViewController = nil;
    self.markdownWebView = nil;
}


#pragma mark - 마크다운 웹 뷰 속성

- (void)assignAttributeToMarkdownWebView
{
    self.markdownWebView.delegate = self;
    self.markdownWebView.scrollView.delegate = self;
    self.markdownWebView.scrollView.scrollEnabled = YES;
    self.markdownWebView.scrollView.contentInset = UIEdgeInsetsMake(60.0, 0, 0, 0);
}


#pragma mark - UIWebView Delegate (마크다운 웹 뷰 Finish Load)

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    aWebView = self.markdownWebView;
    aWebView.scrollView.maximumZoomScale = 20;
    aWebView.scrollView.minimumZoomScale = 1;
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
    else if ([self.currentNote.noteBody length] > 0) {
        markdownString = self.currentNote.noteBody;
    }
    if (error != nil)
    {
        NSLog(@"Error: %@", error);
        return nil;
    }
    return markdownString;
}


#pragma mark - 웹 뷰

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        if (self.navigationController.navigationBarHidden == YES) {
            [self showStatusBar];
            [self showNavigationBar];
        }
        NSURL *url = nil;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [request URL]]];
        self.toWebViewController = [[TOWebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:self.toWebViewController animated:YES];
        return NO;
    }
    return YES;
}


#pragma mark - 탭 제스처

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 2;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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


#pragma mark - 내비게이션 바 버튼

- (void)addNavigationBarButtonItems
{
    if (iPad) {
        
    } else {
        UIBarButtonItem *barButtonItemShare = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemSharePressed:)];
        
        self.navigationItem.rightBarButtonItem = barButtonItemShare;
    }
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


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
