//
//  LeftViewController.m
//  SwiftNote
//
//  Created by jun on 2014. 7. 1..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//


#define kMENU_ICONIMAGE_COLOR    [UIColor colorWithRed:0.686 green:0.682 blue:0.608 alpha:1]


#import "LeftViewController.h"
#import "LeftTableViewCell.h"                                   //커스텀 셀
#import "UIViewController+JASidePanel.h"
#import "MainSidePanelViewController.h"
#import "DropboxNoteListViewController.h"
#import "LocalNoteListViewController.h"
#import "SupportTableViewController.h"                          //Support 테이블 뷰 컨틀롤러
#import "SVWebViewController.h"                                 //SV 웹뷰
#import "UIImage+ChangeColor.h"                                 //이미지 컬러 변경
#import "AppDelegate.h"                                         //AppDelegate 참조 > 내비게이션 컨트롤러
#import "DropboxSettingsTableViewController.h"                  //드랍박스 링크 셋팅
#import "MarkdownGuideViewController.h"                         //마크다운 Syntax 가이드 뷰
#import <MessageUI/MessageUI.h>                                 //이메일/메시지 공유


@interface LeftViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) NSArray *firstSectionArray;
@property (nonatomic, strong) NSArray *secondSectionArray;
@property (nonatomic, strong) NSArray *thirdSectionArray;
@property (nonatomic, strong) NSArray *fourthSectionArray;
@property (nonatomic, strong) NSArray *containerArray;
@property (nonatomic, strong) NSArray *firstSectionImageArray;
@property (nonatomic, strong) NSArray *secondSectionImageArray;
@property (nonatomic, strong) NSArray *thirdSectionImageArray;
@property (nonatomic, strong) NSArray *fourthSectionImageArray;

@property (strong, nonatomic) SVWebViewController *svWebViewController;//sv 웹뷰 컨트롤러

@end


@implementation LeftViewController

#pragma mark -
#pragma mark 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configureViewAndTableView];                   //테이블 뷰 속성
    [self makeCellDataArray];                           //테이블 데이터
    self.versionLabel.text = @"2014 lovejunsoft";

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showStatusBar];
    [self showNavigationBar];
}


#pragma mark - 데이터

- (void)makeCellDataArray
{
    //스트링
    self.firstSectionArray = @[@"iPhone", @"Dropbox"];
    self.secondSectionArray = @[@"Sync"];
    self.thirdSectionArray = @[@"Markdown Guide"];
    self.fourthSectionArray = @[@"About", @"Website", @"Twitter", @"Send Feedback"];
    
    self.containerArray = @[self.firstSectionArray, self.secondSectionArray, self.thirdSectionArray, self.fourthSectionArray];
    
    //이미지 > 색상 변경
    UIImage *mobile = [UIImage imageNameForChangingColor:@"mobile" color:kMENU_ICONIMAGE_COLOR];
    UIImage *dropbox = [UIImage imageNameForChangingColor:@"dropbox" color:kMENU_ICONIMAGE_COLOR];
    self.firstSectionImageArray = @[mobile, dropbox]; //[NSArray arrayWithObjects:mobile, dropbox, nil];
    
    UIImage *sync = [UIImage imageNameForChangingColor:@"sync48" color:kMENU_ICONIMAGE_COLOR];
    self.secondSectionImageArray = @[sync];
    
    UIImage *mdGuide = [UIImage imageNameForChangingColor:@"help256" color:kMENU_ICONIMAGE_COLOR];
    self.thirdSectionImageArray = @[mdGuide];
    
    UIImage *support = [UIImage imageNameForChangingColor:@"about48" color:kMENU_ICONIMAGE_COLOR];
    self.fourthSectionImageArray = @[support];
    UIImage *web = [UIImage imageNameForChangingColor:@"web128" color:kMENU_ICONIMAGE_COLOR];
    UIImage *twitter = [UIImage imageNameForChangingColor:@"twitter256" color:kMENU_ICONIMAGE_COLOR];
    UIImage *sendFeedback = [UIImage imageNameForChangingColor:@"icn_email48" color:kMENU_ICONIMAGE_COLOR];
    self.fourthSectionImageArray = @[support, web, twitter, sendFeedback];
}


#pragma mark - 테이블 뷰
#pragma mark 뷰 및 테이블 뷰 속성

- (void)configureViewAndTableView
{
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = kTOOLBAR_DROPBOX_LIST_VIEW_BACKGROUND_COLOR;          //뷰
    self.tableView.backgroundColor = kCLEAR_COLOR;                                    //테이블 뷰 배경 색상
    self.tableView.separatorColor = [UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:0.1]; //구분선 색상
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


#pragma mark 데이터 소스
#pragma mark 섹션 갯수

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.containerArray count];
}


#pragma mark 셀 갯수

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return self.firstSectionArray.count;
            break;
        case 1:
            return self.secondSectionArray.count;
            break;
        case 2:
            return self.thirdSectionArray.count;
            break;
        case 3:
            return self.fourthSectionArray.count;
            break;
        default:
            return 1;
            break;
    }
}


