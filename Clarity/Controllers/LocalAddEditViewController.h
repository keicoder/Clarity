//
//  LocalAddEditViewController.h
//  SwiftNote
//
//  Created by jun on 6/5/14.
//  Copyright (c) 2014 Overcommitted, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalNote.h"


@interface LocalAddEditViewController : UIViewController

@property (strong, nonatomic) LocalNote *currentNote;       //리스트 뷰에서 넘겨받거나 넘겨 줄 노트
@property (assign, nonatomic) BOOL isNewNote;               //Add 버튼으로 생긴 뉴 노트인지 확인
@property (assign, nonatomic) BOOL isSearchResultNote;      //Search 디스플레이에서 푸시(모달)된 노트인지 확인
@property (nonatomic, assign) BOOL isLocalNote;             //로컬 노트인지 확인


#pragma mark - 노트 in Managed Object Context 
- (void)note:(LocalNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;   //스토리보드

@end
