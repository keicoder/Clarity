//
//  DropboxAddEditViewController.m
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import "DropboxAddEditViewController.h"
//#import "FRLayeredNavigationController/FRLayeredNavigation.h"
#import "ICTextView.h"                                                  //커스텀 텍스트 뷰
#import "MarkdownWebViewController.h"                                   //MM 마크다운 뷰
#import "NoteDataManager.h"                                             //노트 데이터 매니저
#import "UIImage+MakeThumbnail.h"                                       //이미지 섬네일
#import "UIImage+ChangeColor.h"                                         //이미지 컬러 변경
#import "MMMarkdown.h"                                                  //MM 마크다운 > HTML 스트링 생성
#import "YRDropdownView.h"                                              //드랍다운 뷰
#import <MessageUI/MessageUI.h>                                         //이메일/메시지 공유
#import "DoActionSheet.h"                                               //DoActionSheet
#import <MaryPopin/UIViewController+MaryPopin.h>                        //팝인 뷰 > 카테고리
#import "NoteTitlePopinViewController.h"                                //팝인 뷰 > 노트 타이틀 뷰
#import "Quayboard.h"                                                   //인풋 액세서리 뷰 > Cool
#import "UIButtonPressAndHold.h"


@interface DropboxAddEditViewController () <JSMQuayboardBarDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate>

//@property (strong, nonatomic) UIPopoverController *dropboxNoteListPopoverController;
//@property (nonatomic, strong) UIPopoverController *menuPopoverController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext; //컨텍스트

@property (nonatomic, strong) ICTextView *noteTextView;                     //노트 텍스트 뷰
@property (nonatomic, strong) UILabel *noteTitleLabel;                      //노트 타이틀 레이블
@property (nonatomic, strong) UIView *noteTitleLabelBackgroundView;         //노트 타이틀 레이블 백그라운드 뷰
@property (nonatomic, strong) JSMQuayboardBar *textViewAccessory;           //인풋 액세서리
@property (nonatomic, strong) NSMutableString *htmlString;                  //HTML 스트링
@property (nonatomic, strong) UIBarButtonItem *barButtonItemStarred;        //바 버튼 아이템
@property (nonatomic, strong) UIButton *buttonStar;                         //바 버튼 아이템
@property (nonatomic, strong) UIButton *buttonForFullscreen;                //툴바 뷰 Up 버튼
@property (nonatomic, strong) UIImage *starImage;                           //스타 이미지

@end


@implementation DropboxAddEditViewController
{
    BOOL _didSelectStar;                                                    //별표 상태 저장
    NSString *_originalNote;                                                //저장 시 비교하기위한 원본 노트
}


#pragma mark - 노트 in Managed Object Context

- (void)note:(DropboxNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self.currentNote = note;
    self.managedObjectContext = managedObjectContext;
}


#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addNoteTextView];                             //노트 텍스트 뷰
    [self addNoteTitleLabel];                           //노트 타이틀 레이블
    [self registerKeyboardNotifications];               //키보드 노티피케이션
    [self addInputAccessoryView];                       //인풋 액세서리 뷰
    [self addBarButtonItems];                           //바 버튼
    [self assignNoteData];                              //노트 데이터
    [self.noteTextView assignTextViewAttribute];        //노트 텍스트 뷰 속성
    [self updateStarImage];                             //스타 이미지 업데이트
    [self addTapGestureRecognizer];                     //탭 제스처
    [self addObserverForNoteTitleChanged];              //노트 타이틀 변경 Notification 옵저버 등록
    [self addObserverForHelpMessageMarkdownWebViewPopped]; //Help Message 마크다운 웹뷰에서 나올 때 Notification
    [self addButtonForFullscreen];                      //Full Screen 버튼
    [self checkNewNote];                                //뉴 노트 체크 > 키보드 Up
    [self checkToShowHelpMessage];                      //헬프 message 보여줄건지 판단
//    [self showNoteDataToLogConsole];                    //노트 데이터 로그 콘솔에 보여주기
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self saveCurrentView];                             //현재 뷰 > 유저 디폴트 저장
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.noteTextView = nil;
    self.noteTitleLabel = nil;
    self.noteTitleLabelBackgroundView = nil;
    self.starImage = nil;
    self.htmlString = nil;
}


#pragma mark - 노트 텍스트 뷰
#pragma mark 노트 체크 > 키보드 Up

- (void)checkNewNote
{
    if (self.isNewNote)
    {
        [self.noteTextView becomeFirstResponder];
    }
    else {
        [self.noteTextView resignFirstResponder];
    }
}


#pragma mark - 노트 데이터, 텍스트 뷰, 레이블 타이틀 뷰

#pragma mark 노트 데이터 지정

- (void)assignNoteData
{
    self.noteTitleLabel.text = self.currentNote.noteTitle;      //타이틀
    self.noteTextView.text = self.currentNote.noteBody;         //본문
    _didSelectStar = [self.currentNote.hasNoteStar boolValue];  //스타 불리언 값
    _originalNote = self.currentNote.noteAll;                   //저장 시 비교하기위한 원본 노트
    
    //스타 이미지로 대체
//    if (_didSelectStar == YES)
//    {
//        self.barButtonItemStarred.title = @"Starred";
//        [self.barButtonItemStarred setTitleTextAttributes:@{NSForegroundColorAttributeName:kGOLD_COLOR} forState:UIControlStateNormal];
//    }
//    else
//    {
//        self.barButtonItemStarred.title = @"UnStarred";
//        [self.barButtonItemStarred setTitleTextAttributes:@{NSForegroundColorAttributeName:kWHITE_COLOR} forState:UIControlStateNormal];
//    }
}


