//
//  UIImage+ChangeColor.m
//  SwiftNote
//
//  Created by jun on 2014. 7. 2..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import "UIImage+ChangeColor.h"

@implementation UIImage (ChangeColor)


#pragma mark - 이미지 색상 변경

+ (UIImage *)imageNameForChangingColor:(NSString *)name color:(UIColor *)color
{
	UIImage *image = [UIImage imageNamed:name];
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
	CGContextRef c = UIGraphicsGetCurrentContext();
	[image drawInRect:rect];
	CGContextSetFillColorWithColor(c, [color CGColor]);
	CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
	CGContextFillRect(c, rect);
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	return result;
}


@end