#pragma mark 셀

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    LeftTableViewCell *cell = (LeftTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = (LeftTableViewCell *) [[[NSBundle mainBundle] loadNibNamed:@"LeftTableViewCell" owner:self options:nil] lastObject];
    }
    if (indexPath.section == 0)
    {
        cell.cellTitleLabel.text = self.firstSectionArray[indexPath.row];
        cell.logoImageView.image = self.firstSectionImageArray[indexPath.row];
    }
    else if(indexPath.section == 1)
    {
        cell.cellTitleLabel.text = self.secondSectionArray[indexPath.row];
        cell.logoImageView.image = self.secondSectionImageArray[indexPath.row];
        cell.logoImageView.frame = CGRectMake(18, 18, 25, 25);
    }
    else if(indexPath.section == 2)
    {
        cell.cellTitleLabel.text = self.thirdSectionArray[indexPath.row];
        cell.logoImageView.image = self.thirdSectionImageArray[indexPath.row];
    }
    else if(indexPath.section == 3)
    {
        cell.cellTitleLabel.text = self.fourthSectionArray[indexPath.row];
        cell.logoImageView.image = self.fourthSectionImageArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.logoImageView.frame = CGRectMake(19, 19, 24, 24);
        }
        else if (indexPath.row ==2) {
            cell.logoImageView.frame = CGRectMake(19, 19, 24, 24);
        }
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark 셀 속성

- (void)configureCell:(LeftTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //셀 속성
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) { cell.separatorInset = UIEdgeInsetsZero; }
    cell.backgroundColor = kTABLE_VIEW_BACKGROUND_COLOR_LEFTVIEW;                                   //데이 모드
    //cell.backgroundColor = [UIColor colorWithWhite:0.318 alpha:1.000];                            //나이트 모드
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.cellTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    cell.cellTitleLabel.textColor = [UIColor colorWithRed:0.157 green:0.161 blue:0.176 alpha:1];    //데이 모드
    //cell.cellTitleLabel.textColor = kWHITE_COLOR;                                                 //나이트 모드
}


#pragma mark 섹션 헤더 속성

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
    [header.textLabel setTextColor:[UIColor whiteColor]];
    header.contentView.backgroundColor = [UIColor colorWithWhite:0.578 alpha:1.000];                //데이 모드
    //header.contentView.backgroundColor = [UIColor colorWithWhite:0.379 alpha:1.000];              //나이트 모드
}


#pragma mark 셀 선택

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        self.sidePanelController.centerPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalNoteListViewNavigationController"];
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {
        self.sidePanelController.centerPanel = [self.storyboard instantiateViewControllerWithIdentifier:@"DropboxNoteListViewNavigationController"];
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        DropboxSettingsTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DropboxSettingsTableViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        self.sidePanelController.centerPanel = navigationController;
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        MarkdownGuideViewController *markdownGuideViewController = (MarkdownGuideViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MarkdownGuideViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:markdownGuideViewController];
        self.sidePanelController.centerPanel = navigationController;
    }
    else if(indexPath.section == 3 && indexPath.row == 0)
    {
        SupportTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SupportTableViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        self.sidePanelController.centerPanel = navigationController;
        
    }
    else if(indexPath.section == 3 && indexPath.row == 1)
    {
        NSString *URL = @"http://lovejunsoft.com";
        self.svWebViewController = [[SVWebViewController alloc] initWithAddress:URL];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.svWebViewController];
        self.sidePanelController.centerPanel = navigationController;
    }
    else if(indexPath.section == 3 && indexPath.row == 2)
    {
        NSString *url = @"https://twitter.com/lovejunsoft";   //https://twitter.com/lovejunsoft, http://lovejunsoft.com/swift-note-for-iphone/
        self.svWebViewController = [[SVWebViewController alloc] initWithAddress:url];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.svWebViewController];
        self.sidePanelController.centerPanel = navigationController;
    }
    else if(indexPath.section == 3 && indexPath.row == 3)
    {
        [self sendFeedbackEmail];
    }
}


#pragma mark 델리게이트 메소드

#pragma mark 섹션 타이틀

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Storage", @"Storage");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Cloud Settings", @"Cloud");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Guide", @"Guide");
            break;
        case 3:
            sectionName = NSLocalizedString(@"Clarity", @"Clarity");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


#pragma mark 셀 높이

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}


#pragma mark 섹션 헤더 높이

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 29;
}


#pragma mark - 로고 뷰

- (void)addMenuLogoImageView
{
    //100 by 100
    float logoImageViewLeftGapPercentage = 0.3;
    CGFloat leftViewWidth = CGRectGetWidth(self.view.bounds) * logoImageViewLeftGapPercentage;
    CGFloat imageViewWidth = CGRectGetWidth(self.logoImageView.bounds);
    CGFloat imageViewHeight = CGRectGetHeight(self.logoImageView.bounds);
    CGFloat imageOriginY = 82;
    self.logoImageView.frame = CGRectMake((leftViewWidth - imageViewWidth) / 2, imageOriginY, imageViewWidth, imageViewHeight);
}


#pragma mark 이메일 공유
#pragma mark 메일 컴포즈 컨트롤러

- (void)sendFeedbackEmail
{
    if (![MFMailComposeViewController canSendMail]) //이메일 공유 : email 공유를 위해선 MessageUI 프레임워크가 필요함
    {
        NSLog(@"Can't send email");
        return;
    }
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    
    [mailViewController setToRecipients:@[@"lovejun.soft@gmail.com"]];              //Set params
    [mailViewController setSubject:NSLocalizedString(@"Clarity iOS Feedback", @"Clarity iOS Feedback")];
    [mailViewController setMessageBody:NSLocalizedString(@"\n\n\n\n----\nClarity iOS\n", @"\n\n\n\n----\nClarity iOS\n") isHTML:NO];
    
    [self presentViewController:mailViewController animated:YES completion:^{
    }];
}


#pragma mark 델리게이트 메소드 (MFMailComposeViewControllerDelegate)

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"mail composer cancelled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"mail composer saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"mail composer sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"mail composer failed");
			break;
	}
    [controller dismissViewControllerAnimated:YES completion:^{
        
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
}


- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
