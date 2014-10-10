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
#import "LocalNote.h"
#import "UIImage+MakeThumbnail.h"
#import "TOWebViewController.h"
#import "UIImage+ChangeColor.h"
#import "FCFileManager.h"
#import <MessageUI/MessageUI.h>
#import "DoActionSheet.h"
#import "JGActionSheet.h"


@interface MarkdownWebViewController () <UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, JGActionSheetDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) TOWebViewController *toWebViewController;
@property (nonatomic, weak) IBOutlet UIWebView *markdownWebView;
@property (nonatomic, strong) NSString *markdownString;
@property (nonatomic, strong) NSMutableString *htmlString;
@property (nonatomic, strong) UIButton *buttonForFullscreen;

@end


@implementation MarkdownWebViewController
{
    BOOL _didHideNavigationBar;
    
    JGActionSheet *_currentAnchoredActionSheet;
    UIView *_anchorView;
    BOOL _anchorLeft;
}

#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    [super viewDidLoad];
    _didHideNavigationBar = NO;
    [self addTapGestureRecognizer];
    [self addButtonForFullscreen];
    [self addBarButtonItems];
}


- (void)viewWillAppear:(BOOL)animated
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    [super viewWillAppear:animated];
    self.title = @"Preview";
    [self assignAttributeToMarkdownWebView];
    [self makeMarkdownString];
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
    self.markdownWebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark - UIWebView Delegate (마크다운 웹 뷰 Finish Load)

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    aWebView = self.markdownWebView;
    aWebView.scrollView.maximumZoomScale = 20;
    aWebView.scrollView.minimumZoomScale = 1;
}


#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    self.markdownWebView.scrollView.maximumZoomScale = 20;
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
    self.markdownString = [self makeContentString];
    [self.htmlString appendString:[MMMarkdown HTMLStringWithMarkdown:self.markdownString error:&error]];
    [self.markdownWebView loadHTMLString:self.htmlString baseURL:nil];
}


- (NSString *)cssUTF8String
{
    NSError *error = nil;
    NSString *filePath;
    if (iPad) {
        filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown_iPad_ForWebView" ofType:@"css"];
    } else {
        filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown_iPhone_ForWebView" ofType:@"css"];
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


- (NSString *)makeContentString
{
    NSError *error = nil;
    
    NSString *titleString;
    if ([self.currentNote.noteTitle length] == 0 && [self.currentLocalNote.noteTitle length] == 0) {
        titleString = @"# No Title";
    }
    else if ([self.currentNote.noteTitle length] > 0 && [self.currentLocalNote.noteTitle length] == 0) {
        titleString = self.currentNote.noteTitle;
    }
    else if ([self.currentLocalNote.noteTitle length] > 0 && [self.currentNote.noteTitle length] == 0) {
        titleString = self.currentLocalNote.noteTitle;
    }
    
    NSString *bodyString;
    if ([self.currentNote.noteBody length] == 0 && [self.currentLocalNote.noteBody length] == 0) {
        bodyString = @"*No Contents*";
    }
    else if ([self.currentNote.noteBody length] > 0 && [self.currentLocalNote.noteBody length] == 0) {
        bodyString = self.currentNote.noteBody;
    }
    else if ([self.currentLocalNote.noteBody length] > 0 && [self.currentNote.noteBody length] == 0) {
        bodyString = self.currentLocalNote.noteBody;
    }
    
    NSString *hash = @"# ";
    NSString *newline = @"\n\n";
    NSString *concatenateString;

    concatenateString = [NSString stringWithFormat:@"%@%@%@%@", hash, titleString, newline, bodyString];
    
    if (error != nil) {
        NSLog(@"Error: %@", error.localizedDescription);
       return nil;
    }
    
    return concatenateString;
}


#pragma mark - 웹 뷰

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        if (self.navigationController.navigationBarHidden == YES) {
            _didHideNavigationBar = !_didHideNavigationBar;
            [self showStatusBar];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
        NSURL *url = nil;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [request URL]]];
        self.toWebViewController = [[TOWebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:self.toWebViewController animated:YES];
        return NO;
    }
    return YES;
}


#pragma mark Action Sheet 액션
#pragma mark HTML Attachment Document 생성

