//
//  UIImage+MakeThumbnail.m
//  SwiftNote
//
//  Created by jun on 5/16/14.
//  Copyright (c) 2014 jun. All rights reserved.
//

#import "UIImage+MakeThumbnail.h"

@implementation UIImage (MakeThumbnail)

- (UIImage *)makeThumbnailOfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();        
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil) 
        NSLog(@"could not scale image");
    return newThumbnail;
}

@end
