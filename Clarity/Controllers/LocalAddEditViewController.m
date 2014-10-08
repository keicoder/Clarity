//
//  LocalAddEditViewController.m
//  Clarity
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import "LocalAddEditViewController.h"
#import "FRLayeredNavigationController/FRLayeredNavigation.h"
#import "JTextView.h"
#import "MarkdownWebViewController.h"
#import "NoteDataManager.h"
#import "UIImage+MakeThumbnail.h"
#import "UIImage+ChangeColor.h"
#import "MMMarkdown.h"
#import "YRDropdownView.h"
#import <MessageUI/MessageUI.h>
#import "DoActionSheet.h"
#import "UIViewController+MaryPopin.h"
#import "NoteTitlePopinViewController.h"
#import "UIButtonPressAndHold.h"
#import "NSUserDefaults+Extension.h"
#import "NDHTMLtoPDF.h"
#import "BNHtmlPdfKit.h"
#import "UIImage+ResizeMagick.h"
#import "JGActionSheet.h"
#import "BlankViewController.h"
#import "FCFileManager.h"


#define kHideOrShowStatusAndNavigationBarDelay 0.4


@interface LocalAddEditViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, UIGestureRecognizerDelegate, NDHTMLtoPDFDelegate, BNHtmlPdfKitDelegate, FRLayeredNavigationControllerDelegate, UIPopoverControllerDelegate, JGActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) JTextView *noteTextView;
@property (nonatomic, strong) UILabel *noteTitleLabel;
@property (nonatomic, strong) UIView *noteTitleLabelBackgroundView;
@property (nonatomic, strong) NSMutableString *htmlString;
@property (nonatomic, strong) UIBarButtonItem *barButtonItemStarred;
@property (nonatomic, strong) UIButton *buttonStar;
@property (nonatomic, strong) UIButton *buttonForFullscreen;
@property (nonatomic, strong) UIImage *starImage;
@property (nonatomic, strong) NDHTMLtoPDF *pdfCreator;
@property (nonatomic, strong) UIToolbar *keyboardAccessoryToolBar;

@end


@implementation LocalAddEditViewController
{
    BOOL _didSelectStar;
    BOOL _didHideNavigationBar;
    NSString *_originalNote;
    
    JGActionSheet *_currentAnchoredActionSheet;
    UIView *_anchorView;
    BOOL _anchorLeft;
    
    BNHtmlPdfKit *_htmlPdfKit;
}


#pragma mark - 노트 in Managed Object Context

- (void)note:(LocalNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self.currentNote = note;
    self.managedObjectContext = managedObjectContext;
}


#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iPad) {
        self.layeredNavigationController.delegate = self;
    }
    self.title = @"";
    [self addNoteTextView];
    [self addNoteTitleLabel];
    [self registerKeyboardNotifications];
    [self addBarButtonItems];
    [self assignNoteData];
    [self.noteTextView assignTextViewAttribute];
    [self updateStarImage];
    [self addTapGestureRecognizer];
    [self addObserverForNoteTitleChanged];
    [self addObserverForApplicationWillResignActive];
    [self addButtonForFullscreen];
    [self checkNewNote];
    if (self.keyboardAccessoryToolBar != nil) {
        self.noteTextView.inputAccessoryView = self.keyboardAccessoryToolBar;
    } else {
        [self addKeyboardAccessoryToolBar];
    }
    //[self showNoteDataToLogConsole];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self saveCurrentView];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkToShowHelpMessage];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (iPad) {
        
    } else {
        [self autoSaveAndRegisterStarListViewWillShowNotification];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.keyboardAccessoryToolBar = nil;
    self.starImage = nil;
    self.htmlString = nil;
    self.noteTitleLabel = nil;
    self.noteTitleLabelBackgroundView = nil;
    self.noteTextView = nil;
}


#pragma mark - 노트 텍스트 뷰
#pragma mark 노트 체크 > 키보드 Up

- (void)checkNewNote
{
    if ([self.currentNote.isNewNote boolValue] == YES) {
        [self.noteTextView becomeFirstResponder];
    } else {
        [self setCursorToBeginning:self.noteTextView];
    }
}


#pragma mark 커서 포지션

- (void)setCursorToBeginning:(UITextView *)inView
{
    inView.selectedRange = NSMakeRange(0, 1);
}


#pragma mark - 노트 데이터, 텍스트 뷰, 레이블 타이틀 뷰

#pragma mark 노트 데이터 지정

- (void)assignNoteData
{
    self.noteTitleLabel.text = self.currentNote.noteTitle;
    self.noteTextView.text = self.currentNote.noteBody;
    _didSelectStar = [self.currentNote.hasNoteStar boolValue];
    _didHideNavigationBar = NO;
    _originalNote = self.currentNote.noteAll;
}


#pragma mark 텍스트 뷰 생성

- (void)addNoteTextView
{
    self.noteTextView = [[JTextView alloc] initWithFrame:self.view.frame];
    self.noteTextView.delegate = self;
    [self.view addSubview:self.noteTextView];
}


#pragma mark 타이틀 레이블 생성

- (void)addNoteTitleLabel
{
    CGFloat noteTitleLabelHeight_iPhone = 44.0;
    CGFloat noteTitleLabelHeight_iPad = 50.0;
    int labelPadding_iPhone = 10.0;
    int labelPadding_iPad = 80.0;
    
    if (iPad) {
        self.noteTitleLabelBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -60, CGRectGetWidth(self.view.bounds), noteTitleLabelHeight_iPad)];
        self.noteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding_iPad, 0, CGRectGetWidth(self.view.bounds) - (labelPadding_iPad * 2), CGRectGetHeight(self.noteTitleLabelBackgroundView.bounds))];
    } else {
        self.noteTitleLabelBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -40, CGRectGetWidth(self.view.bounds), noteTitleLabelHeight_iPhone)];
        self.noteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding_iPhone, 0, CGRectGetWidth(self.view.bounds) - (labelPadding_iPhone * 2), CGRectGetHeight(self.noteTitleLabelBackgroundView.bounds))];
    }
    
    self.noteTitleLabelBackgroundView.backgroundColor = kTEXTVIEW_BACKGROUND_COLOR;
    [self.noteTextView addSubview:self.noteTitleLabelBackgroundView];
    [self.noteTitleLabelBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    if (iPad) {
        self.noteTitleLabel.font = kTEXTVIEW_LABEL_FONT_IPAD;
    } else {
        self.noteTitleLabel.font = kTEXTVIEW_LABEL_FONT;
    }
    self.noteTitleLabel.textColor = kTEXTVIEW_LABEL_TEXT_COLOR;
    self.noteTitleLabel.backgroundColor = kTEXTVIEW_BACKGROUND_COLOR;
    self.noteTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.noteTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.noteTitleLabelBackgroundView addSubview:self.noteTitleLabel];
    [self.noteTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}


#pragma mark - Keyboard handle

- (void)registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.noteTextView keyboardWillShow:notification];
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    [self.noteTextView keyboardWillHide:notification];
}


