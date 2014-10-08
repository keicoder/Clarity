//
//  NoteTitlePopinViewController.m
//  SwiftNote
//
//  Created by jun on 2014. 7. 12..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import "NoteTitlePopinViewController.h"
#import "Note.h"
#import "LocalAddEditViewController.h"
#import "DropboxAddEditViewController.h"
#import "UIViewController+MaryPopin.h"


@interface NoteTitlePopinViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UIButton *buttonCancel;
@property (nonatomic, weak) IBOutlet UIButton *buttonSave;

@end


@implementation NoteTitlePopinViewController

#pragma mark - 노트 in Managed Object Context

- (void)note:(Note *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _currentNote = note;
    _managedObjectContext = managedObjectContext;
}


- (void)localNote:(LocalNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _currentLocalNote = note;
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


#pragma mark - 뷰 life cycle

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
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:0.949 green:0.427 blue:0.188 alpha:1]];
    
    if (self.currentNote) {
        self.titleTextField.text = self.currentNote.noteTitle;
    }
    else if (self.currentLocalNote.isLocalNote)
    {
        self.titleTextField.text = self.currentLocalNote.noteTitle;
    }
    [self.titleTextField performSelector:@selector(selectAll:) withObject:self.titleTextField afterDelay:0.f];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.titleTextField becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.titleTextField resignFirstResponder];
    if (self.currentNote.isDropboxNote) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currentNote forKey:@"didChangeNoteTitleKey"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DidChangeNoteTitleNotification" object:nil userInfo:userInfo];
    } else if (self.currentLocalNote.isLocalNote) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currentLocalNote forKey:@"didChangeNoteTitleKey"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DidChangeNoteTitleNotification" object:nil userInfo:userInfo];
    }
}


#pragma mark - 버튼 액션 메소드

- (IBAction)popinButtonCancelPressed:(id)sender
{
    [self dismissView];
}


- (IBAction)popinButtonSavePressed:(id)sender
{
    [self saveMethodInvoked];
}


#pragma mark - Save and Dismiss View

- (void)saveMethodInvoked
{
    if (self.currentNote.isDropboxNote) {
        if ([self.titleTextField.text length] == 0) {
            self.currentNote.noteTitle = @"Untitled";
        } else if ([self.titleTextField.text length] > 0) {
            self.currentNote.noteTitle = self.titleTextField.text;
        }
    } else if (self.currentLocalNote.isLocalNote) {
        if ([self.titleTextField.text length] == 0) {
            self.currentLocalNote.noteTitle = @"Untitled";
        } else if ([self.titleTextField.text length] > 0) {
            self.currentLocalNote.noteTitle = self.titleTextField.text;
        }
    }
    [self dismissView];
}


- (void)dismissView
{
    [self.navigationController dismissCurrentPopinControllerAnimated:YES completion:^{ }];
}


#pragma mark 텍스트 필드 델리게이트

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveMethodInvoked];
    return YES;
}


#pragma mark - deregisterForNotifications

- (void)deregisterForNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"DidChangeNoteTitleNotification" object:nil];
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
    [self saveMethodInvoked];
    [super didReceiveMemoryWarning];
}


@end