#pragma mark 텍스트 뷰 생성

- (void)addNoteTextView
{
    self.noteTextView = [[ICTextView alloc] initWithFrame:self.view.bounds];
    self.noteTextView.delegate = self;
    [self.view addSubview:self.noteTextView];
    [self.noteTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
}


#pragma mark 타이틀 레이블 생성

- (void)addNoteTitleLabel
{
    CGFloat noteTitleLabelHeight = 44;
    
    self.noteTitleLabelBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -44, CGRectGetWidth(self.view.bounds), noteTitleLabelHeight)];
    self.noteTitleLabelBackgroundView.backgroundColor = kTEXTVIEW_BACKGROUND_COLOR;
    [self.noteTextView addSubview:self.noteTitleLabelBackgroundView];
    [self.noteTitleLabelBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    int labelPadding = 10;
    self.noteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, 0, CGRectGetWidth(self.view.bounds) - (labelPadding * 2), CGRectGetHeight(self.noteTitleLabelBackgroundView.bounds))];
    self.noteTitleLabel.font = kTEXTVIEW_LABEL_FONT;
    self.noteTitleLabel.textColor = kTEXTVIEW_LABEL_TEXT_COLOR;
    self.noteTitleLabel.backgroundColor = kCLEAR_COLOR;
    self.noteTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.noteTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail; //NSLineBreakByCharWrapping
    [self.noteTitleLabelBackgroundView addSubview:self.noteTitleLabel];
    [self.noteTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}


#pragma mark - 인풋 액세서리 뷰 (JSMQuayboardBar)