#pragma mark - UITextView delegate method (optional)

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_didHideNavigationBar == NO) {
        if (iPad) {
            [self hideStatusAndNavigationBar];
        } else {
            [self hideStatusAndNavigationBar];
        }
    }
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (_didHideNavigationBar == YES) {
        if (iPad) {
            [self performSelector:@selector(showStatusAndNavigationBar) withObject:nil afterDelay:kHideOrShowStatusAndNavigationBarDelay];
        } else {
            [self performSelector:@selector(showStatusAndNavigationBar) withObject:nil afterDelay:kHideOrShowStatusAndNavigationBarDelay];
        }
    }
    return YES;
}


#pragma mark - 바 버튼

- (void)addBarButtonItems
{
    UIColor *tmpColor = [UIColor clearColor];
    UIColor *buttonHighlightedColor = [UIColor orangeColor];
    CGRect buttonFrame = CGRectMake(0 ,0, 40, 40);
    
    UIBarButtonItem *barButtonItemFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barButtonItemFixed.width = 24.0f;
    
    UIBarButtonItem *barButtonItemFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
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
    
    
    float sImageSize = 32.0;
    UIImage *star = [UIImage imageNameForChangingColor:@"star-256-white" color:kWHITE_COLOR];
    [star resizedImageByHeight:sImageSize];
    self.buttonStar = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonStar addTarget:self action:@selector(barButtonItemStarredPressed:)forControlEvents:UIControlEventTouchUpInside];
    [self.buttonStar setBackgroundImage:star forState:UIControlStateNormal];
    self.buttonStar.frame = CGRectMake(0 ,0, sImageSize, sImageSize);
    [self.buttonStar setContentEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
    self.barButtonItemStarred = [[UIBarButtonItem alloc] initWithCustomView:self.buttonStar];
    self.buttonStar.backgroundColor = tmpColor;
    
    
    NSString *as = @"plus-256";
    UIImage *add = [UIImage imageNamed:as];
    UIImage *addH = [UIImage imageNameForChangingColor:as color:buttonHighlightedColor];
    UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonAdd addTarget:self action:@selector(barButtonItemAddPressed:)forControlEvents:UIControlEventTouchUpInside];
    [buttonAdd setImage:add forState:UIControlStateNormal];
    [buttonAdd setImage:addH forState:UIControlStateSelected];
    [buttonAdd setImage:addH forState:UIControlStateHighlighted];
    buttonAdd.frame = buttonFrame;
    float aImageInset = 2.0;
    [buttonAdd setImageEdgeInsets:UIEdgeInsetsMake(aImageInset, aImageInset, aImageInset, aImageInset)];
    UIBarButtonItem *barButtonItemAdd = [[UIBarButtonItem alloc] initWithCustomView:buttonAdd];
    buttonAdd.backgroundColor = tmpColor;
    
    
    UIButton *buttonMarkdown = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonMarkdown setTitle:@"M" forState:UIControlStateNormal];
    buttonMarkdown.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:28.0];
    [buttonMarkdown setTitleColor:kTOOLBAR_TEXT_COLOR forState:UIControlStateNormal];
    [buttonMarkdown setContentEdgeInsets:UIEdgeInsetsMake(8, 0, 0, 0)];
    buttonMarkdown.frame = buttonFrame;
    [buttonMarkdown addTarget:self action:@selector(barButtonItemMarkdownPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItemMarkdown = [[UIBarButtonItem alloc] initWithCustomView: buttonMarkdown];
    [barButtonItemMarkdown setTitleTextAttributes:@{NSForegroundColorAttributeName:kGOLD_COLOR} forState:UIControlStateNormal];
    buttonMarkdown.backgroundColor = tmpColor;
    
    
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
    
    
    if (iPad) {
        NSArray *navigationBarItems = @[barButtonItemFlexible, barButtonItemFullScreen, barButtonItemFlexible, self.barButtonItemStarred, barButtonItemFlexible, barButtonItemAdd, barButtonItemFlexible, barButtonItemShare, barButtonItemFlexible, barButtonItemMarkdown, barButtonItemFlexible];
        self.navigationItem.rightBarButtonItems = navigationBarItems;
    } else {
        NSArray *navigationBarItems = @[barButtonItemFullScreen, barButtonItemFixed, self.barButtonItemStarred, barButtonItemFixed, barButtonItemShare, barButtonItemFixed, barButtonItemMarkdown];
        self.navigationItem.rightBarButtonItems = navigationBarItems;
    }
}


#pragma mark 버튼 액션 Method: 컨텍스트 저장, 뷰 pop 외

- (void)noAction:(id)sender
{
    
}


#pragma mark 뉴 노트 (노트 추가 Notification 통보)

- (void)barButtonItemAddPressed:(id)sender
{
    [self performSelector:@selector(postAddNewNoteNotification) withObject:self afterDelay:0.0];
}


- (void)postAddNewNoteNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"AddNewNoteNotification" object:nil userInfo:nil];
}


#pragma mark FullScreen 버튼

- (void)barButtonItemFullScreenPressed:(id)sender
{
    if (_didHideNavigationBar == NO) {
        [self hideStatusAndNavigationBarAndShowButton];
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
    
    [self.buttonForFullscreen addTarget:self action:@selector(showStatusAndNavigationBarAndHideButton) forControlEvents:UIControlEventTouchUpInside];
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


#pragma mark 노트 저장

- (void)autoSave
{
    if ([self.currentNote.isNewNote boolValue] == YES) {
        self.currentNote.isNewNote = [NSNumber numberWithBool:NO];
        [self saveMethodInvoked];
    } else {
        NSString *newline = @"\n\n";
        NSString *concatenateString = [NSString stringWithFormat:@"%@%@%@%@%@", self.noteTitleLabel.text, newline, self.noteTextView.text, newline, _didSelectStar ? @"YES" : @"NO"];
        
        if ([_originalNote isEqualToString:concatenateString]) {
            
        } else {
            [self saveMethodInvoked];
        }
    }
}


- (void)saveMethodInvoked
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    NSManagedObjectContext *mainManagedObjectContext = [managedObjectContext parentContext];
    
    [self updateNoteDataWithCurrentState];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setInteger:0 forKey:kSELECTED_LOCAL_NOTE_INDEX];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [standardUserDefaults setIndexPath:indexPath forKey:kSELECTED_LOCAL_NOTE_INDEXPATH];
    [standardUserDefaults synchronize];
    
    [managedObjectContext performBlock:^{
         NSError *error = nil;
         if ([managedObjectContext save:&error]) {
             //[mainManagedObjectContext save:&error];
         } else {
             NSLog(@"Error saving context: %@", error);
         }
     }];
    //[self showNoteDataToLogConsole];
}


#pragma mark 업데이트 노트 데이터

