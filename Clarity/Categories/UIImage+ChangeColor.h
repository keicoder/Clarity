//
//  UIImage+ChangeColor.h
//  SwiftNote
//
//  Created by jun on 2014. 7. 2..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ChangeColor)

+ (UIImage *)imageNameForChangingColor:(NSString *)name color:(UIColor *)color;    //usage: UIImage *buttonImage = [UIImage ipMaskedImageNamed:@"UIButtonBarAction.png" color:[UIColor redColor]];

@end
