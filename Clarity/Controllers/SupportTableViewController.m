//
//  SupportTableViewController.m
//  SwiftNote
//
//  Created by jun on 2014. 7. 8..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//


#define kMENU_ICONIMAGE_COLOR    [UIColor colorWithRed:0.686 green:0.682 blue:0.608 alpha:1]    //[UIColor colorWithRed:0.553 green:0.729 blue:0.494 alpha:1]    //[UIColor colorWithRed:0.286 green:0.878 blue:0.796 alpha:1]


#import "SupportTableViewController.h"
#import "AboutViewController.h"
#import "WelcomePageViewController.h"
#import "OpenSourceLicencesViewController.h"
#import "UIImage+ChangeColor.h"
#import "FRLayeredNavigationController/FRLayeredNavigation.h"


@interface SupportTableViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *aboutImageView;
@property (nonatomic, weak) IBOutlet UIImageView *welcomeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *opensourceImageView;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

@end


@implementation SupportTableViewController


#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewAndTableView];
    [self changeColorOfCellImages];
    
    NSString *versionString = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSString *buildNumberString = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@ (Build %@)\nNovember 17, 2014\nThank you for purchasing Clarity.\nEnjoy Writing!", versionString, buildNumberString];
}


#pragma mark 뷰 및 테이블 뷰 속성

- (void)configureViewAndTableView
{
    self.view.backgroundColor = kNAVIGATIONBAR_DROPBOX_LIST_VIEW_BAR_TINT_COLOR;
    self.tableView.backgroundColor = kNAVIGATIONBAR_DROPBOX_LIST_VIEW_BAR_TINT_COLOR;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.333 alpha:0.300];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"About";
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @"";
}


#pragma mark - 테이블 뷰

#pragma mark 셀 선택

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        AboutViewController *aboutViewController = (AboutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        
        if (iPad) {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
            
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:YES animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                layeredNavigationItem.nextItemDistance = 0;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            [self.navigationController pushViewController:aboutViewController animated:YES];
        }
    }
    else if(indexPath.section == 1 && indexPath.row == 1)
    {
        WelcomePageViewController *welcomePageViewController = (WelcomePageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePageViewController"];
        
        if (iPad) {
            [self.navigationController presentViewController:welcomePageViewController animated:YES completion:nil];
        } else {
            [self.navigationController pushViewController:welcomePageViewController animated:YES];
        }
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        OpenSourceLicencesViewController *openSourceLicencesViewController = (OpenSourceLicencesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OpenSourceLicencesViewController"];
        
        if (iPad) {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:openSourceLicencesViewController];
            
            [self.layeredNavigationController pushViewController:navigationController inFrontOf:self.navigationController maximumWidth:YES animated:YES configuration:^(FRLayeredNavigationItem *layeredNavigationItem) {
                layeredNavigationItem.nextItemDistance = 0;                 //레이어가 가려질 거리;
                layeredNavigationItem.hasChrome = NO;
                layeredNavigationItem.hasBorder = NO;
                layeredNavigationItem.displayShadow = YES;
            }];
        } else {
            [self.navigationController pushViewController:openSourceLicencesViewController animated:YES];
        }
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
            return 29;
            break;
        case 2:
            return 29;
            break;
        default:
            return 29;
            break;
    }
}


@end