- (void)addInputAccessoryView
{
    //Create the Quayboard bar
	self.textViewAccessory = [[JSMQuayboardBar alloc] initWithFrame:CGRectZero];
	self.textViewAccessory.delegate = self;
	self.noteTextView.inputAccessoryView = self.textViewAccessory;
    
	//Create the Quayboard keys
    JSMQuayboardButton *previousCharacterKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
	previousCharacterKey.title = @"◀︎";
	[previousCharacterKey addTarget:self action:@selector(previousCharacterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.textViewAccessory addKey:previousCharacterKey];
    
    JSMQuayboardButton *tabKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
	tabKey.title = @"⍈";
	[tabKey addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.textViewAccessory addKey:tabKey];
    
    JSMQuayboardButton *hashKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
	hashKey.title = @"#";
	[hashKey addTarget:self action:@selector(hashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.textViewAccessory addKey:hashKey];
    
    JSMQuayboardButton *hideKeyboardKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
	hideKeyboardKey.title = @"▼";
	[hideKeyboardKey addTarget:self action:@selector(hideKeyboardButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.textViewAccessory addKey:hideKeyboardKey];
    
    JSMQuayboardButton *asteriskKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
	asteriskKey.title = @"✳︎";
	[asteriskKey addTarget:self action:@selector(asteriskButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.textViewAccessory addKey:asteriskKey];
    
    JSMQuayboardButton *selectKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
	selectKey.title = @"{ }";
	[selectKey addTarget:self action:@selector(selectWordButonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.textViewAccessory addKey:selectKey];
    
    JSMQuayboardButton *nextCharacterKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
	nextCharacterKey.title = @"▶︎";
	[nextCharacterKey addTarget:self action:@selector(nextCharacterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.textViewAccessory addKey:nextCharacterKey];
    
//    JSMQuayboardButton *angleBracketKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
//	angleBracketKey.title = @">";
//	[angleBracketKey addTarget:self action:@selector(angleBracketButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//	[self.textViewAccessory addKey:angleBracketKey];

//    JSMQuayboardButton *hyphenKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
//	hyphenKey.title = @"-";
//	[hyphenKey addTarget:self action:@selector(hyphenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//	[self.textViewAccessory addKey:hyphenKey];

//    JSMQuayboardButton *equalKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
//	equalKey.title = @"=";
//	[equalKey addTarget:self action:@selector(equalButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//	[self.textViewAccessory addKey:equalKey];
    
//    JSMQuayboardButton *exclamationMarkKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
//	exclamationMarkKey.title = @"!";
//	[exclamationMarkKey addTarget:self action:@selector(exclamationMarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//	[self.textViewAccessory addKey:exclamationMarkKey];
    
//    JSMQuayboardButton *linkKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
//	linkKey.title = @"♾";
//	[linkKey addTarget:self action:@selector(linkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [self.textViewAccessory addKey:linkKey];
  
//    JSMQuayboardButton *imageKey = [[JSMQuayboardButton alloc] initWithFrame:CGRectZero];
//	imageKey.title = @"🂠";
//	[tabKey addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//	[self.textViewAccessory addKey:imageKey];
}


#pragma mark Quayboard Bar Delegate Methods

- (void)quayboardBar:(JSMQuayboardBar *)quayboardBar keyWasPressed:(JSMQuayboardButton *)key {
	// Find the range of the selected text
	NSRange range = self.noteTextView.selectedRange;
	
	// Get the relevant strings
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = key.value;
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
	
	// Update the textView's text
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
	// More the selection to after our inserted text
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    // Move cursor
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark Quayboard Bar action methods
#pragma mark previousWordButtonPressed

- (void)previousWordButtonPressed:(id)sender
{
    NSRange selectedRange = self.noteTextView.selectedRange;
    NSInteger currentLocation = selectedRange.location;
    
    if ( currentLocation == 0 ){
        return;
    }
    
    NSRange newRange = [self.noteTextView.text
                        rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                        options:NSBackwardsSearch
                        range:NSMakeRange(0, (currentLocation - 1))];
    
    if ( newRange.location != NSNotFound ) {
        self.noteTextView.selectedRange = NSMakeRange((newRange.location + 1), 0);
    } else {
        self.noteTextView.selectedRange = NSMakeRange(0, 0);
    }
    [self.noteTextView textViewDidChange:self.noteTextView];    //Move cursor
}


#pragma mark previousCharacterButtonPressed

- (void)previousCharacterButtonPressed:(id)sender
{
    UITextRange *selectedRange = [self.noteTextView selectedTextRange]; //Calculate the new position, - for left and + for right
    
    if (self.noteTextView.selectedRange.location > 0)
    {
        UITextPosition *newPosition = [self.noteTextView positionFromPosition:selectedRange.start offset:-1];
        UITextRange *newRange = [self.noteTextView textRangeFromPosition:newPosition toPosition:newPosition];
        [self.noteTextView setSelectedTextRange:newRange];      //Set new range
    }
    [self.noteTextView textViewDidChange:self.noteTextView];    //Move cursor
}


#pragma mark hashButtonPressed

- (void)hashButtonPressed:(id)sender
{
	// Find the range of the selected text
	NSRange range = self.noteTextView.selectedRange;
	
	// Get the relevant strings
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = @"#";
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
	
	// Update the textView's text
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
	// More the selection to after our inserted text
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    // Move cursor
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark asteriskButtonPressed

- (void)asteriskButtonPressed:(id)sender
{
	NSRange range = self.noteTextView.selectedRange;
	
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = @"*";
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
	
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark angleBracketButtonPressed

- (void)angleBracketButtonPressed:(id)sender
{
	// Find the range of the selected text
	NSRange range = self.noteTextView.selectedRange;
	
	// Get the relevant strings
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = @">";
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
	
	// Update the textView's text
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
	// More the selection to after our inserted text
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    // Move cursor
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark imageButtonPressed (not working)

- (void)imageButtonPressed:(id)sender
{
	// Find the range of the selected text
	NSRange range = self.noteTextView.selectedRange;
	
	// Get the relevant strings
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = @"![image](http://)";
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
	
	// Update the textView's text
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
    //NSRange rangeFromInsertingString = NSMakeRange(9, 7);
    
	// More the selection to after our inserted text
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    [self cursorPosition];
    
    // Move cursor
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark linkButtonPressed

- (void)linkButtonPressed:(id)sender
{
	
}


#pragma mark hideKeyboardButtonPressed

- (void)hideKeyboardButtonPressed:(id)sender
{
	[self.noteTextView resignFirstResponder];
}


#pragma mark hyphenButtonPressed

- (void)hyphenButtonPressed:(id)sender
{
	NSRange range = self.noteTextView.selectedRange;
	
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = @"-";
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
    
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark equalButtonPressed

- (void)equalButtonPressed:(id)sender
{
	// Find the range of the selected text
	NSRange range = self.noteTextView.selectedRange;
	
	// Get the relevant strings
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = @"=";
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
	
	// Update the textView's text
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
	// More the selection to after our inserted text
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    // Move cursor
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark exclamationMarkButtonPressed

- (void)exclamationMarkButtonPressed:(id)sender
{
	// Find the range of the selected text
	NSRange range = self.noteTextView.selectedRange;
	
	// Get the relevant strings
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = @"!";
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
	
	// Update the textView's text
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
	// More the selection to after our inserted text
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    // Move cursor
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark tabButtonPressed

- (void)tabButtonPressed:(id)sender
{
	// Find the range of the selected text
	NSRange range = self.noteTextView.selectedRange;
	
	// Get the relevant strings
	NSString *firstHalfString = [self.noteTextView.text substringToIndex:range.location];
	NSString *insertingString = @"\t";
	NSString *secondHalfString = [self.noteTextView.text substringFromIndex:range.location+range.length];
	
	// Update the textView's text
	self.noteTextView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
	// More the selection to after our inserted text
	range.location += insertingString.length;
	range.length = 0;
	self.noteTextView.selectedRange = range;
    
    // Move cursor
    [self.noteTextView textViewDidChange:self.noteTextView];
}


#pragma mark selectWordButonPressed

- (void)selectWordButonPressed:(id)sender
{
    NSRange selectedRange = self.noteTextView.selectedRange;
    
    if (![self.noteTextView hasText])
    {
        [self.noteTextView select:self];
    }
    else if ([self.noteTextView hasText] && selectedRange.length == 0)
    {
        [self.noteTextView select:self];
    }
    else if ([self.noteTextView hasText] && selectedRange.length > 0)
    {
        selectedRange.location = selectedRange.location + selectedRange.length;
        selectedRange.length = 0;
        self.noteTextView.selectedRange = selectedRange;
    }
    [self cursorPosition];
}


#pragma mark cursorPosition

- (CGPoint)cursorPosition;
{
    CGPoint cursorPosition = [self.noteTextView caretRectForPosition:self.noteTextView.selectedTextRange.start].origin;
    return cursorPosition;
}


#pragma mark nextCharacterButtonPressed

- (void)nextCharacterButtonPressed:(id)sender
{
    UITextRange *selectedRange = [self.noteTextView selectedTextRange]; //Calculate the new position, - for left and + for right
    
    if (self.noteTextView.selectedRange.location < self.noteTextView.text.length)
    {
        UITextPosition *newPosition = [self.noteTextView positionFromPosition:selectedRange.start offset:1];
        UITextRange *newRange = [self.noteTextView textRangeFromPosition:newPosition toPosition:newPosition];
        [self.noteTextView setSelectedTextRange:newRange];      //Set new range
    }
    [self.noteTextView textViewDidChange:self.noteTextView];    //Move cursor
}


#pragma mark nextWordButtonPressed

- (void)nextWordButtonPressed:(id)sender
{
    NSRange selectedRange = self.noteTextView.selectedRange;
    NSInteger currentLocation = selectedRange.location + selectedRange.length;
    NSInteger textLength = [self.noteTextView.text length];
    
    if ( currentLocation == textLength ) {
        return;
    }
    
    NSRange newRange = [self.noteTextView.text
                        rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                        options:NSCaseInsensitiveSearch
                        range:NSMakeRange((currentLocation + 1), (textLength - 1 - currentLocation))];
    
    if ( newRange.location != NSNotFound ) {
        self.noteTextView.selectedRange = NSMakeRange(newRange.location, 0);
    } else {
        self.noteTextView.selectedRange = NSMakeRange(textLength, 0);
    }
    
    [self.noteTextView textViewDidChange:self.noteTextView];    //Move cursor
}


#pragma mark undoButtonPressed

- (void)undoButtonPressed:(id)sender
{
    [[self.noteTextView undoManager] undo];
}


#pragma mark redoButtonPressed

- (void)redoButtonPressed:(id)sender
{
    [[self.noteTextView undoManager] redo];
}


#pragma mark - FRLayeredNavigationControllerDelegate
//
//- (void)layeredNavigationController:(FRLayeredNavigationController*)layeredController
//                 willMoveController:(UIViewController*)controller
//{
//    
//}
//
//
//- (void)layeredNavigationController:(FRLayeredNavigationController*)layeredController
//               movingViewController:(UIViewController*)controller
//{
//    [self.noteTextView resignFirstResponder];
//}
//
//
//- (void)layeredNavigationController:(FRLayeredNavigationController*)layeredController
//                  didMoveController:(UIViewController*)controller
//{
//    
//}


#pragma mark - Keyboard handle

- (void)registerKeyboardNotifications
{
    //키보드 팝업 옵저버 (키보드 팝업 시 텍스트 뷰 인셋 조절)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:self.view.window];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.noteTextView keyboardWillShow:notification];
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    [self.noteTextView keyboardDidShow:notification];
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    [self.noteTextView keyboardWillHide:notification];
}


- (void)keyboardDidHide:(NSNotification*)notification
{
    [self.noteTextView keyboardDidHide:notification];
}


#pragma mark - UITextView delegate method (optional)

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self hideStatusBar];                                    //상태바 Up
    [self hideNavigationBar];                                //내비게이션바 Up
    [self hideButtonForFullscreenWithAnimation];             //Full Screen 버튼
    return YES;
}


#pragma mark textViewDidChange > 텍스트 스크롤링

- (void)textViewDidChange:(UITextView *)textView
{
    [self.noteTextView textViewDidChange:self.noteTextView];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	[self.noteTextView textViewShouldEndEditing:self.noteTextView];
    [self showStatusBar];                                    //상태바 Down
    [self showNavigationBar];                                //내비게이션바 Down
    [self hideButtonForFullscreenWithAnimation];             //Full Screen 버튼
    return YES;
}


#pragma mark - 바 버튼

- (void)addBarButtonItems
{
    UIBarButtonItem *barButtonItemFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barButtonItemFixed.width = 20.0f;
    UIBarButtonItem *barButtonItemFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
//    UIImage *cancel = [UIImage imageNameForChangingColor:@"previous-250" color:kNAVIGATIONBAR_ICONIMAGE_COLOR];
//    UIImage *cancelSelected = [UIImage imageNamed:@"previous-250"];
//    [buttoncancel setBackgroundImage:cancelSelected forState:UIControlStateSelected];
    
    
    UIImage *cancel = [UIImage imageNamed:@"previous-250"];
    //    UIImage *cancel = [UIImage imageNamed:@""];
    UIButton *buttoncancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttoncancel addTarget:self action:@selector(barButtonItemCancelPressed:)forControlEvents:UIControlEventTouchUpInside];
    [buttoncancel setBackgroundImage:cancel forState:UIControlStateNormal];
    buttoncancel.frame = CGRectMake(0 ,0, 24, 24);
    UIBarButtonItem *barButtonItemCancel = [[UIBarButtonItem alloc] initWithCustomView:buttoncancel];
    
    
    UIImage *fullScreen = [UIImage imageNamed:@"expand-256"];
    UIButton *buttonFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonFullScreen addTarget:self action:@selector(barButtonItemFullScreenPressed:)forControlEvents:UIControlEventTouchUpInside];
    [buttonFullScreen setBackgroundImage:fullScreen forState:UIControlStateNormal];
    buttonFullScreen.frame = CGRectMake(0 ,0, 18, 18);
    UIBarButtonItem *barButtonItemFullScreen = [[UIBarButtonItem alloc] initWithCustomView:buttonFullScreen];
    
    
    UIImage *star = [UIImage imageNamed:@"star-256-white"];
    self.buttonStar = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonStar addTarget:self action:@selector(barButtonItemStarredPressed:)forControlEvents:UIControlEventTouchUpInside];
    [self.buttonStar setBackgroundImage:star forState:UIControlStateNormal];
    self.buttonStar.frame = CGRectMake(0 ,0, 26, 26);
    self.barButtonItemStarred = [[UIBarButtonItem alloc] initWithCustomView:self.buttonStar];
    
    
    UIImage *add = [UIImage imageNamed:@"plus-256"];
    UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonAdd addTarget:self action:@selector(barButtonItemAddPressed:)forControlEvents:UIControlEventTouchUpInside];
    [buttonAdd setBackgroundImage:add forState:UIControlStateNormal];
    buttonAdd.frame = CGRectMake(0 ,0, 26, 26);
    UIBarButtonItem *barButtonItemAdd = [[UIBarButtonItem alloc] initWithCustomView:buttonAdd];
    
    
    UIImage *markdown = [UIImage imageNamed:@"md-256"];
    UIButton *buttonMarkdown = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonMarkdown addTarget:self action:@selector(barButtonItemMarkdownPressed:)forControlEvents:UIControlEventTouchUpInside];
    [buttonMarkdown setBackgroundImage:markdown forState:UIControlStateNormal];
    buttonMarkdown.frame = CGRectMake(0 ,0, 22, 22);
    UIBarButtonItem *barButtonItemMarkdown = [[UIBarButtonItem alloc] initWithCustomView:buttonMarkdown];
    
    
    UIImage *share = [UIImage imageNamed:@"action83"];
    UIButton *buttonShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonShare addTarget:self action:@selector(barButtonItemSharePressed:)forControlEvents:UIControlEventTouchUpInside];
    [buttonShare setBackgroundImage:share forState:UIControlStateNormal];
    buttonShare.frame = CGRectMake(0 ,0, 28, 24);
    UIBarButtonItem *barButtonItemShare = [[UIBarButtonItem alloc] initWithCustomView:buttonShare];
    
    
    UIImage *save = [UIImage imageNamed:@"save-64"];
    UIButton *buttonSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSave addTarget:self action:@selector(barButtonItemSavePressed:)forControlEvents:UIControlEventTouchUpInside];
    [buttonSave setBackgroundImage:save forState:UIControlStateNormal];
    buttonSave.frame = CGRectMake(0 ,0, 22, 22);
    UIBarButtonItem *barButtonItemSave = [[UIBarButtonItem alloc] initWithCustomView:buttonSave];
    
    self.navigationItem.hidesBackButton=YES;
    
    NSArray *navigationBarItems = @[barButtonItemSave, barButtonItemFlexible, self.barButtonItemStarred, barButtonItemFlexible, barButtonItemMarkdown, barButtonItemFlexible, barButtonItemFixed, barButtonItemAdd, barButtonItemFixed, barButtonItemFlexible, barButtonItemShare, barButtonItemFlexible, barButtonItemFullScreen, barButtonItemFlexible, barButtonItemCancel];
    
    self.navigationItem.rightBarButtonItems = navigationBarItems;
    
//    NSArray *toolbarItems = @[barButtonItemCancel, barButtonItemFlexible, barButtonItemFullScreen, barButtonItemFlexible, barButtonItemShare, barButtonItemFlexible, barButtonItemFixed, barButtonItemAdd, barButtonItemFixed, barButtonItemFlexible, barButtonItemMarkdown, barButtonItemFlexible, self.barButtonItemStarred, barButtonItemFlexible, barButtonItemSave];
//
//    self.toolbar.items = toolbarItems;
//    self.toolbar.translucent = NO;
//    self.toolbar.barTintColor = kTOOLBAR_DROPBOX_LIST_VIEW_BACKGROUND_COLOR;
//    [self.view addSubview:self.toolbar];
}


#pragma mark 버튼 액션 Method: 컨텍스트 저장, 뷰 pop 외

- (void)barButtonItemCancelPressed:(id)sender
{
    if (self.isNewNote) {
        [self deleteNote:self.currentNote];
        [self performSelector:@selector(dismissView) withObject:self afterDelay:0.1];
    } else {
        [self performSelector:@selector(popView) withObject:self afterDelay:0.1];
    }
}


#pragma mark 뉴 버튼 (뉴 노트 추가 Notification 통보)

- (void)barButtonItemAddPressed:(id)sender
{
    if (self.isNewNote) {
        [self deleteNote:self.currentNote];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self performSelector:@selector(postAddNewDropboxNoteNotification) withObject:self afterDelay:0.0];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self performSelector:@selector(postAddNewDropboxNoteNotification) withObject:self afterDelay:0.0];
    }
}


- (void)postAddNewDropboxNoteNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"AddNewDropboxNoteNotification" object:nil userInfo:nil];
}


#pragma mark FullScreen 버튼

- (void)barButtonItemFullScreenPressed:(id)sender
{
    [self hideStatusBar];
    [self hideNavigationBar];
    [self showButtonForFullscreenWithAnimation];
}


- (void)addButtonForFullscreen
{
    UIImage *image = [UIImage imageNamed:@"collapse-black-256"];
    UIImage *imageThumb = [image makeThumbnailOfSize:CGSizeMake(24, 24)];
    
    self.buttonForFullscreen = [UIButton buttonWithType:UIButtonTypeSystem];
    self.buttonForFullscreen.frame = CGRectMake(0, -44, 44, 44);
    [self.buttonForFullscreen setImage:imageThumb forState:UIControlStateNormal];
    self.buttonForFullscreen.tintColor = [UIColor colorWithRed:0.094 green:0.071 blue:0.188 alpha:1];
    [self.view addSubview:self.buttonForFullscreen];
    
    [self.buttonForFullscreen addTarget:self action:@selector(showStatbarNavbarAndHideFullScreenButton) forControlEvents:UIControlEventTouchUpInside];
}


- (void)showButtonForFullscreenWithAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.buttonForFullscreen.frame = CGRectMake(0, 0, 44, 44);
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
                         self.buttonForFullscreen.frame = CGRectMake(0, -44, 44, 44);
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
    [self showStatusBar];
    [self showNavigationBar];
    [self hideButtonForFullscreenWithAnimation];
}


