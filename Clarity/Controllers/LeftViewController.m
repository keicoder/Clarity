//
//  LeftViewController.m
//  SwiftNote
//
//  Created by jun on 2014. 7. 1..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//


#define kMENU_ICONIMAGE_COLOR    [UIColor colorWithRed:0.686 green:0.682 blue:0.608 alpha:1]


#import "LeftViewController.h"
#import "LeftTableViewCell.h"
#import "UIViewController+JASidePanel.h"
#import "MainSidePanelViewController.h"
#import "DropboxNoteListViewController.h"
#import "LocalNoteListViewController.h"
#import "SupportTableViewController.h"
#import "SVWebViewController.h"
#import "UIImage+ChangeColor.h"
#import "AppDelegate.h"                                         //AppDelegate 참조 > 내비게이션 컨트롤러
#import "DropboxSettingsTableViewController.h"
#import "MarkdownGuideViewController.h"
#import <MessageUI/MessageUI.h>                                 //이메일/메시지 공유
#import "FRLayeredNavigationController/FRLayeredNavigation.h"


@interface LeftViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, FRLayeredNavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *firstSectionArray;
@property (nonatomic, strong) NSArray *secondSectionArray;
@property (nonatomic, strong) NSArray *thirdSectionArray;
@property (nonatomic, strong) NSArray *fourthSectionArray;
@property (nonatomic, strong) NSArray *containerArray;
@property (nonatomic, strong) NSArray *firstSectionImageArray;
@property (nonatomic, strong) NSArray *secondSectionImageArray;
@property (nonatomic, strong) NSArray *thirdSectionImageArray;
@property (nonatomic, strong) NSArray *fourthSectionImageArray;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

@property (strong, nonatomic) SVWebViewController *svWebViewController;//sv 웹뷰 컨트롤러

@end


@implementation LeftViewController

#pragma mark -
#pragma mark 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewAndTableView];                   //테이블 뷰 속성
    [self makeCellDataArray];                           //테이블 데이터
    [self addtitleLabel];                               //타이틀 레이블
    if (iPad) {
        [self chooseWhichViewLocatedInCenterView];
    }
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
    self.firstSectionArray = @[@"Local", @"Dropbox"];
    self.secondSectionArray = @[@"Sync"];
    self.thirdSectionArray = @[@"Markdown Guide"];
    self.fourthSectionArray = @[@"About", @"Website", @"Twitter", @"Send Feedback"];
    
    self.containerArray = @[self.firstSectionArray, self.secondSectionArray, self.thirdSectionArray, self.fourthSectionArray];
    
    //이미지
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
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) { cell.separatorInset = UIEdgeInsetsZero; }
    cell.backgroundColor = kTABLE_VIEW_BACKGROUND_COLOR_LEFTVIEW;
    cell.cellTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    cell.cellTitleLabel.textColor = [UIColor colorWithRed:0.157 green:0.161 blue:0.176 alpha:1];
}


#pragma mark 섹션 헤더 속성

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
    [header.textLabel setTextColor:[UIColor whiteColor]];
    header.contentView.backgroundColor = [UIColor colorWithWhite:0.578 alpha:1.000];
}


#pragma mark 셀 선택

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        LocalNoteListViewController *controller = (LocalNoteListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LocalNoteListViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        if (iPad) {
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:kFRLAYERED_NAVIGATION_ITEM_MAXIMUM_WIDTH animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                layeredNavigationItem.width = kFRLAYERED_NAVIGATION_ITEM_WIDTH_MIDDLE;
                layeredNavigationItem.nextItemDistance = kFRLAYERED_NAVIGATION_ITEM_NEXT_ITEM_DISTANCE;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            self.sidePanelController.centerPanel = navigationController;
        }
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {
        DropboxNoteListViewController *controller = (DropboxNoteListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxNoteListViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        if (iPad) {
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:kFRLAYERED_NAVIGATION_ITEM_MAXIMUM_WIDTH animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                layeredNavigationItem.width = kFRLAYERED_NAVIGATION_ITEM_WIDTH_MIDDLE;
                layeredNavigationItem.nextItemDistance = kFRLAYERED_NAVIGATION_ITEM_NEXT_ITEM_DISTANCE;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            self.sidePanelController.centerPanel = navigationController;
        }
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        DropboxSettingsTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DropboxSettingsTableViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        if (iPad) {
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:NO animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                layeredNavigationItem.width = 320;
                layeredNavigationItem.nextItemDistance = 0;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            self.sidePanelController.centerPanel = navigationController;
        }
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        MarkdownGuideViewController *markdownGuideViewController = (MarkdownGuideViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MarkdownGuideViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:markdownGuideViewController];
        if (iPad) {
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:NO animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                //layeredNavigationItem.width = 320;
                layeredNavigationItem.nextItemDistance = 0;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            self.sidePanelController.centerPanel = navigationController;
        }
    }
    else if(indexPath.section == 3 && indexPath.row == 0)
    {
        SupportTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SupportTableViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        if (iPad) {
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:NO animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                layeredNavigationItem.width = 320;
                layeredNavigationItem.nextItemDistance = 0;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            self.sidePanelController.centerPanel = navigationController;
        }
    }
    else if(indexPath.section == 3 && indexPath.row == 1)
    {
        NSString *URL = @"http://lovejunsoft.com";
        self.svWebViewController = [[SVWebViewController alloc] initWithAddress:URL];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.svWebViewController];
        if (iPad) {
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:NO animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                //layeredNavigationItem.width = 320;
                layeredNavigationItem.nextItemDistance = 0;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            self.sidePanelController.centerPanel = navigationController;
        }
    }
    else if(indexPath.section == 3 && indexPath.row == 2)
    {
        NSString *url = @"https://twitter.com/lovejunsoft";
        self.svWebViewController = [[SVWebViewController alloc] initWithAddress:url];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.svWebViewController];
        if (iPad) {
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:NO animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                //layeredNavigationItem.width = 320;
                layeredNavigationItem.nextItemDistance = 0;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            self.sidePanelController.centerPanel = navigationController;
        }
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
            sectionName = NSLocalizedString(@"Cloud Settings", @"Cloud Settings");
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


#pragma mark - 타이틀 레이블

- (void)addtitleLabel
{
    UIView *customTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.frame = CGRectMake(-((((CGRectGetWidth(self.view.bounds)*kJASIDEPANEL_LEFTGAP_PERCENTAGE)-CGRectGetWidth(titleLabel.bounds))/2)-14), -2, 100, 44);
    [titleLabel setTextColor:[UIColor colorWithWhite:1.000 alpha:0.550]];
    [titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:20]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setNumberOfLines:1];
    [titleLabel setAdjustsFontSizeToFitWidth:NO];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"Clarity"];
    
    [customTitleView addSubview:titleLabel];
    self.navigationItem.titleView = customTitleView;
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


