//
//  DropboxNote.m
//  Clarity
//
//  Created by jun on 10/3/14.
//  Copyright (c) 2014 lovejunsoft. All rights reserved.
//

#import "DropboxNote.h"

@interface DropboxNote ()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end


@implementation DropboxNote

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
@dynamic isNewNote;
@dynamic isOtherCloudNote;
@dynamic location;
@dynamic monthAndYearString;
@dynamic monthString;
@dynamic noteAll;
@dynamic noteAnnotate;
@dynamic noteBody;
@dynamic noteCreatedDate;
@dynamic noteModifiedDate;
@dynamic noteSection;
@dynamic noteTitle;
@dynamic position;
@dynamic sectionName;
@dynamic syncID;
@dynamic uniqueNoteIDString;
@dynamic yearString;

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
    [self updateTableCellDateValue];
}


- (void)updateTableCellDateValue
{
    NSDate *now = [NSDate date];
    
    [self.formatter setDateFormat:@"yyyy"];
    NSString *stringYear = [self.formatter stringFromDate:now];
    
    [self.formatter setDateFormat:@"MMM"];
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
    NSString *monthAndYearString = [self.formatter stringFromDate:now];
    self.monthAndYearString = monthAndYearString;
    
    [self.formatter setDateFormat:@"yyyy"];
    NSString *yearString = [self.formatter stringFromDate:now];
    self.sectionName = yearString;
}


@end
