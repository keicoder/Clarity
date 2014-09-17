//
//  LocalNote.m
//  Clarity
//
//  Created by jun on 9/17/14.
//  Copyright (c) 2014 lovejunsoft. All rights reserved.
//

#import "LocalNote.h"

@interface LocalNote ()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end


@implementation LocalNote

@dynamic date;
@dynamic dateString;
@dynamic dayString;
@dynamic hasImage;
@dynamic hasNoteAnnotate;
@dynamic hasNoteStar;
@dynamic image;
@dynamic imageCreatedDate;
@dynamic imageData;
@dynamic imageName;
@dynamic imageUniqueId;
@dynamic isDropboxNote;
@dynamic isiCloudNote;
@dynamic isLocalNote;
@dynamic location;
@dynamic monthString;
@dynamic noteAll;
@dynamic noteAnnotate;
@dynamic noteBody;
@dynamic noteCreatedDate;
@dynamic noteModifiedDate;
@dynamic noteSection;
@dynamic noteTitle;
@dynamic position;
@dynamic syncID;
@dynamic yearString;
@dynamic isOtherCloudNote;
@dynamic isNewNote;
@dynamic sectionName;

@synthesize formatter = _formatter;


#pragma mark 데이트 Formatter

- (NSDateFormatter *)formatter
{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
    }
    return _formatter;
}


#pragma mark awakeFromInsert

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    NSDate *now = [NSDate date];
    
    [self.formatter setDateFormat:@"yyyy"];
    NSString *stringYear = [self.formatter stringFromDate:now];
    
    [self.formatter setDateFormat:@"M"];
    NSString *stringMonth = [self.formatter stringFromDate:now];
    
    [self.formatter setDateFormat:@"dd"];
    NSString *stringDay = [self.formatter stringFromDate:now];
    
    [self.formatter setDateFormat:@"EEEE"];
    NSString *stringDate = [self.formatter stringFromDate:now];
    NSString *stringdaysOfTheWeek = [[stringDate substringToIndex:3] uppercaseString];
    
    self.yearString = stringYear;
    self.monthString = stringMonth;
    self.dayString = stringDay;
    self.dateString = stringdaysOfTheWeek;
    
    [self.formatter setDateFormat:@"MMM yyyy"];
    NSString *sectionName = [self.formatter stringFromDate:now];
    self.sectionName = sectionName;
}


@end