- (void)updateNoteDataWithCurrentState
{
    NSDate *now = [NSDate date];
    if (self.currentNote.date == nil) {
        self.currentNote.date = now;
    }
    if (self.currentNote.noteCreatedDate == nil) {
        self.currentNote.noteCreatedDate = now;
    }
    self.currentNote.noteModifiedDate = now;
    
    self.currentNote.hasNoteStar = [NSNumber numberWithBool:_didSelectStar];
    
    NSString *newline = @"\n\n";
    NSString *concatenateString = [NSString stringWithFormat:@"%@%@%@%@%@", self.noteTitleLabel.text, newline, self.noteTextView.text, newline, _didSelectStar ? @"YES" : @"NO"];
    self.currentNote.noteAll = concatenateString;
    self.currentNote.noteTitle = self.noteTitleLabel.text;
    self.currentNote.noteBody = self.noteTextView.text;
    
    [self.currentNote updateTableCellDateValue]; //sectionName, dateString, dayString, monthString, yearString
}


#pragma mark concatenateString

- (void)concatenateString
{
    NSString *newline = @"\n\n";
    NSString *concatenateString = [NSString stringWithFormat:@"%@%@%@%@%@", self.noteTitleLabel.text, newline, self.noteTextView.text, newline, _didSelectStar ? @"YES" : @"NO"];
    _originalNote = concatenateString;
}


#pragma mark barButtonItemMarkdownPressed

- (void)barButtonItemMarkdownPressed:(id)sender
{
    MarkdownWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MarkdownWebViewController"];
    self.currentNote.noteTitle = self.noteTitleLabel.text;
    self.currentNote.noteBody = self.noteTextView.text;
    controller.currentLocalNote = self.currentNote;
    [self.noteTextView hideKeyboard:sender];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark barButtonItemStarredPressed

- (void)barButtonItemStarredPressed:(id)sender
{
    if (_didSelectStar == NO)
    {
        _didSelectStar = YES;
        self.currentNote.hasNoteStar = [NSNumber numberWithBool:YES];
        
        [YRDropdownView showDropdownInView:self.view coloredTitle:@"Starred" image:nil animated:YES hideAfter:0.2];
        [self performSelector:@selector(updateStarImage) withObject:self afterDelay:0.2];
    }
    else
    {
        _didSelectStar = NO;
        self.currentNote.hasNoteStar = [NSNumber numberWithBool:NO];
        
        [YRDropdownView showDropdownInView:self.view unColoredTitle:@"UnStarred" image:nil animated:YES hideAfter:0.2];
        [self performSelector:@selector(updateStarImage) withObject:self afterDelay:0.2];
    }
}


#pragma mark 스타 이미지 업데이트

- (void)updateStarImage
{
    if ([self.currentNote.hasNoteStar boolValue] == YES)
    {
        self.starImage = nil;
        UIImage *star = [UIImage imageNameForChangingColor:@"star-256" color:kGOLD_COLOR];
        [star resizedImageByHeight:26];
        [self.buttonStar setBackgroundImage:star forState:UIControlStateNormal];
    }
    else
    {
        self.starImage = nil;
        UIImage *star = [UIImage imageNameForChangingColor:@"star-256-white" color:kWHITE_COLOR];
        [star resizedImageByHeight:26];
        [self.buttonStar setBackgroundImage:star forState:UIControlStateNormal];
    }
}


#pragma mark HTML 스트링 Parcing

#pragma mark HTML 스트링

- (NSString *)createHTMLString
{
    NSError *error;
    
    NSString *hash = @"# ";
    NSString *newline = @"\n\n";
    NSString *doubleBlank = @"  ";
    self.htmlString = [[NSMutableString alloc] init];
    NSString *htmlString = [NSString stringWithFormat:@"%@%@%@%@%@", hash, self.currentNote.noteTitle, newline, self.currentNote.noteBody, doubleBlank];
    
    [self.htmlString appendString:[NSString stringWithFormat:@"<html>"
                                   " <head>"
                                   " <meta charset='UTF-8'/>"
                                   " <style> %@ </style>"
                                   " </head> ", [self cssUTF8String]]];
    [self.htmlString appendString:[MMMarkdown HTMLStringWithMarkdown:htmlString error:&error]];
    
    htmlString = nil;
    return self.htmlString;
}


#pragma mark CSS 스트링

- (NSString *)cssUTF8String
{
    NSError *error = nil;
    NSString *filePath;
    if (iPad) {
        filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown_iPad" ofType:@"css"];
    } else {
        filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown_iPhone" ofType:@"css"];
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


#pragma mark 노트 컨텐츠

- (NSString *)noteString
{
    return self.noteTextView.text;
}


#pragma mark - 탭 제스처

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopInNoteTitleField:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [self.noteTitleLabelBackgroundView addGestureRecognizer:tapGesture];
}


#pragma mark 탭 제스처 > 팝인 노트 타이틀 필드

- (void)showPopInNoteTitleField:(UITapGestureRecognizer *)gesture
{
    if (_didHideNavigationBar == NO) {
        [self hideStatusAndNavigationBar];
    }
    
    NoteTitlePopinViewController *controller;
    
    if (iPad) {
        controller = [[NoteTitlePopinViewController alloc] initWithNibName:@"NoteTitlePopinViewController_iPad" bundle:nil];
    } else {
        controller = [[NoteTitlePopinViewController alloc] initWithNibName:@"NoteTitlePopinViewController" bundle:nil];
    }
    
    [self updateNoteDataWithCurrentState];
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    NSManagedObjectContext *mainManagedObjectContext = [managedObjectContext parentContext];
    [controller localNote:self.currentNote inManagedObjectContext:managedObjectContext];
    
    [controller setPopinTransitionStyle:BKTPopinTransitionStyleSlide];
    [controller setPopinOptions:BKTPopinDefault];
    [controller setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    [controller setPopinAlignment:BKTPopinAlignementOptionUp];
    [controller setPopinOptions:[controller popinOptions]|BKTPopinDefault];
    
    [self.navigationController presentPopinController:controller animated:YES completion:^{ }];
}


#pragma mark - 노티피케이션

#pragma mark 노트 타이틀 변경 Notification 옵저버 등록

- (void)addObserverForNoteTitleChanged
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNoteTitleChanged:)
                                                 name:@"DidChangeNoteTitleNotification"
                                               object:nil];
}


#pragma mark 노트 타이틀 변경 노티피케이션 수신 후 후속작업

- (void)didReceiveMessageNoteTitleChanged:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"DidChangeNoteTitleNotification"])
    {
        NSDictionary *userInfo = notification.userInfo;
        LocalNote *receivedNote = [userInfo objectForKey:@"didChangeNoteTitleKey"];
        self.currentNote = receivedNote;
        
        if (self.currentNote.noteTitle.length > 0) {
            self.noteTitleLabel.text = self.currentNote.noteTitle;
        }
        else {
            self.noteTitleLabel.text = @"Untitled";
        }
        
        if (_didHideNavigationBar == YES) {
            if (iPad) {
                [self performSelector:@selector(showStatusAndNavigationBar) withObject:nil afterDelay:kHideOrShowStatusAndNavigationBarDelay];
            } else {
                [self performSelector:@selector(showStatusAndNavigationBar) withObject:nil afterDelay:kHideOrShowStatusAndNavigationBarDelay];
            }
        }
    }
}


