//
//  WelcomePage.m
//  SwiftNote
//
//  Created by jun on 2014. 6. 26..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import "WelcomePage.h"

@implementation WelcomePage


+ (NSArray *)allPages
{
    WelcomePage *page0 = [[WelcomePage alloc] initWithIndex:0 text:@"Elegance Style View"];     //Elegance style note preview
    WelcomePage *page1 = [[WelcomePage alloc] initWithIndex:1 text:@"Built-in Web"];            //Built-in web browser
    WelcomePage *page2 = [[WelcomePage alloc] initWithIndex:2 text:@"Sync and Share"];          //Support markdown formatting
    WelcomePage *page3 = [[WelcomePage alloc] initWithIndex:3 text:@"Noise-Free Writing"];      //Noise-free Writing
    WelcomePage *page4 = [[WelcomePage alloc] initWithIndex:4 text:@"Support Markdown"];        //Sync and share
    return @[page0, page1, page2, page3, page4];
}


- (instancetype)initWithIndex:(int)index text:(NSString *)text
{
    self = [super init];
    if (self)
    {
        _index = index;
        _text = text;
    }
    return self;
}


- (UIImage *)welcomeImage
{
    if (iPad) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"welcome_iPad%d", self.index + 1]];
    } else {
        return [UIImage imageNamed:[NSString stringWithFormat:@"welcome%d", self.index + 1]];
    }
}


@end
