//
//  YRDropdownView.m
//  YRDropdownViewExample
//
//  Created by Eli Perkins on 1/27/12.
//  Copyright (c) 2012 One Mighty Roar. All rights reserved.
//

#import "YRDropdownView.h"
#import <QuartzCore/QuartzCore.h>


#define kVIEW_BACKGROUND_COLOR  kTOOLBAR_DROPBOX_LIST_VIEW_BACKGROUND_COLOR //[UIColor colorWithRed:0.686 green:0.322 blue:0.263 alpha:1]
#define kCOLORED_TEXT_COLOR     [UIColor colorWithRed:0.953 green:0.784 blue:0.471 alpha:1] //[UIColor colorWithRed:0.753 green:0.757 blue:0.6 alpha:1], [UIColor colorWithRed:0.898 green:0.894 blue:0.835 alpha:1]

#define kMIN_HEIGHT             44
#define kMIN_WIDTH              140
#define kLAYER_CORNER_RADIUS    7

#define kDROPDOWNHEIGHT         110

#define kTITLELABEL_FONT        @"Avenir-Heavy"   //@"AvenirNextCondensed-Bold", @"AvenirNextCondensed-Medium"
#define kTITLELABEL_FONT_SIZE   20
//#define kTITLELABEL_ORIGIN_Y    10

#define kANIMATION_DURATION     0.3f


@interface YRDropdownView ()

- (void)updateTitleLabel:(NSString *)newText;
- (void)updateTitleLabelColored:(NSString *)newText;
- (void)updateTitleLabelUnColored:(NSString *)newText;
- (void)hideUsingAnimation:(NSNumber *)animated;
- (void)done;

@end


@implementation YRDropdownView

@synthesize accessoryImage;
@synthesize onTouch;
@synthesize shouldAnimate;


static YRDropdownView *currentDropdown = nil;

+ (YRDropdownView *)currentDropdownView
{
    return currentDropdown;
}


#pragma mark - Accessors

- (NSString *)titleText
{
    return titleText;
}


- (NSString *)coloredTitleText
{
    return titleText;
}


- (NSString *)unColoredTitleText
{
    return titleText;
}


