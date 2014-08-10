//
//  AppDelegate.h
//  Clarity
//
//  Created by jun on 8/10/14.
//  Copyright (c) 2014 lovejunsoft. All rights reserved.
//


#define sharedAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])


#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
