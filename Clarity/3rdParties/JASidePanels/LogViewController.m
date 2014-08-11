//
//  LogViewController.m
//  SwiftNote
//
//  Created by jun on 6/5/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController ()

@end

@implementation LogViewController

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    //NSLog(@"%@ viewWillAppear", self);
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    //NSLog(@"%@ viewDidAppear", self);
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
    //NSLog(@"%@ viewWillDisappear", self);
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
    //NSLog(@"%@ viewDidDisappear", self);
}

- (void)willMoveToParentViewController:(UIViewController *)parent 
{
    [super willMoveToParentViewController:parent];
    //NSLog(@"%@ willMoveToParentViewController %@", self, parent);
}

- (void)didMoveToParentViewController:(UIViewController *)parent 
{
    [super didMoveToParentViewController:parent];
    //NSLog(@"%@ didMoveToParentViewController %@", self, parent);
}

@end
