//
//  NoteTitlePopinViewController.m
//  SwiftNote
//
//  Created by jun on 2014. 7. 12..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import "NoteTitlePopinViewController.h"
#import "LocalNote.h"
#import "DropboxNote.h"
#import "LocalAddEditViewController.h"
#import "DropboxAddEditViewController.h"
#import <MaryPopin/UIViewController+MaryPopin.h>


@interface NoteTitlePopinViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext; //컨텍스트
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UIButton *buttonCancel;
@property (nonatomic, weak) IBOutlet UIButton *buttonSave;

@end


@implementation NoteTitlePopinViewController

#pragma mark - 노트 in Managed Object Context

- (void)localNote:(LocalNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _currentLocalNote = note;
    _managedObjectContext = managedObjectContext;
}


- (void)dropboxNote:(DropboxNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _currentDropboxNote = note;
    _managedObjectContext = managedObjectContext;
}


#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}


#pragma mark -
#pragma mark 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.192 green:0.706 blue:0.643 alpha:1];
    self.titleTextField.backgroundColor = kTEXTVIEW_BACKGROUND_COLOR;
    self.titleTextField.textColor = kTEXTVIEW_TEXT_COLOR;
    self.titleTextField.delegate = self;
    self.titleTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.titleTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    self.titleTextField.placeholder = @"Title";
    self.titleTextField.returnKeyType = UIReturnKeyDone;
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:0.949 green:0.427 blue:0.188 alpha:1]]; //텍스트 필드 캐럿 색상 변경
    
    if (self.currentLocalNote.isLocalNote)
    {
        self.titleTextField.text = self.currentLocalNote.noteTitle;
    }
    else if (self.currentDropboxNote.isDropboxNote)
    {
        self.titleTextField.text = self.currentDropboxNote.noteTitle;
    }
    
    [self.titleTextField performSelector:@selector(selectAll:) withObject:self.titleTextField afterDelay:0.f];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.titleTextField becomeFirstResponder];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.titleTextField setSelectedTextRange:[self.titleTextField textRangeFromPosition:self.titleTextField.beginningOfDocument toPosition:self.titleTextField.endOfDocument]];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.titleTextField resignFirstResponder];
}


#pragma mark - 버튼 액션 메소드

- (IBAction)popinButtonCancelPressed:(id)sender
{
    [self performSelector:@selector(dismissView:) withObject:self afterDelay:0.0];
}


- (IBAction)popinButtonSavePressed:(id)sender
{
    [self saveMethodInvoked];
}


#pragma mark - Save and Dismiss View

- (void)saveMethodInvoked
{
    if (self.currentLocalNote.isLocalNote)
    {
        self.currentLocalNote.noteTitle = self.titleTextField.text;
        
        //타이틀 변경 노티피케이션 통보
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currentLocalNote forKey:@"changedLocalNoteKey"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DidChangeLocalNoteTitleNotification" object:nil userInfo:userInfo];
    }
    else if (self.currentDropboxNote.isDropboxNote)
    {
        self.currentDropboxNote.noteTitle = self.titleTextField.text;
        
        //타이틀 변경 노티피케이션 통보
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currentDropboxNote forKey:@"changedDropboxNoteKey"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DidChangeDropboxNoteTitleNotification" object:nil userInfo:userInfo];
    }
    
    [self performSelector:@selector(dismissView:) withObject:self afterDelay:0.1];
}


- (void)dismissView:(id)sender
{
    [self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:^{ }];
}


#pragma mark 텍스트 필드 델리게이트 > 텍스트 선택

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveMethodInvoked];
    return YES;
}


#pragma mark - 메모리 경고

- (void)didReceiveMemoryWarning
{
    if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Warning Invoked");
}


@end
