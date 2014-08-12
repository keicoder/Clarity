//
//  LocalNote.m
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//


#import "LocalNote.h"
#import "NoteDataManager.h"

@interface LocalNote ()

@property (nonatomic, strong) NSDateFormatter *formatter;                   //데이트 Formatter

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
@dynamic isLocalNote;
@dynamic isiCloudNote;
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

@synthesize managedObjectContext = _managedObjectContext;
@synthesize formatter = _formatter;


#pragma mark - 퍼블릭 메소드
#pragma mark 노트 포지션

+ (NSUInteger)highestPosition
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LocalNote"];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:NO]]];
    LocalNote *note = [[[NoteDataManager sharedNoteDataManager].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    
//    NSLog (@"LocalNote > highestPosition: %lu\n", (unsigned long)[note.position unsignedIntegerValue]);
    
    return [note.position unsignedIntegerValue];
}


#pragma mark 섹션 네임
- (NSString *)sectionName
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM yyyy"];
    return [dateFormatter stringFromDate:date];
}


#pragma mark 노트 저장

- (void)saveLocalNote:(LocalNote *)aNote inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self saveNote:aNote];
}


- (void)saveNote:(LocalNote *)aNote
{
    //노트 데이트 생성 > 섹션 헤더
    self.date = [[NSDate date] timeIntervalSince1970];
//    NSLog (@"self.date from timeIntervalSince1970: %f\n", self.date);
    
    //날짜 문자로 변환 > 셀 레이블
    NSDate *current = [NSDate date];
    
    [self.formatter setDateFormat:@"yyyy"];
    NSString *stringYear = [self.formatter stringFromDate:current];
    
    [self.formatter setDateFormat:@"M"];
    NSString *stringMonth = [self.formatter stringFromDate:current];
    
    [self.formatter setDateFormat:@"dd"];
    NSString *stringDay = [self.formatter stringFromDate:current];
    
    [self.formatter setDateFormat:@"EEEE"];
    NSString *stringDate = [self.formatter stringFromDate:current];
    NSString *stringdaysOfTheWeek = [[stringDate substringToIndex:3] uppercaseString];
    
    self.yearString = stringYear;
    self.monthString = stringMonth;
    self.dayString = stringDay;
    self.dateString = stringdaysOfTheWeek;
}


#pragma mark 폰트
#pragma mark 타이틀 레터프레스 효과 적용

- (NSAttributedString *)applyLetterPressEffect:(NSString *)aString withColor:(UIColor *)aColor
{
    UIFont* font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    UIColor* textColor = aColor;
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : textColor,
                             NSFontAttributeName : font,
                             NSTextEffectAttributeName : NSTextEffectLetterpressStyle};
    NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:aString attributes:attrs];
    
    return attrString;
}


#pragma mark - 유저 디폴트 > 인덱스 저장 (사용안함)

- (NSInteger)indexOfSelectedNote
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kSELECTED_LOCAL_NOTE_INDEX];
}


- (void)setIndexOfSelectedNote:(NSInteger)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:kSELECTED_LOCAL_NOTE_INDEX];
}


#pragma mark - 프라이빗 메소드

//Invoked automatically by the Core Data framework. when the receiver is first inserted into a managed object context. this method is invoked only once in the object's lifetime.

#pragma mark - Awake From Insert

-(void) awakeFromInsert
{
    [super awakeFromInsert];
}


#pragma mark - 유저 디폴트

- (id)init
{
    if ((self = [super init]))
    {
        [self registerDefaults];
        [self formatter];                                   //데이트 Formatter
    }
    return self;
}


- (void)registerDefaults
{
    NSDictionary *dictionary = @{ kSELECTED_LOCAL_NOTE_INDEX : @-1 };
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}


#pragma mark 첫째 라인만 가져오기

- (NSString *)getFirstLineOfStringForTitle:(NSString *)aString
{
    NSString *trimmedTitleString = [self makeTrimmedString:aString];
    
    if (trimmedTitleString.length == 0)
    {
        trimmedTitleString = @"Untitled";
    }
    
    if (trimmedTitleString.length > 0)
    {
        //노트 타이틀
        __block NSString *trimmedNoteTitle = nil;
        [trimmedTitleString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {trimmedNoteTitle = line; *stop = YES;}];
    }
    return trimmedTitleString;
}


#pragma mark 노트 디스크립션

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n noteCreatedDate : %@, \n noteModifiedDate: %@, \n hasNoteStar: %@, \n isLocalNote: %@, \n isDropboxNote: %@, \n isiCloudNote: %@, \n noteTitle: %@,  \n noteSection: %@", [self noteCreatedDate], [self noteModifiedDate], [[self hasNoteStar] boolValue] ? @"YES" : @"NO",  [[self isLocalNote] boolValue] ? @"YES" : @"NO", [[self isDropboxNote] boolValue] ? @"YES" : @"NO", [[self isiCloudNote] boolValue] ? @"YES" : @"NO", [self noteTitle], [self noteSection]];
}


#pragma mark 문자열 길이 취득

- (NSUInteger)getLengthFromString:(NSString *)aString
{
    NSUInteger len = [aString length];
    return len;
}


#pragma mark 공백 문자 제거

- (NSString *)makeTrimmedString:(NSString *)aString
{
    NSString *trimmedString;
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];    //공백 문자와 라인 피드문자 삭제
    trimmedString = [aString stringByTrimmingCharactersInSet:charSet];
    return trimmedString;
}


#pragma mark 데이트 Formatter

// When you need, just use self.formatter
- (NSDateFormatter *)formatter
{
    if (! _formatter) {
        _formatter = [[NSDateFormatter alloc] init];
    }
    return _formatter;
}


@end
