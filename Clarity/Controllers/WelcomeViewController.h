//
//  WelcomeViewController.h
//  SwiftNote
//
//  Created by jun on 2014. 6. 26..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WelcomePage;


@interface WelcomeViewController : UIViewController

@property (nonatomic, strong) WelcomePage *welcomePage;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end