#pragma mark 유저 디폴트 > savedView 확인

- (UINavigationController *)defaultNavigationController
{
    DropboxNoteListViewController *controller = (DropboxNoteListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxNoteListViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    return navigationController;
}


- (void)chooseWhichViewLocatedInCenterView
{
    BOOL isDropboxView = [[NSUserDefaults standardUserDefaults] boolForKey:kCURRENT_VIEW_IS_DROPBOX];
    BOOL isLocalView = [[NSUserDefaults standardUserDefaults] boolForKey:kCURRENT_VIEW_IS_LOCAL];
    
    if (isLocalView == YES && isDropboxView == NO)
    {
        LocalNoteListViewController *controller = (LocalNoteListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LocalNoteListViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:kFRLAYERED_NAVIGATION_ITEM_MAXIMUM_WIDTH animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
            layeredNavigationItem.width = kFRLAYERED_NAVIGATION_ITEM_WIDTH_MIDDLE;
            layeredNavigationItem.nextItemDistance = kFRLAYERED_NAVIGATION_ITEM_NEXT_ITEM_DISTANCE;
            layeredNavigationItem.hasChrome = NO;
            layeredNavigationItem.hasBorder = NO;
            layeredNavigationItem.displayShadow = YES;
        }];
    }
    else if (isLocalView == NO && isDropboxView == YES)
    {
        UINavigationController *navigationController = [self defaultNavigationController];
        [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:kFRLAYERED_NAVIGATION_ITEM_MAXIMUM_WIDTH animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
            layeredNavigationItem.width = kFRLAYERED_NAVIGATION_ITEM_WIDTH_MIDDLE;
            layeredNavigationItem.nextItemDistance = kFRLAYERED_NAVIGATION_ITEM_NEXT_ITEM_DISTANCE;
            layeredNavigationItem.hasChrome = NO;
            layeredNavigationItem.hasBorder = NO;
            layeredNavigationItem.displayShadow = YES;
        }];
    }
    else if (isLocalView == NO && isDropboxView == NO)
    {
        UINavigationController *navigationController = [self defaultNavigationController];
        [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:kFRLAYERED_NAVIGATION_ITEM_MAXIMUM_WIDTH animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
            layeredNavigationItem.width = kFRLAYERED_NAVIGATION_ITEM_WIDTH_MIDDLE;
            layeredNavigationItem.nextItemDistance = kFRLAYERED_NAVIGATION_ITEM_NEXT_ITEM_DISTANCE;
            layeredNavigationItem.hasChrome = NO;
            layeredNavigationItem.hasBorder = NO;
            layeredNavigationItem.displayShadow = YES;
        }];
    }
    else if (isLocalView == YES && isDropboxView == YES)
    {
        UINavigationController *navigationController = [self defaultNavigationController];
        [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:kFRLAYERED_NAVIGATION_ITEM_MAXIMUM_WIDTH animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
            layeredNavigationItem.width = kFRLAYERED_NAVIGATION_ITEM_WIDTH_MIDDLE;
            layeredNavigationItem.nextItemDistance = kFRLAYERED_NAVIGATION_ITEM_NEXT_ITEM_DISTANCE;
            layeredNavigationItem.hasChrome = NO;
            layeredNavigationItem.hasBorder = NO;
            layeredNavigationItem.displayShadow = YES;
        }];
    }
    else
    {
        UINavigationController *navigationController = [self defaultNavigationController];
        [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:kFRLAYERED_NAVIGATION_ITEM_MAXIMUM_WIDTH animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
            layeredNavigationItem.width = kFRLAYERED_NAVIGATION_ITEM_WIDTH_MIDDLE;
            layeredNavigationItem.nextItemDistance = kFRLAYERED_NAVIGATION_ITEM_NEXT_ITEM_DISTANCE;
            layeredNavigationItem.hasChrome = NO;
            layeredNavigationItem.hasBorder = NO;
            layeredNavigationItem.displayShadow = YES;
        }];
    }
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
