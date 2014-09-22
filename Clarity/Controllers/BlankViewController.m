//
//  BlankViewController.m
//  ClarityHD
//
//  Created by jun on 2014. 8. 24..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import "BlankViewController.h"

@interface BlankViewController ()

@property (nonatomic, strong) IBOutlet UIButton *buttonAdd;

@end

@implementation BlankViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";
    self.view.backgroundColor = kTEXTVIEW_BACKGROUND_COLOR;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 뉴 노트 (노트 추가 Notification 통보)

- (IBAction)buttonAddPressed:(id)sender
{
    [self performSelector:@selector(postAddNewNoteNotification) withObject:self afterDelay:0.0];
}


- (void)postAddNewNoteNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"AddNewNoteNotification" object:nil userInfo:nil];
}


@end