- (void)setTitleText:(NSString *)newText
{
    if ([NSThread isMainThread])
    {
		[self updateTitleLabel:newText];
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
    else
    {
		[self performSelectorOnMainThread:@selector(updateTitleLabel:) withObject:newText waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
	}
}


- (void)setColoredTitleText:(NSString *)newText
{
    if ([NSThread isMainThread])
    {
		[self updateTitleLabelColored:newText];
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
    else
    {
		[self performSelectorOnMainThread:@selector(updateTitleLabelColored:) withObject:newText waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
	}
}


- (void)setUnColoredTitleText:(NSString *)newText
{
    if ([NSThread isMainThread])
    {
		[self updateTitleLabelUnColored:newText];
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
    else
    {
		[self performSelectorOnMainThread:@selector(updateTitleLabelUnColored:) withObject:newText waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
	}
}


- (void)updateTitleLabel:(NSString *)newText
{
    if (titleText != newText)
    {
        titleText = [newText copy];
        titleLabel.text = titleText;
        titleLabel.textColor = [UIColor whiteColor];
    }
}


- (void)updateTitleLabelColored:(NSString *)newText
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    if (coloredTitleText != newText)
    {
        titleText = [newText copy];
        titleLabel.text = titleText;
        titleLabel.textColor = kCOLORED_TEXT_COLOR;
    }
}


- (void)updateTitleLabelUnColored:(NSString *)newText
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    if (unColoredTitleText != newText)
    {
        titleText = [newText copy];
        titleLabel.text = titleText;
        titleLabel.textColor = [UIColor whiteColor];
    }
}


#pragma mark - Initializers

- (id)init
{
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, kMIN_WIDTH, kMIN_HEIGHT)];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleText = nil;
        self.minHeight = kMIN_HEIGHT;
        self.backgroundColor = kVIEW_BACKGROUND_COLOR;
       
        titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        accessoryImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        self.opaque = YES;
        
        onTouch = @selector(hide:);
    }
    return self;
}


#pragma mark - Class methods

#pragma mark View Methods

+ (YRDropdownView *)showDropdownInView:(UIView *)view title:(NSString *)title image:(UIImage *)image animated:(BOOL)animated hideAfter:(float)delay
{
    if (currentDropdown)
    {
        [currentDropdown hideUsingAnimation:@(animated)];
    }
    
    YRDropdownView *dropdown = [[YRDropdownView alloc] initWithFrame:CGRectMake(0, 0, kMIN_WIDTH, kMIN_HEIGHT)];
    [dropdown setFrame:(
                        {
                            CGRect frame = dropdown.frame;
                            frame.origin.x = (view.bounds.size.width - frame.size.width) / 2;
                            frame.origin.y = 0; //(view.bounds.size.height - frame.size.height) / 1.1;;
                            CGRectIntegral(frame);
                        })];
    
    currentDropdown = dropdown;
    dropdown.titleText = title;
    
    if (image)
    {
        dropdown.accessoryImage = image;
    }
    
    dropdown.shouldAnimate = animated;
    
    if ([view isKindOfClass:[UIWindow class]])
    {
        CGRect dropdownFrame = dropdown.frame;
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        dropdownFrame.origin.y = appFrame.origin.y;
        dropdown.frame = dropdownFrame;
    }
    
    [view addSubview:dropdown];
    [dropdown show:animated];
    
    if (delay != 0.0)
    {
        [dropdown performSelector:@selector(hideUsingAnimation:) withObject:@(animated) afterDelay:delay+kANIMATION_DURATION];
    }
    
    return dropdown;
}


+ (YRDropdownView *)showDropdownInView:(UIView *)view coloredTitle:(NSString *)title image:(UIImage *)image animated:(BOOL)animated hideAfter:(float)delay
{
    if (currentDropdown)
    {
        [currentDropdown hideUsingAnimation:@(animated)];
    }
    
    YRDropdownView *dropdown = [[YRDropdownView alloc] initWithFrame:CGRectMake(0, 0, kMIN_WIDTH, kMIN_HEIGHT)];
    [dropdown setFrame:(
    {
        CGRect frame = dropdown.frame;
        frame.origin.x = (view.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = 0; //(view.bounds.size.height - frame.size.height) / 1.1;;
        CGRectIntegral(frame);
    })];
    
    currentDropdown = dropdown;
    dropdown.coloredTitleText = title;
    
    if (image)
    {
        dropdown.accessoryImage = image;
    }
    
    dropdown.shouldAnimate = animated;
    
    if ([view isKindOfClass:[UIWindow class]])
    {
        CGRect dropdownFrame = dropdown.frame;
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        dropdownFrame.origin.y = appFrame.origin.y;
        dropdown.frame = dropdownFrame;
    }

    [view addSubview:dropdown];
    [dropdown show:animated];
    
    if (delay != 0.0)
    {
        [dropdown performSelector:@selector(hideUsingAnimation:) withObject:@(animated) afterDelay:delay+kANIMATION_DURATION];
    }

    return dropdown;
}


+ (YRDropdownView *)showDropdownInView:(UIView *)view unColoredTitle:(NSString *)title image:(UIImage *)image animated:(BOOL)animated hideAfter:(float)delay
{
    if (currentDropdown)
    {
        [currentDropdown hideUsingAnimation:@(animated)];
    }
    
    YRDropdownView *dropdown = [[YRDropdownView alloc] initWithFrame:CGRectMake(0, 0, kMIN_WIDTH, kMIN_HEIGHT)];
    [dropdown setFrame:(
                        {
                            CGRect frame = dropdown.frame;
                            frame.origin.x = (view.bounds.size.width - frame.size.width) / 2;
                            frame.origin.y = 0; //(view.bounds.size.height - frame.size.height) / 1.1;;
                            CGRectIntegral(frame);
                        })];
    
    currentDropdown = dropdown;
    dropdown.unColoredTitleText = title;
    
    if (image)
    {
        dropdown.accessoryImage = image;
    }
    
    dropdown.shouldAnimate = animated;
    
    if ([view isKindOfClass:[UIWindow class]])
    {
        CGRect dropdownFrame = dropdown.frame;
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        dropdownFrame.origin.y = appFrame.origin.y;
        dropdown.frame = dropdownFrame;
    }
    
    [view addSubview:dropdown];
    [dropdown show:animated];
    
    if (delay != 0.0)
    {
        [dropdown performSelector:@selector(hideUsingAnimation:) withObject:@(animated) afterDelay:delay+kANIMATION_DURATION];
    }
    
    return dropdown;
}


+ (void)removeView 
{
    if (!currentDropdown) {
        return;
    }
    
    [currentDropdown removeFromSuperview];
    
    currentDropdown = nil;
}


+ (BOOL)hideDropdownInView:(UIView *)view
{
    return [YRDropdownView hideDropdownInView:view animated:YES];
}


+ (BOOL)hideDropdownInView:(UIView *)view animated:(BOOL)animated
{
    if (currentDropdown)
    {
        [currentDropdown hideUsingAnimation:@(animated)];
        return YES;
    }
    
    UIView *viewToRemove = nil;
    
    for (UIView *v in [view subviews])
    {
        if ([v isKindOfClass:[YRDropdownView class]])
        {
            viewToRemove = v;
        }
    }
    if (viewToRemove != nil)
    {
        YRDropdownView *dropdown = (YRDropdownView *)viewToRemove;
        [dropdown hideUsingAnimation:@(animated)];
        return YES;
    }
    else
    {
        return NO;
    }
}


#pragma mark - Methods

- (void)show:(BOOL)animated
{
    if(animated)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
        self.alpha = 0.01;
        [UIView animateWithDuration:kANIMATION_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 1.0;
                             self.frame = CGRectMake(self.frame.origin.x, 
                                                     self.frame.origin.y + self.frame.size.height,
                                                     self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 
                             }
                         }];
    }
}