- (void)createHTMLAttachmentDocumentWithTitle:(NSString *)title
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    [self createHTMLAttachmentString];
    
    NSString *fileNameWithExtension = [NSString stringWithFormat:@"%@.html", title];
    NSString *tempPath = [FCFileManager pathForTemporaryDirectoryWithPath:fileNameWithExtension];
    
    BOOL fileExists = [FCFileManager existsItemAtPath:tempPath];
    if (fileExists) {
        [FCFileManager removeItemAtPath:tempPath];
    }
    
    [FCFileManager createFileAtPath:tempPath withContent:self.htmlString];
    NSData *htmlFileData = [NSData dataWithContentsOfFile:tempPath];
    
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    
    if ([self.currentNote.noteTitle length] > 0 && [self.currentLocalNote.noteTitle length] == 0) {
        [mailViewController setSubject:self.currentNote.noteTitle];
    }
    else if ([self.currentLocalNote.noteTitle length] > 0 && [self.currentNote.noteTitle length] == 0) {
        [mailViewController setSubject:self.currentLocalNote.noteTitle];
    }
    
    [mailViewController setMessageBody:@"" isHTML:YES];
    NSString *mimeType = @"text/html";
    [mailViewController addAttachmentData:htmlFileData mimeType:mimeType fileName:fileNameWithExtension];
    
    [self setupMailComposeViewModalTransitionStyle:mailViewController];
    mailViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    [self presentViewController:mailViewController animated:YES completion:^ {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}


#pragma mark make HTML Attachment 스트링

- (void)createHTMLAttachmentString
{
    NSError *error;
    self.htmlString = [[NSMutableString alloc] init];
    [self.htmlString appendString:[NSString stringWithFormat:@"<!DOCTYPE html>"
                                   "<html>"
                                   "<head>"
                                   "  <meta charset='UTF-8'/>"
                                   "  <style>%@</style>"
                                   "</head>", [self cssUTF8StringForiPhoneAttachment]]];
    self.markdownString = [self makeContentString];
    [self.htmlString appendString:[MMMarkdown HTMLStringWithMarkdown:self.markdownString error:&error]];
}


#pragma mark make cssUTF8String for HTML Attachment

- (NSString *)cssUTF8StringForiPhoneAttachment
{
    NSError *error = nil;
    NSString *filePath;
    if (iPad) {
        filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown_iPad_ForWebView" ofType:@"css"];
    } else {
        filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown_iPad_ForWebView" ofType:@"css"];
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


#pragma mark 이메일 공유 (Mail ComposeView Modal Transition Style)

- (void)setupMailComposeViewModalTransitionStyle:(MFMailComposeViewController *)mailViewController
{
    if (iPad) {
        mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    } else {
        mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    }
}


#pragma mark 델리게이트 메소드 (MFMailComposeViewControllerDelegate)

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
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
    if ( _didHideNavigationBar == NO)
    {
        _didHideNavigationBar = !_didHideNavigationBar;
        [self hideStatusBar];
        [self hideNavigationBar];
        [self showButtonForFullscreenWithAnimation];
    }
    else
    {
        _didHideNavigationBar = !_didHideNavigationBar;
        [self showStatusBar];
        [self showNavigationBar];
        [self hideButtonForFullscreenWithAnimation];
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


#pragma mark - 바 버튼

- (void)addBarButtonItems
{
    UIColor *tmpColor = [UIColor clearColor];
    UIColor *buttonHighlightedColor = [UIColor orangeColor];
    CGRect buttonFrame = CGRectMake(0 ,0, 40, 40);
    
    
    NSString *ss = @"upload";
    UIImage *share = [UIImage imageNameForChangingColor:ss color:kWHITE_COLOR];
    UIImage *shareH = [UIImage imageNameForChangingColor:ss color:buttonHighlightedColor];
    UIButton *buttonShare = [UIButton buttonWithType:UIButtonTypeCustom];
    if (iPad) {
        [buttonShare addTarget:self action:@selector(displayJGActionSheet:withEvent:)forControlEvents:UIControlEventTouchUpInside];
    } else {
        [buttonShare addTarget:self action:@selector(displayDoActionSheet:)forControlEvents:UIControlEventTouchUpInside];
    }
    [buttonShare setImage:share forState:UIControlStateNormal];
    [buttonShare setImage:shareH forState:UIControlStateSelected];
    [buttonShare setImage:shareH forState:UIControlStateHighlighted];
    buttonShare.frame = buttonFrame;
    float sImageInset = 10.0;
    [buttonShare setImageEdgeInsets:UIEdgeInsetsMake(9.0, sImageInset, 7.0, sImageInset)];
    UIBarButtonItem *barButtonItemShare = [[UIBarButtonItem alloc] initWithCustomView:buttonShare];
    buttonShare.backgroundColor = tmpColor;
    
    
    NSString *fs = @"expand-256";
    UIImage *fullScreen = [UIImage imageNamed:fs];
    UIImage *fullScreenH = [UIImage imageNameForChangingColor:fs color:buttonHighlightedColor];
    UIButton *buttonFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonFullScreen addTarget:self action:@selector(barButtonItemFullScreenPressed:)forControlEvents:UIControlEventTouchUpInside];
    [buttonFullScreen setImage:fullScreen forState:UIControlStateNormal];
    [buttonFullScreen setImage:fullScreenH forState:UIControlStateSelected];
    [buttonFullScreen setImage:fullScreenH forState:UIControlStateHighlighted];
    buttonFullScreen.frame = buttonFrame;
    float fImageInset = 10.0;
    [buttonFullScreen setImageEdgeInsets:UIEdgeInsetsMake(12.0, fImageInset, 8.0, fImageInset)];
    UIBarButtonItem *barButtonItemFullScreen = [[UIBarButtonItem alloc] initWithCustomView:buttonFullScreen];
    buttonFullScreen.backgroundColor = tmpColor;
    
    
    if (iPad) {
        UIBarButtonItem *barButtonItemFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        barButtonItemFixed.width = 40.0f;
        
        NSArray *navigationBarItems = @[barButtonItemFixed, barButtonItemFullScreen, barButtonItemFixed, barButtonItemShare];
        self.navigationItem.rightBarButtonItems = navigationBarItems;
    } else {
        UIBarButtonItem *barButtonItemFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        barButtonItemFixed.width = 4.0f;
        
        NSArray *navigationBarItems = @[barButtonItemFullScreen, barButtonItemFixed, barButtonItemShare];
        self.navigationItem.rightBarButtonItems = navigationBarItems;
    }
}


#pragma mark - Do 액션 sheet (HTML 내보내기, 메일, 기타 공유 등)

#pragma mark Do Action sheet

- (void)displayDoActionSheet:(id)sender
{
    DoActionSheet *vActionSheet = [[DoActionSheet alloc] init];
    [vActionSheet setStyle];
    vActionSheet.dRound = 7;
    vActionSheet.dButtonRound = 3;
    vActionSheet.nAnimationType = 2; //2 > POP
    vActionSheet.doDimmedColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    vActionSheet.nDestructiveIndex = 1;
    
    [vActionSheet showC:@""
                 cancel:@"Cancel"
                buttons:@[@"Email as Attachment"]
                 result:^(int nResult)
     {
         switch (nResult)
         {
             case 0:
             {
                 self.htmlString = nil;
                 if ([self.currentNote.noteTitle length] > 0 && [self.currentLocalNote.noteTitle length] == 0) {
                     [self createHTMLAttachmentDocumentWithTitle:self.currentNote.noteTitle];
                 }
                 else if ([self.currentLocalNote.noteTitle length] > 0 && [self.currentNote.noteTitle length] == 0) {
                     [self createHTMLAttachmentDocumentWithTitle:self.currentLocalNote.noteTitle];
                 }
             }
                 break;
         }
     }];
}


#pragma mark - JG 액션 시트

- (void)displayJGActionSheet:(UIBarButtonItem *)barButtonItem withEvent:(UIEvent *)event
{
    UIView *view = [event.allTouches.anyObject view];
    
    JGActionSheetSection *section = [JGActionSheetSection sectionWithTitle:@"" message:@"" buttonTitles:@[@"Email as Attachment", @"Cancel"] buttonStyle:JGActionSheetButtonStyleBlue];
    
    [section setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:0];
    [section setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:1];
    
    NSArray *sections = (iPad ? @[section] : @[section, [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel]]);
    
    JGActionSheet *sheet = [[JGActionSheet alloc] initWithSections:sections];
    sheet.delegate = self;
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath)
     {
         if (indexPath.section == 0) {
             switch (indexPath.row) {
                 case 0:
                 {
                     self.htmlString = nil;
                     if ([self.currentNote.noteTitle length] > 0 && [self.currentLocalNote.noteTitle length] == 0) {
                         [self createHTMLAttachmentDocumentWithTitle:self.currentNote.noteTitle];
                     }
                     else if ([self.currentLocalNote.noteTitle length] > 0 && [self.currentNote.noteTitle length] == 0) {
                         [self createHTMLAttachmentDocumentWithTitle:self.currentLocalNote.noteTitle];
                     }
                 }
                     break;
                 case 1:
                     break;
                 default:
                     break;
             }
         }
         [sheet dismissAnimated:YES];
     }];
    
    if (iPad) {
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet) {
            [sheet dismissAnimated:YES];
        }];
        
        CGPoint point = (CGPoint){CGRectGetMidX(view.bounds), CGRectGetMaxY(view.bounds)};
        
        point = [self.navigationController.view convertPoint:point fromView:view];
        
        _currentAnchoredActionSheet = sheet;
        _anchorView = view;
        _anchorLeft = NO;
        
        [sheet showFromPoint:point inView:self.navigationController.view arrowDirection:JGActionSheetArrowDirectionTop animated:YES];
    }
    else {
        [sheet showInView:self.navigationController.view animated:YES];
    }
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!iOS7) {
        [self.navigationController.view.superview bringSubviewToFront:self.navigationController.view]; //Use this on iOS < 7 to prevent the UINavigationBar from overlapping your action sheet!
    }
    
    if (_currentAnchoredActionSheet) {
        UIView *view = _anchorView;
        
        CGPoint point = (_anchorLeft ? (CGPoint){-5.0f, CGRectGetMidY(view.bounds)} : (CGPoint){CGRectGetMidX(view.bounds), CGRectGetMaxY(view.bounds)});
        
        point = [self.navigationController.view convertPoint:point fromView:view];
        
        [_currentAnchoredActionSheet moveToPoint:point arrowDirection:(_anchorLeft ? JGActionSheetArrowDirectionRight : JGActionSheetArrowDirectionTop) animated:NO];
    }
}


