//
//  Note.h
//  Clarity
//
//  Created by jun on 9/17/14.
//  Copyright (c) 2014 lovejunsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSNumber * isOtherCloudNote;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * dateString;
@property (nonatomic, retain) NSString * dayString;
@property (nonatomic, retain) NSNumber * hasImage;
@property (nonatomic, retain) NSNumber * hasNoteAnnotate;
@property (nonatomic, retain) NSNumber * hasNoteStar;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSDate * imageCreatedDate;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSNumber * imageUniqueId;
@property (nonatomic, retain) NSNumber * isDropboxNote;
@property (nonatomic, retain) NSNumber * isiCloudNote;
@property (nonatomic, retain) NSNumber * isLocalNote;
@property (nonatomic, retain) NSNumber * isNewNote;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * monthString;
@property (nonatomic, retain) NSString * noteAll;
@property (nonatomic, retain) NSString * noteAnnotate;
@property (nonatomic, retain) NSString * noteBody;
@property (nonatomic, retain) NSDate * noteCreatedDate;
@property (nonatomic, retain) NSDate * noteModifiedDate;
@property (nonatomic, retain) NSString * noteSection;
@property (nonatomic, retain) NSString * noteTitle;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSString * yearString;
@property (nonatomic, retain) NSString * uniqueNoteIDString;
@property (nonatomic, retain) NSString * monthAndYearString;
- (void)updateTableCellDateValue;

@end
