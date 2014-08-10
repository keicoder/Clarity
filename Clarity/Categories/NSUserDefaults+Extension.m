//
//  NSUserDefaults+Extension.m
//  SwiftNote
//
//  Created by jun on 2014. 6. 27..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import "NSUserDefaults+Extension.h"

@implementation NSUserDefaults (Extension)


- (void)setIndexPath:(NSIndexPath *)value forKey:(NSString *)defaultName
{
    [self setObject:@{@"row": @(value.row),
                      @"section": @(value.section)}
             forKey:defaultName];
}


- (NSIndexPath *)indexPathForKey:(NSString *)defaultName
{
    NSDictionary *dict = [self objectForKey:defaultName];
    return [NSIndexPath indexPathForRow:[dict[@"row"] integerValue]
                              inSection:[dict[@"section"] integerValue]];
}


@end
