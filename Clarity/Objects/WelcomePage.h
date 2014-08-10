//
//  WelcomePage.h
//  SwiftNote
//
//  Created by jun on 2014. 6. 26..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WelcomePage : NSObject

@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSString *text;

+ (NSArray *)allPages;

- (instancetype)initWithIndex:(int)index text:(NSString *)text;
- (UIImage *)welcomeImage;


@end