#pragma mark 세이브 노트

- (void)barButtonItemSavePressed:(id)sender
{
    NSString *newline = @"\n\n";
    NSString *concatenateString = [NSString stringWithFormat:@"%@%@%@%@%@", self.noteTitleLabel.text, newline, self.noteTextView.text, newline, _didSelectStar ? @"YES" : @"NO"];
    
    if (self.isNewNote) {
        [self saveMethodInvoked];
        [self performSelector:@selector(dismissView) withObject:self afterDelay:0.1];
    }
    else {
        if ([_originalNote isEqualToString:concatenateString]) {
            [self barButtonItemCancelPressed:sender];
        }
        else {
            [self saveMethodInvoked];
            [self performSelector:@selector(popView) withObject:self afterDelay:0.1];
        }
    }
}


- (void)saveMethodInvoked
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSManagedObjectContext *mainManagedObjectContext = [managedObjectContext parentContext];
    
    [self updateNoteDataWithCurrentState];                         //업데이트 노트 데이터
    [self.currentNote saveNote:self.currentNote];                  //노트 저장
    
    [managedObjectContext performBlock:^
    {
        NSError *error = nil;
        if ([managedObjectContext save:&error]) {
            [mainManagedObjectContext save:&error];
        } else {
            //NSLog(@"Error saving context: %@", error);
        }
    }];
}