#pragma mark check to Show 헬프 메시지

- (void)checkToShowHelpMessage
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDIDSHOW_NOTEVIEW_HELP] == YES) {
        
    }
    else if ([self.currentNote.isNewNote boolValue] == YES && [[NSUserDefaults standardUserDefaults] boolForKey:kDIDSHOW_NOTEVIEW_HELP] == NO)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDIDSHOW_NOTEVIEW_HELP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.noteTextView.text = @"\n# Quick Guide\n\n### Notice\n**This quick guide note will not show again**.\n\n### Edit\n* To edit title, tap the date.\n* To save note, swipe right.\n* To remove keyboard, just swipe down.\n\n### Preview\n* To preview markdown, tap 'M' button.\n* In preview mode, double tap anywhere to enter full screen\n\n### Navigation\n* Swipe right to reveal lists.\n\n> Thank you for purchasing Clarity.  \nEnjoy Writing!";
    }
    else {
        
    }
}


#pragma mark ApplicationWillResignActive Notification 옵저버 등록

- (void)addObserverForApplicationWillResignActive
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApplicationWillResignActive:)
                                                 name:@"ApplicationWillResignActiveNotification"
                                               object:nil];
}


#pragma mark ApplicationWillResignActive 노티피케이션 수신 후 후속작업

- (void)didReceiveApplicationWillResignActive:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"ApplicationWillResignActiveNotification"])
    {
        NSLog(@"ApplicationWillResignActive Notification Received");
        [self autoSave];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currentNote forKey:@"currentNoteObjectIDKey"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"CurrentNoteObjectIDKeyNotification" object:nil userInfo:userInfo];
    }
}


#pragma mark - 유저 디폴트 > 현재 뷰 저장

- (void)saveCurrentView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:kCURRENT_VIEW_IS_LOCAL];
    [standardUserDefaults synchronize];
}


#pragma mark - 내비게이션 뷰 해제

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)popView
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Do 액션 sheet (HTML 내보내기, 메일, 기타 공유 등)

#pragma mark Do Action sheet

- (void)displayDoActionSheet:(id)sender
{
    [self.noteTextView hideKeyboard:sender];
    
    DoActionSheet *vActionSheet = [[DoActionSheet alloc] init];
    [vActionSheet setStyle];
    vActionSheet.dRound = 7;
    vActionSheet.dButtonRound = 3;
    vActionSheet.nAnimationType = 2; //2 > POP
    vActionSheet.doDimmedColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    vActionSheet.nDestructiveIndex = 7;
    
    [vActionSheet showC:@""
                 cancel:@"Cancel"
                buttons:@[@"Email as HTML", @"Email as HTML Attachment", @"Copy as HTML", @"Email as Plain Text", @"Copy as Plain Text", @"More actions as Plain Text...", @"Print Note", @"Delete Note"]
                 result:^(int nResult)
     {
         switch (nResult)
         {
             case 0:
             {
                 self.htmlString = nil;
                 [self setDefaultBodyText];
                 [self createHTMLString];
                 [self sendEmailWithTitle:self.noteTitleLabel.text andBody:self.htmlString];
             }
                 break;
             case 1:
             {
                 self.htmlString = nil;
                 [self setDefaultBodyText];
                 [self createHTMLString];
                 [self sendEmailWithTitle:self.noteTitleLabel.text withHtmlStringForAttachment:self.htmlString];
             }
                 break;
             case 2:
             {
                 self.htmlString = nil;
                 [self setDefaultBodyText];
                 [self createHTMLString];
                 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                 pasteboard.string = self.htmlString;
             }
                 break;
             case 3:
             {
                 self.htmlString = nil;
                 [self setDefaultBodyText];
                 [self sendEmailWithTitle:self.noteTitleLabel.text andBody:self.noteTextView.text];
             }
                 break;
             case 4:
             {
                 self.htmlString = nil;
                 [self setDefaultBodyText];
                 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                 pasteboard.string = self.noteTextView.text;
             }
                 break;
             case 5:
             {
                 self.htmlString = nil;
                 [self setDefaultBodyText];
                 NSArray *itemsToShare = @[self.noteTextView.text];
                 UIActivityViewController *activityViewController;
                 activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
                 [self presentViewController:activityViewController animated:YES completion:^{
                 }];
             }
                 break;
             case 6:
             {
                 self.htmlString = nil;
                 [self setDefaultBodyText];
                 [self createHTMLString];
                 NSString *noteStringForPrint = self.htmlString;
                 [self printNoteAsHTML:noteStringForPrint];
             }
                 break;
             case 7:
             {
                 [self showAlertView];
             }
                 break;
         }
     }];
}


#pragma mark 디폴트 바디 텍스트

- (void)setDefaultBodyText
{
    NSString *noContents = @"*No Contents*";
    if ([self.noteTextView.text length] == 0) {
        self.noteTextView.text = noContents;
    }
}


#pragma mark 팝 뷰 컨트롤러

- (void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark show Alert 뷰

- (void)showAlertView
{
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Delete"
                                                     message:@"do you really want to delete this note?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles: nil];
    [alert addButtonWithTitle:@"YES"];
    [alert show];
}


#pragma mark Alert 뷰 Delegate Method

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //NSLog(@"You have clicked Cancel");
    } else if(buttonIndex == 1) {
        [self deleteNote];
    }
}


#pragma mark Delete 노트

- (void)deleteNote
{
    [self saveMethodInvoked];
    [self.managedObjectContext deleteObject:self.currentNote];
    if (iPad) {
        [self.layeredNavigationController popViewControllerAnimated:YES];
        [self showBlankView];
    } else {
        [self performSelector:@selector(popViewController:) withObject:nil afterDelay:0.3];
    }
}


#pragma mark Action Sheet 액션

#pragma mark PDF 생성

- (void)createPDFDocument:(NSString *)htmlString
{
    //    self.pdfCreator.delegate = self;
    //
    NSString *path = [[[NSString stringWithFormat:@"~/Documents/%@.pdf", self.noteTitleLabel.text] stringByExpandingTildeInPath] stringByExpandingTildeInPath];
    //    CGSize size = kPaperSizeA4;
    //    UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
    //
    //    self.pdfCreator = [NDHTMLtoPDF createPDFWithHTML:htmlString pathForPDF:path pageSize:size margins:insets successBlock:^(NDHTMLtoPDF *htmlToPDF) {
    //        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    //        NSLog(@"%@",result);
    //
    //    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
    //        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
    //        NSLog(@"%@",result);
    //        [self showErrorMessageView];
    //    }];
    
    
    _htmlPdfKit = [[BNHtmlPdfKit alloc] init];
    _htmlPdfKit.delegate = self;
    _htmlPdfKit.pageSize = BNPageSizeA4;
    [_htmlPdfKit saveHtmlAsPdf:htmlString toFile:path];
}


#pragma mark BNHtmlPdfKit Delegate

- (void)htmlPdfKit:(BNHtmlPdfKit *)htmlPdfKit didSavePdfData:(NSData *)data
{
    
}