- (void)hide:(BOOL)animated
{
    [self done];
}


- (void)hideUsingAnimation:(NSNumber *)animated
{
    if ([animated boolValue])
    {
        [UIView animateWithDuration:kANIMATION_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 0.5;
                             self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self done];
                             }
                         }];        
    }
    else
    {
        self.alpha = 0.0f;
        [self done];
    }
}



- (void)done
{
    [self removeFromSuperview];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideUsingAnimation:@(self.shouldAnimate)];
}



#pragma mark - Layout

- (void)layoutSubviews
{
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, kDROPDOWNHEIGHT)];
    self.layer.cornerRadius = kLAYER_CORNER_RADIUS;
    
    // Set label properties
    titleLabel.font = [UIFont fontWithName:kTITLELABEL_FONT size:kTITLELABEL_FONT_SIZE];
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.opaque = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.titleText;
    titleLabel.frame = CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, titleLabel.frame.size.height);
    [titleLabel setFrame:({
        CGRect frame = titleLabel.frame;
        frame.origin.x = self.bounds.origin.x;
        frame.origin.y = (self.frame.size.height + 60 - frame.size.height) / 2;
        CGRectIntegral(frame);
    })];
    [self addSubview:titleLabel];
    
//    if (self.accessoryImage) {
//        accessoryImageView.image = self.accessoryImage;
//        accessoryImageView.frame = CGRectMake(self.bounds.origin.x + HORIZONTAL_PADDING, 
//                                              self.bounds.origin.y + VERTICAL_PADDING,
//                                              self.accessoryImage.size.width,
//                                              self.accessoryImage.size.height);
//        
//        [titleLabel sizeToFitFixedWidth:self.bounds.size.width - IMAGE_PADDING - (HORIZONTAL_PADDING * 2)];
//        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x + IMAGE_PADDING, 
//                                      titleLabel.frame.origin.y, 
//                                      titleLabel.frame.size.width, 
//                                      titleLabel.frame.size.height);
//        
//        
//        [self addSubview:accessoryImageView];
//    }
    
    
}


@end