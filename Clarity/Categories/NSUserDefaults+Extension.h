//
//  NSUserDefaults+Extension.h
//  SwiftNote
//
//  Created by jun on 2014. 6. 27..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Extension)

- (void)setIndexPath:(NSIndexPath *)value forKey:(NSString *)defaultName;
- (NSIndexPath *)indexPathForKey:(NSString *)defaultName;

@end
