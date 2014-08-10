//
//  DropboxNote.h
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DropboxNote : NSManagedObject


@property (nonatomic, readonly) NSString *sectionName;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSNumber * hasImage;
@property (nonatomic, retain) NSNumber * hasNoteAnnotate;
@property (nonatomic, retain) NSNumber * hasNoteStar;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSDate * imageCreatedDate;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSNumber * imageUniqueId;
@property (nonatomic, retain) NSString * noteAll;
@property (nonatomic, retain) NSString * noteAnnotate;
@property (nonatomic, retain) NSString * noteBody;
@property (nonatomic, retain) NSDate * noteCreatedDate;
@property (nonatomic, retain) NSDate * noteModifiedDate;
@property (nonatomic, retain) NSString * noteSection;
@property (nonatomic, retain) NSString * noteTitle;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSNumber * isDropboxNote;
@property (nonatomic, retain) NSNumber * isiCloudNote;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * isLocalNote;
@property (nonatomic, retain) NSString * dateString;
@property (nonatomic, retain) NSString * dayString;
@property (nonatomic, retain) NSString * monthString;
@property (nonatomic, retain) NSString * yearString;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


+ (NSUInteger)highestPosition;

- (void)saveNote:(DropboxNote *)aNote;                          //노트 저장
- (void)saveDropboxNote:(DropboxNote *)aNote inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;//노트 저장

- (NSString *)makeTrimmedString:(NSString *)aString;            //공백 문자와 라인 피드문자 삭제
//- (NSString *)getFirstCharacter:(NSString *)aString;            //섹션 타이틀
- (NSAttributedString *)applyLetterPressEffect:(NSString *)aString withColor:(UIColor *)aColor;     //타이틀 레터프레스 효과 적용
//- (NSString *)getFirstLineOfStringForTitle:(NSString *)aString; //첫째 라인만 가져오기


#pragma mark - 유저 디폴트 > 인덱스 저장

- (NSInteger)indexOfSelectedNote;
- (void)setIndexOfSelectedNote:(NSInteger)index;


@end