- (void)htmlPdfKit:(BNHtmlPdfKit *)htmlPdfKit didSavePdfFile:(NSString *)file
{
    NSLog(@"pdf file saved");
}


- (void)htmlPdfKit:(BNHtmlPdfKit *)htmlPdfKit didFailWithError:(NSError *)error
{
    NSLog(@"pdf error");
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


#pragma mark 이메일 공유 (attach HTML file)

- (void)sendEmailWithTitle:(NSString *)title withHtmlStringForAttachment:(NSString *)htmlString
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    NSString *fileNameWithExtension = [NSString stringWithFormat:@"%@.html", title];
    NSString *tempPath = [FCFileManager pathForTemporaryDirectoryWithPath:fileNameWithExtension];
    
    BOOL fileExists = [FCFileManager existsItemAtPath:tempPath];
    if (fileExists) {
        [FCFileManager removeItemAtPath:tempPath];
    }
    
    [FCFileManager createFileAtPath:tempPath withContent:htmlString];
    NSData *htmlFileData = [NSData dataWithContentsOfFile:tempPath];
    
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    
    [mailViewController setSubject:self.noteTitleLabel.text];
    [mailViewController setMessageBody:@"" isHTML:YES];
    NSString *mimeType = @"text/html";
    [mailViewController addAttachmentData:htmlFileData mimeType:mimeType fileName:fileNameWithExtension];
    
    [self setupMailComposeViewModalTransitionStyle:mailViewController];
    mailViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    [self presentViewController:mailViewController animated:YES completion:^ {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}


#pragma mark 이메일 공유 (send HTML mail)

- (void)sendEmailWithTitle:(NSString *)title andBody:(NSString *)body
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    
    [mailViewController setSubject:title];
    
    if (self.htmlString) {
        [mailViewController setMessageBody:body isHTML:YES];
    } else {
        [mailViewController setMessageBody:body isHTML:NO];
    }
    
    [self setupMailComposeViewModalTransitionStyle:mailViewController];
    mailViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    [self presentViewController:mailViewController animated:YES completion:^ {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
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


#pragma mark 프린트 노트

- (void)printNoteAsHTML:(NSString *)htmlString
{
    NSString *htmlStringForPrint = htmlString;
    
    if ([UIPrintInteractionController isPrintingAvailable])
    {
        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = self.title;
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        
        printController.printInfo = printInfo;
        printController.showsPageRange = YES;
        printController.printingItem = htmlStringForPrint;          //프린트 아이템
        
        [printController presentAnimated:YES completionHandler: ^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error){
             if (!completed && (error != nil)) {
//                 NSLog(@"Error Printing: %@", error);
             } else {
//                 NSLog(@"Printing Completed");
             }
         }];
    }
}


#pragma mark 델리게이트 메소드 (UIPrintInteractionControllerDelegate)

- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController
{
    [self styleViewController];
    return self.navigationController;
}


#pragma mark - JG 액션 시트

- (void)displayJGActionSheet:(UIBarButtonItem *)barButtonItem withEvent:(UIEvent *)event
{
    [self.noteTextView hideKeyboard:self];
    
    UIView *view = [event.allTouches.anyObject view];
    
    JGActionSheetSection *section = [JGActionSheetSection sectionWithTitle:@"" message:@"" buttonTitles:@[@"Email as HTML", @"Email as HTML Attachment", @"Copy as HTML", @"Email as Plain Text", @"Copy as Plain Text", @"Delete Note", @"Cancel"] buttonStyle:JGActionSheetButtonStyleBlue];
    
    [section setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:0];
    [section setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:1];
    [section setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:2];
    [section setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:3];
    [section setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:4];
    [section setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:5];
    
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
                    [self setDefaultBodyText];
                    [self createHTMLString];
                    [self sendEmailWithTitle:self.noteTitleLabel.text andBody:self.htmlString];
                }
                    break;
                case 1:
                {
                    self.htmlString = nil;
                    [self setDefaultBodyText];
                    [self createHTMLString];
                    [self sendEmailWithTitle:self.noteTitleLabel.text withHtmlStringForAttachment:self.htmlString];
                }
                    break;
                case 2:
                {
                    self.htmlString = nil;
                    [self setDefaultBodyText];
                    [self createHTMLString];
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = self.htmlString;
                }
                    break;
                case 3:
                {
                    self.htmlString = nil;
                    [self setDefaultBodyText];
                    [self sendEmailWithTitle:self.noteTitleLabel.text andBody:self.noteTextView.text];
                }
                    break;
                case 4:
                {
                    self.htmlString = nil;
                    [self setDefaultBodyText];
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = self.noteTextView.text;
                }
                    break;
                case 5:
                {
                    [self showAlertView];
                }
                    break;
                case 6:
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


#pragma mark - Show 블랭크 뷰

- (void)showBlankView
{
    BlankViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"BlankViewController"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:NO animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if(orientation == 0) {
            layeredNavigationItem.width = 768-320; //Default
        }
        else if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            layeredNavigationItem.width = 768-320;
        }
        else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            layeredNavigationItem.width = 1024-320;
        }
        layeredNavigationItem.nextItemDistance = 320;                 //레이어가 가려질 거리;
        layeredNavigationItem.hasChrome = NO;
        layeredNavigationItem.hasBorder = NO;
        layeredNavigationItem.displayShadow = YES;
    }];
}


#pragma mark - FRLayeredNavigationControllerDelegate

- (void)layeredNavigationController:(FRLayeredNavigationController*)layeredController
                  didMoveController:(UIViewController*)controller
{
    [self showStatusAndNavigationBarAndHideButton];
    [self.noteTextView resignFirstResponder];
    [self autoSave];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currentNote forKey:@"currentNoteObjectIDKey"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CurrentNoteObjectIDKeyNotification" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"StarListViewWillShowNotification" object:nil userInfo:nil];
}


#pragma mark - 상태바, 내비게이션바 컨트롤

- (void)hideNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)showNavigationBarAfterDelay
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self performSelector:@selector(showNavigationBar) withObject:nil afterDelay:0.0];
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


- (void)hideStatusAndNavigationBar
{
    if (_didHideNavigationBar == NO) {
        [self hideStatusBar];
        [self hideNavigationBar];
        _didHideNavigationBar = YES;
    }
}


- (void)showStatusAndNavigationBar
{
    if (_didHideNavigationBar == YES) {
        [self showStatusBar];
        [self showNavigationBarAfterDelay];
        [self hideButtonForFullscreenWithAnimation];
        _didHideNavigationBar = NO;
    }
}


- (void)hideStatusAndNavigationBarAndShowButton
{
    if (_didHideNavigationBar == NO) {
        [self hideStatusBar];
        [self hideNavigationBar];
        [self showButtonForFullscreenWithAnimation];
        _didHideNavigationBar = YES;
    }
}


- (void)showStatusAndNavigationBarAndHideButton
{
    if (_didHideNavigationBar == YES) {
        [self showStatusBar];
        [self showNavigationBarAfterDelay];
        [self hideButtonForFullscreenWithAnimation];
        _didHideNavigationBar = NO;
    }
}