#pragma mark 업데이트 노트 데이터

- (void)updateNoteDataWithCurrentState
{
    self.currentNote.noteTitle = self.noteTitleLabel.text;
    self.currentNote.noteBody = self.noteTextView.text;
    self.currentNote.hasNoteStar = [NSNumber numberWithBool:_didSelectStar];
    self.currentNote.isLocalNote = [NSNumber numberWithBool:NO];
    self.currentNote.isDropboxNote = [NSNumber numberWithBool:YES];
    self.currentNote.isiCloudNote = [NSNumber numberWithBool:NO];
    self.currentNote.hasImage = [NSNumber numberWithBool:NO];
    self.currentNote.hasNoteAnnotate = [NSNumber numberWithBool:NO];
    self.currentNote.location = @"";
    
    NSString *newline = @"\n\n";
    NSString *concatenateString = [NSString stringWithFormat:@"%@%@%@%@%@", self.noteTitleLabel.text, newline, self.noteTextView.text, newline, _didSelectStar ? @"YES" : @"NO"];
    self.currentNote.noteAll = concatenateString;
//    NSLog (@"updateNoteDataWithCurrentState > concatenateString: %@\n", concatenateString);
}


- (void)barButtonItemMarkdownPressed:(id)sender
{
    MarkdownWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MarkdownWebViewController"];
    [self updateNoteDataWithCurrentState];                                              //업데이트 노트 데이터
    controller.currentDropboxNote = self.currentNote;
    [self.navigationController pushViewController:controller animated:YES];             //Push
}


