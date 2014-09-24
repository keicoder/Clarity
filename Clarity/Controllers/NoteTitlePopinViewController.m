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
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:0.949 green:0.427 blue:0.188 alpha:1]]; //텍스트 필드 캐럿 색상 변경
    
    if (self.currentNote) {
        self.titleTextField.text = self.currentNote.noteTitle;
    }
    
//    [self.titleTextField performSelector:@selector(selectAll:) withObject:self.titleTextField afterDelay:0.f];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.titleTextField becomeFirstResponder];
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
    if (self.currentNote)
    {
        self.currentNote.noteTitle = self.titleTextField.text;
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currentNote forKey:@"didChangeNoteTitleKey"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DidChangeNoteTitleNotification" object:nil userInfo:userInfo];
    }
    
    [self performSelector:@selector(dismissView:) withObject:self afterDelay:0.1];
}


- (void)dismissView:(id)sender
{
    [self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:^{ }];
}


#pragma mark 텍스트 필드 델리게이트

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveMethodInvoked];
    return YES;
}


#pragma mark - 메모리 경고

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Warning Invoked");
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