#pragma mark - Style ViewController (모달 뷰 UI)

- (void)styleViewController
{
    //BEFORE calling to [[...ViewController alloc] init];
    [[UINavigationBar appearance] setBarTintColor:kWINDOW_BACKGROUND_COLOR];            //냅바 색상
    [[UINavigationBar appearance] setTintColor:kWHITE_COLOR];                           //냅바 버튼 색상
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:kWHITE_COLOR, NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]};
}


- (void)styleDarkViewController
{
    //BEFORE calling to [[...ViewController alloc] init];
    [[UINavigationBar appearance] setBarTintColor:kWINDOW_BACKGROUND_COLOR];            //냅바 색상
    [[UINavigationBar appearance] setTintColor:kGOLD_COLOR];                           //냅바 버튼 색상
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:kGOLD_COLOR, NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]};
}


#pragma mark - 노트 데이터 로그 콘솔에 보여주기

- (void)showNoteDataToLogConsole
{
    NSLog (@"\n***showNoteDataToLogConsole***\n");
    NSLog (@"NSDate > date: %@\n", self.currentNote.date);
    NSLog (@"NSDate > noteCreatedDate: %@\n", self.currentNote.noteCreatedDate);
    NSLog (@"NSDate > noteModifiedDate: %@\n", self.currentNote.noteModifiedDate);
    NSLog (@"NSDate > imageCreatedDate: %@\n", self.currentNote.imageCreatedDate);
    
    NSLog (@"NSData > imageData: %@\n", self.currentNote.imageData);
    NSLog (@"id > image: %@\n", self.currentNote.image);
    
    NSLog (@"NSNumber > imageUniqueId: %@\n", self.currentNote.imageUniqueId);
    NSLog (@"NSNumber > position: %@\n", self.currentNote.position);
    
    kLOGBOOL([self.currentNote.isNewNote boolValue]);
    kLOGBOOL([self.currentNote.isLocalNote boolValue]);
    kLOGBOOL([self.currentNote.isDropboxNote boolValue]);
    kLOGBOOL([self.currentNote.isiCloudNote boolValue]);
    kLOGBOOL([self.currentNote.isOtherCloudNote boolValue]);
    kLOGBOOL([self.currentNote.hasImage boolValue]);
    kLOGBOOL([self.currentNote.hasNoteStar boolValue]);
    kLOGBOOL([self.currentNote.hasNoteAnnotate boolValue]);
    
    NSLog (@"NSString > imageName: %@\n", self.currentNote.imageName);
    NSLog (@"NSString > location: %@\n", self.currentNote.location);
    NSLog (@"NSString > noteAnnotate: %@\n", self.currentNote.noteAnnotate);
    NSLog (@"NSString > noteSection: %@\n", self.currentNote.noteSection);
    NSLog (@"NSString > syncID: %@\n", self.currentNote.syncID);
    
    NSLog (@"NSString > dateString: %@\n", self.currentNote.dateString);
    NSLog (@"NSString > dayString: %@\n", self.currentNote.dayString);
    NSLog (@"NSString > monthString: %@\n", self.currentNote.monthString);
    NSLog (@"NSString > yearString: %@\n", self.currentNote.yearString);
    NSLog (@"NSString > monthAndYearString: %@\n", self.currentNote.monthAndYearString);
    
    NSLog (@"NSString > uniqueNoteIDString: %@\n", self.currentNote.uniqueNoteIDString);
    NSLog (@"NSString > sectionName: %@\n", self.currentNote.sectionName);
    NSLog (@"NSString > noteTitle: %@\n", self.currentNote.noteTitle);
    //NSLog (@"NSString > noteBody: %@\n", self.currentNote.noteBody);
    //NSLog (@"NSString > noteAll: %@\n", self.currentNote.noteAll);
    NSLog (@"\n");
}


#pragma mark - deregisterForNotifications

- (void)deregisterForNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [center removeObserver:self name:@"DidChangeNoteTitleNotification" object:nil];
    [center removeObserver:self name:@"ApplicationWillResignActiveNotification" object:nil];
    [center removeObserver:self name:@"AddNewNoteNotification" object:nil];
    [center removeObserver:self];
}


#pragma mark - Dealloc

- (void)dealloc
{
    [self deregisterForNotifications];
    NSLog(@"dealloc %@", self);
}


#pragma mark - 메모리 경고

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self autoSave];
}


#pragma mark - 뷰 사라질 때 오토 세이브 및 노티피케이션 발송

- (void)autoSaveAndRegisterStarListViewWillShowNotification
{
    [self autoSave];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"StarListViewWillShowNotification" object:nil userInfo:nil];
}


#pragma mark - iOS 버전 체크

- (void)checkiOSVersionEightPointO
{
    BOOL checkVer = ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedSame || [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedDescending);
    kLOGBOOL(checkVer);
    NSLog(@"[[UIDevice currentDevice] systemVersion] : %@", [[UIDevice currentDevice] systemVersion]);
    if (checkVer == YES)
    {
        
    }
    else
    {
        
    }
}


#pragma mark - 키보드 액세서리 뷰

