//
//  BackgroundLayer.h
//  SwiftNote
//
//  Created by jun on 6/18/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface BackgroundLayer : NSObject

+ (CAGradientLayer*) greyGradient;
+ (CAGradientLayer*) blueGradient;
+ (CAGradientLayer*) menuGradient;

@end