- (void)barButtonItemStarredPressed:(id)sender
{
    if (_didSelectStar == NO)
    {
        _didSelectStar = YES;
        self.currentNote.hasNoteStar = [NSNumber numberWithBool:YES];
        
        [YRDropdownView showDropdownInView:self.view coloredTitle:@"Starred" image:nil animated:YES hideAfter:0.2];
        [self performSelector:@selector(updateStarImage) withObject:self afterDelay:0.2];    //툴바 뷰 스타 이미지 업데이트
    }
    else
    {
        _didSelectStar = NO;
        self.currentNote.hasNoteStar = [NSNumber numberWithBool:NO];
        
        [YRDropdownView showDropdownInView:self.view unColoredTitle:@"UnStarred" image:nil animated:YES hideAfter:0.2];
        [self performSelector:@selector(updateStarImage) withObject:self afterDelay:0.2];   //툴바 뷰 스타 이미지 업데이트
    }
}


#pragma mark 스타 이미지 업데이트

- (void)updateStarImage
{
    if ([self.currentNote.hasNoteStar boolValue] == YES)
    {
        self.starImage = nil;
        UIImage *image = [UIImage imageNamed:@"star-256"];
        [self.buttonStar setBackgroundImage:image forState:UIControlStateNormal];
    }
    else
    {
        self.starImage = nil;
        UIImage *image = [UIImage imageNamed:@"star-256-white"];
        [self.buttonStar setBackgroundImage:image forState:UIControlStateNormal];
    }
}


- (void)barButtonItemSharePressed:(id)sender
{
    [self displayDoActionSheet:sender];
}


#pragma mark - Do 액션 sheet (HTML 내보내기, 메일, 기타 공유 등)

#pragma mark Do Action sheet

