//
//  YRDropdownView.h
//  YRDropdownViewExample
//
//  Created by Eli Perkins on 1/27/12.
//  Copyright (c) 2012 One Mighty Roar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface YRDropdownView : UIView
{
    NSString        *titleText;
    NSString        *coloredTitleText;
    NSString        *unColoredTitleText;
    UILabel         *titleLabel;
    UIImage         *__weak accessoryImage;
    UIImageView     *accessoryImageView;
    SEL             onTouch;
    NSDate          *showStarted;
    BOOL            shouldAnimate;
}

@property (copy) NSString           *titleText;
@property (copy) NSString           *coloredTitleText;
@property (copy) NSString           *unColoredTitleText;
@property (weak) UIImage            *accessoryImage;
@property (assign) float            minHeight;
@property (nonatomic, assign) SEL   onTouch;
@property (assign) BOOL             shouldAnimate;


#pragma mark - View methods
+ (YRDropdownView *)showDropdownInView:(UIView *)view title:(NSString *)title image:(UIImage *)image animated:(BOOL)animated hideAfter:(float)delay;
+ (YRDropdownView *)showDropdownInView:(UIView *)view coloredTitle:(NSString *)title image:(UIImage *)image animated:(BOOL)animated hideAfter:(float)delay;
+ (YRDropdownView *)showDropdownInView:(UIView *)view unColoredTitle:(NSString *)title image:(UIImage *)image animated:(BOOL)animated hideAfter:(float)delay;

+ (BOOL)hideDropdownInView:(UIView *)view;
+ (BOOL)hideDropdownInView:(UIView *)view animated:(BOOL)animated;


#pragma mark -

- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end