- (void)addKeyboardAccessoryToolBar
{
#define kToolBarHeight_iPad     60.0
#define kToolBarHeight_iPhone   44.0
#define kToolBarFrame_iPad      CGRectMake(0 ,0, 60.0, kToolBarHeight_iPad)
#define kToolBarFrame_iPhone    CGRectMake(0 ,0, 44.0, kToolBarHeight_iPhone)
#define kInset_iPhone           10.0
#define kInset_iPad             18.0
#define kFont                   @"AvenirNext-Bold"
#define kFontSize_Medium_iPhone 24.0    //4, 8, 9
#define kFontSize_Medium_iPad   26.0    //8
#define kFontSize_Large_iPhone  34.0    //5
#define kFontSize_Large_iPad    36.0    //5
#define kFontSize_Small_iPhone  20.0    //7
#define kFontSize_Small_iPad    24.0    //4, 7, 9
#define kFontInset_iPhone       4.0
#define kFontInset_iPad         4.0
#define kButtonBackgroundColor  [UIColor clearColor]
#define kButtonNormalColor      [UIColor grayColor]
#define kButtonHighlightedColor [UIColor blackColor]
#define kTextNormalColor        [UIColor grayColor]
#define kTextHighlightedColor   [UIColor blackColor]
#define kOneImage               @"left"
#define kOneAction              previousCharacter //previousCharacter //previousWord
#define kTwoImage               @"right"
#define kTwoAction              nextCharacter //nextCharacter //nextWord
#define kThreeImage             @"keyboard_hide"
#define kThreeAction            hideKeyboard
#define kFour                   @"#"
#define kFourAction             addHash
#define kFive                   @"*"
#define kFiveAction             addAsterisk
#define kFiveFontInset_iPhone   16.0
#define kFiveFontInset_iPad     16.0
#define kSixImage               @"tab"
#define kSixAction              addTab
#define kSeven                  @"{}"
#define kSevenAction            selectWord
#define kEight                  @">"
#define kEightAction            addAngleBracket
#define kNine                   @"!"
#define kNineAction             addExclamationMark
    
    if (iPad) {
        self.keyboardAccessoryToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kToolBarHeight_iPad)];
    } else {
        self.keyboardAccessoryToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kToolBarHeight_iPhone)];
    }
    
    UIBarButtonItem *f = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 24.0f;
    
    UIImage *oneImageNormal = [UIImage imageNameForChangingColor:kOneImage color:kButtonNormalColor];
    UIImage *oneImageHighlighted = [UIImage imageNameForChangingColor:kOneImage color:kButtonHighlightedColor];
    UIButton *buttonOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOne addTarget:self action:@selector(kOneAction:)forControlEvents:UIControlEventTouchUpInside];
    [buttonOne setImage:oneImageNormal forState:UIControlStateNormal];
    [buttonOne setImage:oneImageHighlighted forState:UIControlStateSelected];
    [buttonOne setImage:oneImageHighlighted forState:UIControlStateHighlighted];
    CGFloat oneTopBottom_iPad = 20.0;
    CGFloat oneLeftRight_iPad = 20.0;
    CGFloat oneTopBottom_iPhone = 12.0;
    CGFloat oneLeftRight_iPhone = 14.0;
    if (iPad) {
        buttonOne.frame = kToolBarFrame_iPad;
        [buttonOne setImageEdgeInsets:UIEdgeInsetsMake(oneTopBottom_iPad, oneLeftRight_iPad, oneTopBottom_iPad, oneLeftRight_iPad)];
    } else {
        buttonOne.frame = kToolBarFrame_iPhone;
        [buttonOne setImageEdgeInsets:UIEdgeInsetsMake(oneTopBottom_iPhone, oneLeftRight_iPhone, oneTopBottom_iPhone, oneLeftRight_iPhone)];
    }
    UIBarButtonItem *barButtonItemOne = [[UIBarButtonItem alloc] initWithCustomView:buttonOne];
    buttonOne.backgroundColor = kButtonBackgroundColor;
    
    
    UIImage *twoImageNormal = [UIImage imageNameForChangingColor:kTwoImage color:kButtonNormalColor];
    UIImage *twoImageHighlighted = [UIImage imageNameForChangingColor:kTwoImage color:kButtonHighlightedColor];
    UIButton *buttonTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonTwo addTarget:self action:@selector(kTwoAction:)forControlEvents:UIControlEventTouchUpInside];
    [buttonTwo setImage:twoImageNormal forState:UIControlStateNormal];
    [buttonTwo setImage:twoImageHighlighted forState:UIControlStateSelected];
    [buttonTwo setImage:twoImageHighlighted forState:UIControlStateHighlighted];
    CGFloat twoTopBottom_iPad = 20.0;
    CGFloat twoLeftRight_iPad = 20.0;
    CGFloat twoTopBottom_iPhone = 12.0;
    CGFloat twoLeftRight_iPhone = 14.0;
    if (iPad) {
        buttonTwo.frame = kToolBarFrame_iPad;
        [buttonTwo setImageEdgeInsets:UIEdgeInsetsMake(twoTopBottom_iPad, twoLeftRight_iPad, twoTopBottom_iPad, twoLeftRight_iPad)];
    } else {
        buttonTwo.frame = kToolBarFrame_iPhone;
        [buttonTwo setImageEdgeInsets:UIEdgeInsetsMake(twoTopBottom_iPhone, twoLeftRight_iPhone, twoTopBottom_iPhone, twoLeftRight_iPhone)];
    }
    UIBarButtonItem *barButtonItemTwo = [[UIBarButtonItem alloc] initWithCustomView:buttonTwo];
    buttonTwo.backgroundColor = kButtonBackgroundColor;
    
    
    UIImage *threeImageNormal = [UIImage imageNameForChangingColor:kThreeImage color:kButtonNormalColor];
    UIImage *threeImageHighlighted = [UIImage imageNameForChangingColor:kThreeImage color:kButtonHighlightedColor];
    UIButton *buttonThree = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonThree addTarget:self action:@selector(kThreeAction:)forControlEvents:UIControlEventTouchUpInside];
    [buttonThree setImage:threeImageNormal forState:UIControlStateNormal];
    [buttonThree setImage:threeImageHighlighted forState:UIControlStateSelected];
    [buttonThree setImage:threeImageHighlighted forState:UIControlStateHighlighted];
    CGFloat threeTopBottom_iPad = 20.0;
    CGFloat threeLeftRight_iPad = 18.0;
    CGFloat threeTopBottom_iPhone = 12.0;
    CGFloat threeLeftRight_iPhone = 10.0;
    if (iPad) {
        buttonThree.frame = kToolBarFrame_iPad;
        [buttonThree setImageEdgeInsets:UIEdgeInsetsMake(threeTopBottom_iPad, threeLeftRight_iPad, threeTopBottom_iPad, threeLeftRight_iPad)];
    } else {
        buttonThree.frame = kToolBarFrame_iPhone;
        [buttonThree setImageEdgeInsets:UIEdgeInsetsMake(threeTopBottom_iPhone, threeLeftRight_iPhone, threeTopBottom_iPhone, threeLeftRight_iPhone)];
    }
    UIBarButtonItem *barButtonItemThree = [[UIBarButtonItem alloc] initWithCustomView:buttonThree];
    buttonThree.backgroundColor = kButtonBackgroundColor;
    
    
    UIButton *buttonFour = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonFour setTitle:kFour forState:UIControlStateNormal];
    [buttonFour setTitleColor:kTextNormalColor forState:UIControlStateNormal];
    [buttonFour setTitleColor:kTextHighlightedColor forState:UIControlStateSelected];
    [buttonFour setTitleColor:kTextHighlightedColor forState:UIControlStateHighlighted];
    if (iPad) {
        buttonFour.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Small_iPad];
        [buttonFour setContentEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
        buttonFour.frame = kToolBarFrame_iPad;
    } else {
        buttonFour.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Medium_iPhone];
        [buttonFour setContentEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
        buttonFour.frame = kToolBarFrame_iPhone;
    }
    [buttonFour addTarget:self action:@selector(kFourAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItemFour = [[UIBarButtonItem alloc] initWithCustomView: buttonFour];
    buttonFour.backgroundColor = kButtonBackgroundColor;
    
    
    UIButton *buttonFive = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonFive setTitle:kFive forState:UIControlStateNormal];
    [buttonFive setTitleColor:kTextNormalColor forState:UIControlStateNormal];
    [buttonFive setTitleColor:kTextHighlightedColor forState:UIControlStateSelected];
    [buttonFive setTitleColor:kTextHighlightedColor forState:UIControlStateHighlighted];
    if (iPad) {
        buttonFive.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Large_iPad];
        [buttonFive setContentEdgeInsets:UIEdgeInsetsMake(kFiveFontInset_iPad, 0, 0, 0)];
        buttonFive.frame = kToolBarFrame_iPad;
    } else {
        buttonFive.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Large_iPhone];
        [buttonFive setContentEdgeInsets:UIEdgeInsetsMake(kFiveFontInset_iPhone, 0, 0, 0)];
        buttonFive.frame = kToolBarFrame_iPhone;
    }
    [buttonFive addTarget:self action:@selector(kFiveAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItemFive = [[UIBarButtonItem alloc] initWithCustomView: buttonFive];
    buttonFive.backgroundColor = kButtonBackgroundColor;
    
    
    UIImage *sixImageNormal = [UIImage imageNameForChangingColor:kSixImage color:kButtonNormalColor];
    UIImage *sixImageHighlighted = [UIImage imageNameForChangingColor:kSixImage color:kButtonHighlightedColor];
    UIButton *buttonSix = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSix addTarget:self action:@selector(kSixAction:)forControlEvents:UIControlEventTouchUpInside];
    [buttonSix setImage:sixImageNormal forState:UIControlStateNormal];
    [buttonSix setImage:sixImageHighlighted forState:UIControlStateSelected];
    [buttonSix setImage:sixImageHighlighted forState:UIControlStateHighlighted];
    CGFloat sixTopBottom_iPad = 22.0;
    CGFloat sixLeftRight_iPad = 18.0;
    CGFloat sixTopBottom_iPhone = 15.0;
    CGFloat sixLeftRight_iPhone = 11.0;
    if (iPad) {
        buttonSix.frame = kToolBarFrame_iPad;
        [buttonSix setImageEdgeInsets:UIEdgeInsetsMake(sixTopBottom_iPad, sixLeftRight_iPad, sixTopBottom_iPad, sixLeftRight_iPad)];
    } else {
        buttonSix.frame = kToolBarFrame_iPhone;
        [buttonSix setImageEdgeInsets:UIEdgeInsetsMake(sixTopBottom_iPhone, sixLeftRight_iPhone, sixTopBottom_iPhone, sixLeftRight_iPhone)];
    }
    UIBarButtonItem *barButtonItemSix = [[UIBarButtonItem alloc] initWithCustomView:buttonSix];
    buttonSix.backgroundColor = kButtonBackgroundColor;
    
    
    UIButton *buttonSeven = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonSeven setTitle:kSeven forState:UIControlStateNormal];
    [buttonSeven setTitleColor:kTextNormalColor forState:UIControlStateNormal];
    [buttonSeven setTitleColor:kTextHighlightedColor forState:UIControlStateSelected];
    [buttonSeven setTitleColor:kTextHighlightedColor forState:UIControlStateHighlighted];
    if (iPad) {
        buttonSeven.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Small_iPad];
        [buttonSeven setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        buttonSeven.frame = kToolBarFrame_iPad;
    } else {
        buttonSeven.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Small_iPhone];
        [buttonSeven setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        buttonSeven.frame = kToolBarFrame_iPhone;
    }
    [buttonSeven addTarget:self action:@selector(kSevenAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItemSeven = [[UIBarButtonItem alloc] initWithCustomView: buttonSeven];
    buttonSeven.backgroundColor = kButtonBackgroundColor;
    
    
    if (iPad) {
        UIButton *buttonEight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonEight setTitle:kEight forState:UIControlStateNormal];
        [buttonEight setTitleColor:kTextNormalColor forState:UIControlStateNormal];
        [buttonEight setTitleColor:kTextHighlightedColor forState:UIControlStateSelected];
        [buttonEight setTitleColor:kTextHighlightedColor forState:UIControlStateHighlighted];
        if (iPad) {
            buttonEight.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Medium_iPad];
            [buttonEight setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            buttonEight.frame = kToolBarFrame_iPad;
        } else {
            buttonEight.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Medium_iPhone];
            [buttonEight setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            buttonEight.frame = kToolBarFrame_iPhone;
        }
        [buttonEight addTarget:self action:@selector(kEightAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItemEight = [[UIBarButtonItem alloc] initWithCustomView: buttonEight];
        buttonEight.backgroundColor = kButtonBackgroundColor;
        
        
        UIButton *buttonNine = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonNine setTitle:kNine forState:UIControlStateNormal];
        [buttonNine setTitleColor:kTextNormalColor forState:UIControlStateNormal];
        [buttonNine setTitleColor:kTextHighlightedColor forState:UIControlStateSelected];
        [buttonNine setTitleColor:kTextHighlightedColor forState:UIControlStateHighlighted];
        if (iPad) {
            buttonNine.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Small_iPad];
            [buttonNine setContentEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
            buttonNine.frame = kToolBarFrame_iPad;
        } else {
            buttonNine.titleLabel.font = [UIFont fontWithName:kFont size:kFontSize_Medium_iPhone];
            [buttonNine setContentEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
            buttonNine.frame = kToolBarFrame_iPhone;
        }
        [buttonNine addTarget:self action:@selector(kNineAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItemNine = [[UIBarButtonItem alloc] initWithCustomView: buttonNine];
        buttonNine.backgroundColor = kButtonBackgroundColor;
        
        NSArray *navigationBarItems = @[f, barButtonItemOne, fixed, f, barButtonItemSix, f, barButtonItemFour, f, barButtonItemFive, f, barButtonItemThree, f, barButtonItemEight, f, barButtonItemNine, f, barButtonItemSeven, f, fixed, barButtonItemTwo, f];
        self.keyboardAccessoryToolBar.items = navigationBarItems;
    } else {
        NSArray *navigationBarItems = @[f, barButtonItemOne, f, barButtonItemFour, f, barButtonItemFive, f, barButtonItemThree, f, barButtonItemSix, f, barButtonItemSeven, f, barButtonItemTwo, f];
        self.keyboardAccessoryToolBar.items = navigationBarItems;
    }
    
    self.noteTextView.inputAccessoryView = self.keyboardAccessoryToolBar;
}


#pragma mark 키보드 액세서리 뷰 액션 메소드

- (void)previousCharacter:(id)sender
{
    [self.noteTextView previousCharacter:sender];
}


- (void)nextCharacter:(id)sender
{
    [self.noteTextView nextCharacter:sender];
}


- (void)hideKeyboard:(id)sender
{
    [self.noteTextView hideKeyboard:sender];
}


- (void)addHash:(id)sender
{
    [self.noteTextView addHash:sender];
}


- (void)addAsterisk:(id)sender
{
    [self.noteTextView addAsterisk:sender];
}


- (void)addTab:(id)sender
{
    [self.noteTextView addTab:sender];
}


- (void)selectWord:(id)sender
{
    [self.noteTextView selectWord:sender];
}


- (void)addAngleBracket:(id)sender
{
    [self.noteTextView addAngleBracket:sender];
}


- (void)addExclamationMark:(id)sender
{
    [self.noteTextView addExclamationMark:sender];
}


- (void)previousWord:(id)sender
{
    [self.noteTextView previousWord:sender];
}


- (void)nextWord:(id)sender
{
    [self.noteTextView nextWord:sender];
}


- (void)selectParagraph:(id)sender
{
    [self.noteTextView selectParagraph:sender];
}


@end