- (void)displayDoActionSheet:(id)sender
{
    DoActionSheet *vActionSheet = [[DoActionSheet alloc] init];
    [vActionSheet setStyle];
    vActionSheet.dRound = 7;
    vActionSheet.dButtonRound = 3;
    vActionSheet.nAnimationType = 2; //0 > Default, 2 > POP
    vActionSheet.doDimmedColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    vActionSheet.nDestructiveIndex = 5;
    
    [vActionSheet showC:@""
                 cancel:@"Cancel"
                buttons:@[@"Email as HTML", @"Copy as HTML", @"Email as Plain Text", @"Copy as Plain Text", @"More actions as Plain Text...", @"Print Note"]
                 result:^(int nResult)
     {
         switch (nResult)
         {
             case 0:
             {
                 self.htmlString = nil;
                 if ([self.noteTextView.text length] == 0) {
                     self.noteTextView.text = @"> No Contents";
                 } else {
                 }
                 [self createHTMLString];                                                            //HTML 스트링
                 [self sendEmailWithTitle:self.noteTitleLabel.text andBody:self.htmlString];         //메일 컴포즈 컨트롤러
             }
                 break;
             case 1:
             {
                 self.htmlString = nil;
                 if ([self.noteTextView.text length] == 0) {
                     self.noteTextView.text = @"> No Contents";
                 } else {
                 }
                 [self createHTMLString];
                 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                 pasteboard.string = self.htmlString;                                                //Pasteboard Copy
             }
                 break;
             case 2:
             {
                 self.htmlString = nil;
                 if ([self.noteTextView.text length] == 0) {
                     self.noteTextView.text = @"No Contents";
                 } else {
                 }
                 [self sendEmailWithTitle:self.noteTitleLabel.text andBody:self.noteTextView.text];  //메일 컴포즈 컨트롤러
             }
                 break;
             case 3:
             {
                 self.htmlString = nil;
                 if ([self.noteTextView.text length] == 0) {
                     self.noteTextView.text = @"> No Contents";
                 } else {
                 }
                 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                 pasteboard.string = self.noteTextView.text;                                         //Pasteboard Copy
             }
                 break;
             case 4:
             {
                 self.htmlString = nil;
                 if ([self.noteTextView.text length] == 0) {
                     self.noteTextView.text = @"> No Contents";
                 } else {
                 }
                 NSArray *itemsToShare = @[self.noteTextView.text];
                 UIActivityViewController *activityViewController;
                 activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
                 [self presentViewController:activityViewController animated:YES completion:^{
                 }];
             }
                 break;
             case 5:
             {
                 self.htmlString = nil;
                 if ([self.noteTextView.text length] == 0) {
                     self.noteTextView.text = @"> No Contents";
                 } else {
                 }
                 [self createHTMLString];                                                            //HTML 스트링
                 NSString *noteStringForPrint = self.htmlString;
                 [self printNoteAsHTML:noteStringForPrint];                                          //프린트
             }
                 break;
         }
     }];
}


#pragma mark Do Action Sheet 액션

#pragma mark 이메일 공유
#pragma mark 메일 컴포즈 컨트롤러

- (void)sendEmailWithTitle:(NSString *)title andBody:(NSString *)body
{
    //이메일 공유 : email 공유를 위해선 MessageUI 프레임워크가 필요함
    if (![MFMailComposeViewController canSendMail]) {
//        NSLog(@"Can't send email");
        return;
    }
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setSubject:title];
    
    if (self.htmlString) {
        [mailViewController setMessageBody:body isHTML:YES];
    } else {
        [mailViewController setMessageBody:body isHTML:NO];
    }
    
    mailViewController.mailComposeDelegate = self;
    
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
//			NSLog(@"mail composer cancelled");
			break;
		case MFMailComposeResultSaved:
//			NSLog(@"mail composer saved");
			break;
		case MFMailComposeResultSent:
//			NSLog(@"mail composer sent");
			break;
		case MFMailComposeResultFailed:
//			NSLog(@"mail composer failed");
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


#pragma mark - HTML 스트링 Parcing

#pragma mark HTML 스트링

- (NSString *)createHTMLString
{
    NSError *error;
    self.htmlString = [[NSMutableString alloc] init];
    [self.htmlString appendString:[NSString stringWithFormat:@"<html>"
                                   " <head>"
                                   " <meta charset='UTF-8'/>"
                                   " <style> %@ </style>"
                                   " </head> ", [self cssUTF8String]]];
    [self.htmlString appendString:[MMMarkdown HTMLStringWithMarkdown:[self noteString] error:&error]];
    //NSLog (@"HTML 스트링: %@\n", self.htmlString);
    
    return self.htmlString;
}


#pragma mark CSS 스트링

- (NSString *)cssUTF8String
{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"jMarkdown" ofType:@"css"];
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


#pragma mark - 노트 삭제

- (void)deleteNote:(id)sender
{
    NSManagedObject *managedObject = self.currentNote;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    //NSManagedObjectContext *managedObjectContext = [NoteDataManager sharedNoteDataManager].managedObjectContext;
    [managedObjectContext deleteObject:managedObject];
    [managedObjectContext save:nil];
}


#pragma mark - 탭 제스처

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [self.noteTitleLabelBackgroundView addGestureRecognizer:tapGesture];
}


#pragma mark 탭 제스처 > 팝인 노트 타이틀 필드

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    //Create the popin view controller
    NoteTitlePopinViewController *controller = [[NoteTitlePopinViewController alloc] initWithNibName:@"NoteTitlePopinViewController" bundle:nil];
    
    [self updateNoteDataWithCurrentState];                  //업데이트 노트 데이터
    
    //넘겨줄 노트 데이터
//    NSManagedObjectContext *managedObjectContext = [NoteDataManager sharedNoteDataManager].managedObjectContext;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSManagedObjectContext *mainManagedObjectContext = [managedObjectContext parentContext];
    [controller dropboxNote:self.currentNote inManagedObjectContext:mainManagedObjectContext];
    
    //팝인 뷰 속성
    [controller setPopinTransitionStyle:BKTPopinTransitionStyleSlide];  //BKTPopinTransitionStyleSlide, BKTPopinTransitionStyleCrossDissolve
    [controller setPopinOptions:BKTPopinDefault];                               //BKTPopinDefault > Dismissable
    [controller setPopinTransitionDirection:BKTPopinTransitionDirectionTop];    //Set popin transition direction
    [controller setPopinAlignment:BKTPopinAlignementOptionUp];                  //Set popin alignment
    [controller setPopinOptions:[controller popinOptions]|BKTPopinDefault];     //Add option for a blurry background > ex) BKTPopinBlurryDimmingView

    [self.navigationController presentPopinController:controller animated:YES completion:^{ }];
}


