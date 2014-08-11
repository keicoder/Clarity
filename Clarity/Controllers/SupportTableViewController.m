//
//  SupportTableViewController.m
//  SwiftNote
//
//  Created by jun on 2014. 7. 8..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//


#define kMENU_ICONIMAGE_COLOR    [UIColor colorWithRed:0.686 green:0.682 blue:0.608 alpha:1]    //[UIColor colorWithRed:0.553 green:0.729 blue:0.494 alpha:1]    //[UIColor colorWithRed:0.286 green:0.878 blue:0.796 alpha:1]


#import "SupportTableViewController.h"
#import "AboutViewController.h"                                 //About 뷰
#import "WelcomePageViewController.h"                           //Welcome 뷰
#import "OpenSourceLicencesViewController.h"                    //오픈소스 라이센스
#import "UIImage+ChangeColor.h"                                 //이미지 컬러 변경
#import "SVWebViewController.h"                                 //SV 웹뷰


@interface SupportTableViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *aboutImageView;
@property (nonatomic, weak) IBOutlet UIImageView *welcomeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *opensourceImageView;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) SVWebViewController *svWebViewController; //sv 웹뷰 컨트롤러

@end


@implementation SupportTableViewController


#pragma mark -
#pragma mark 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewAndTableView];           //뷰 및 테이블 뷰 속성
    [self changeColorOfCellImages];             //셀 이미지 색상
    
    self.versionLabel.text = @"Version 1.0\nJuly 31, 2014\nThank you for purchasing Clarity.\nEnjoy Writing!";
}


#pragma mark 뷰 및 테이블 뷰 속성

- (void)configureViewAndTableView
{
    self.title = @"About";
    self.view.backgroundColor = kNAVIGATIONBAR_DROPBOX_LIST_VIEW_BAR_TINT_COLOR;
    self.tableView.backgroundColor = kNAVIGATIONBAR_DROPBOX_LIST_VIEW_BAR_TINT_COLOR;                              //테이블 뷰 배경 색상
    self.tableView.separatorColor = [UIColor colorWithWhite:0.333 alpha:0.300]; //[UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:0.1]; //구분선 색상
}


#pragma mark - 테이블 뷰

#pragma mark 셀 선택

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        AboutViewController *aboutViewController = (AboutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self.navigationController pushViewController:aboutViewController animated:YES];
    }
    else if(indexPath.section == 1 && indexPath.row == 1)
    {
        WelcomePageViewController *welcomePageViewController = (WelcomePageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePageViewController"];
        [self.navigationController pushViewController:welcomePageViewController animated:YES];
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        OpenSourceLicencesViewController *openSourceLicencesViewController = (OpenSourceLicencesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OpenSourceLicencesViewController"];
        [self.navigationController pushViewController:openSourceLicencesViewController animated:YES];
    }
}


#pragma mark - 셀 이미지

- (void)changeColorOfCellImages
{
    UIImage *about = [UIImage imageNameForChangingColor:@"about48" color:kMENU_ICONIMAGE_COLOR];
    UIImage *welcome = [UIImage imageNameForChangingColor:@"welcome48" color:kMENU_ICONIMAGE_COLOR];
    UIImage *openSource = [UIImage imageNameForChangingColor:@"opensource_150" color:kMENU_ICONIMAGE_COLOR];
    
    self.aboutImageView.image = about;
    self.welcomeImageView.image = welcome;
    self.opensourceImageView.image = openSource;
}


#pragma mark 섹션 헤더 속성

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
    [header.textLabel setTextColor:[UIColor whiteColor]];
    header.contentView.backgroundColor =  [UIColor colorWithWhite:0.919 alpha:1.000];
}


#pragma mark 섹션 타이틀

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"", @"");
            break;
        case 1:
            sectionName = NSLocalizedString(@"", @"");
            break;
        case 2:
            sectionName = NSLocalizedString(@"", @"");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


#pragma mark 섹션 헤더 높이

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 0;
            break;
        case 1:
            return 24;
            break;
        case 2:
            return 24;
            break;
        default:
            return 24;
            break;
    }
}


@end