#pragma mark JGActionSheet Delegate

- (void)actionSheetWillPresent:(JGActionSheet *)actionSheet {
    
}

- (void)actionSheetDidPresent:(JGActionSheet *)actionSheet {
    
}

- (void)actionSheetWillDismiss:(JGActionSheet *)actionSheet {
    
    _currentAnchoredActionSheet = nil;
}

- (void)actionSheetDidDismiss:(JGActionSheet *)actionSheet {
    
}


#pragma mark FullScreen 버튼

- (void)barButtonItemFullScreenPressed:(id)sender
{
    if (_didHideNavigationBar == NO) {
        [self hideStatusBar];
        [self hideNavigationBar];
        [self showButtonForFullscreenWithAnimation];
        _didHideNavigationBar = !_didHideNavigationBar;
    }
}


- (void)addButtonForFullscreen
{
#define kFullScreenButton_OriginX   CGRectGetWidth(self.view.bounds) - 44
    
    UIImage *image = [UIImage imageNamed:@"collapse-black-256"];
    UIImage *imageThumb = [image makeThumbnailOfSize:CGSizeMake(24, 24)];
    self.buttonForFullscreen = [UIButton buttonWithType:UIButtonTypeSystem];
    self.buttonForFullscreen.frame = CGRectMake(kFullScreenButton_OriginX, -44, 44, 44);
    [self.buttonForFullscreen setImage:imageThumb forState:UIControlStateNormal];
    self.buttonForFullscreen.tintColor = [UIColor colorWithRed:0.094 green:0.071 blue:0.188 alpha:1];
    [self.view addSubview:self.buttonForFullscreen];
    
    [self.buttonForFullscreen addTarget:self action:@selector(showStatbarNavbarAndHideFullScreenButton) forControlEvents:UIControlEventTouchUpInside];
}


- (void)showButtonForFullscreenWithAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.buttonForFullscreen.frame = CGRectMake(kFullScreenButton_OriginX, 0, 44, 44);
                         self.buttonForFullscreen.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         self.buttonForFullscreen.alpha = 0.5;}
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.buttonForFullscreen.transform = CGAffineTransformMakeScale(1.0, 1.0);}
                                          completion:^(BOOL finished) { }];
                     }];
}


- (void)hideButtonForFullscreenWithAnimation
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.buttonForFullscreen.frame = CGRectMake(kFullScreenButton_OriginX, -44, 44, 44);
                         self.buttonForFullscreen.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         self.buttonForFullscreen.alpha = 0.6;}
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.buttonForFullscreen.transform = CGAffineTransformMakeScale(1.0, 1.0);}
                                          completion:^(BOOL finished) { }];
                     }];
}


- (void)showStatbarNavbarAndHideFullScreenButton
{
    if (_didHideNavigationBar == YES) {
        [self showStatusBar];
        [self showNavigationBar];
        [self hideButtonForFullscreenWithAnimation];
        _didHideNavigationBar = !_didHideNavigationBar;
    }
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