#pragma mark - 노티피케이션

#pragma mark 노트 타이틀 변경 노티피케이션 수신 후 후속작업

- (void)didReceiveMessageNoteTitleChanged:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"DidChangeDropboxNoteTitleNotification"])
    {
        NSDictionary *userInfo = notification.userInfo;
        DropboxNote *receivedNote = [userInfo objectForKey:@"changedDropboxNoteKey"];
        self.currentNote = receivedNote;
        if (self.currentNote.noteTitle.length > 0) {
            self.noteTitleLabel.text = self.currentNote.noteTitle;
        }
        else {
            self.noteTitleLabel.text = @"Untitled";
        }
    }
}


#pragma mark 헬프 메시지

- (void)checkToShowHelpMessage
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDIDSHOW_NOTEVIEW_HELP] == YES) {
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDIDSHOW_NOTEVIEW_HELP];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.noteTextView.text = @"\n## Quick Guide\n\n#### Edit\n* To edit title, tap the date.\n* To remove keyboard, tap ▼ key.\n\n#### Preview\n* To preview markdown, tap MD button.\n* Tap anywhere to enter full screen mode\n\n> Thank you for purchasing Clarity.";
        [self barButtonItemMarkdownPressed:self];
    }
}


#pragma mark 헬프 메시지 노티피케이션 수신 후 후속작업

- (void)helpMessageMarkdownWebViewPopped
{
    [self.noteTextView resignFirstResponder];
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


#pragma mark 노트 타이틀 변경 Notification 옵저버 등록

- (void)addObserverForNoteTitleChanged
{
    //노트 타이틀 변경 Notification 옵저버 등록
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNoteTitleChanged:)
                                                 name:@"DidChangeDropboxNoteTitleNotification"
                                               object:nil];
}


#pragma mark HelpMessageMarkdownWebViewPopped Notification 옵저버 등록

- (void)addObserverForHelpMessageMarkdownWebViewPopped
{
    //노트 타이틀 변경 Notification 옵저버 등록
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(helpMessageMarkdownWebViewPopped)
                                                 name:@"HelpMessageMarkdownWebViewPopped"
                                               object:nil];
}


#pragma mark 유저 디폴트 > 현재 뷰 저장

- (void)saveCurrentView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:kCURRENT_VIEW_IS_DROPBOX];                         //현재 뷰
    [standardUserDefaults synchronize];
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
    kLOGBOOL(self.isNewNote);
    kLOGBOOL(self.isSearchResultNote);
    
    kLOGBOOL(self.currentNote.isDropboxNote);
    kLOGBOOL(self.currentNote.isLocalNote);
    kLOGBOOL(self.currentNote.isiCloudNote);
    kLOGBOOL(self.currentNote.hasImage);
    kLOGBOOL(self.currentNote.hasNoteStar);
    kLOGBOOL(self.currentNote.hasNoteAnnotate);
    
    NSLog (@"NSTimeInterval > date: %f\n", self.currentNote.date);
    
    NSLog (@"NSData > imageData: %@\n", self.currentNote.imageData);
    NSLog (@"NSDate > imageCreatedDate: %@\n", self.currentNote.imageCreatedDate);
    NSLog (@"NSDate > noteCreatedDate: %@\n", self.currentNote.noteCreatedDate);
    NSLog (@"NSDate > noteModifiedDate: %@\n", self.currentNote.noteModifiedDate);
    
    NSLog (@"NSNumber > imageUniqueId: %@\n", self.currentNote.imageUniqueId);
    NSLog (@"NSNumber > position: %@\n", self.currentNote.position);
    
    NSLog (@"NSString > sectionName: %@\n", self.currentNote.sectionName);
    NSLog (@"NSString > dateString: %@\n", self.currentNote.dateString);
    NSLog (@"NSString > dayString: %@\n", self.currentNote.dayString);
    NSLog (@"NSString > imageName: %@\n", self.currentNote.imageName);
    NSLog (@"NSString > location: %@\n", self.currentNote.location);
    NSLog (@"NSString > monthString: %@\n", self.currentNote.monthString);
    NSLog (@"NSString > noteAll: %@\n", self.currentNote.noteAll);
    NSLog (@"NSString > noteAnnotate: %@\n", self.currentNote.noteAnnotate);
    NSLog (@"NSString > noteBody: %@\n", self.currentNote.noteBody);
    NSLog (@"NSString > noteSection: %@\n", self.currentNote.noteSection);
    NSLog (@"NSString > noteTitle: %@\n", self.currentNote.noteTitle);
    NSLog (@"NSString > syncID: %@\n", self.currentNote.syncID);
    NSLog (@"NSString > yearString: %@\n", self.currentNote.yearString);
    
    NSLog (@"id > image: %@\n", self.currentNote.image);
}


#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];     //Remove 옵저버
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidChangeLocalNoteTitleNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    NSLog(@"dealloc %@", self);
}


#pragma mark - 메모리 경고

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self saveMethodInvoked];           //메모리 경고 시 코어 데이터 저장
}


#pragma mark - 노트 in Managed Object Context (사용안함)
#pragma mark xib 방식일 때

- (id)initWithNote:(DropboxNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super initWithNibName:@"DropboxAddEditViewController" bundle:nil];
    if (self)
    {
        _currentNote = note;
        _managedObjectContext = managedObjectContext;
    }
    return self;
}


@end
