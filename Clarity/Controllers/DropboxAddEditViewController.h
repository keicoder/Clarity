//
//  DropboxAddEditViewController.h
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxNote.h"
#import <TextExpander/SMTEDelegateController.h>

@interface DropboxAddEditViewController : UIViewController

@property (strong, nonatomic) DropboxNote *currentNote;     //리스트 뷰에서 넘겨받거나 넘겨 줄 노트
@property (nonatomic, assign) BOOL isNewNote;               //Add 버튼으로 생긴 뉴 노트인지 확인
@property (nonatomic, assign) BOOL isSearchResultNote;      //Search 디스플레이에서 푸시(모달)된 노트인지 확인
@property (nonatomic, assign) BOOL isDropboxNote;           //드랍박스 노트인지 확인

@property (nonatomic, strong) SMTEDelegateController *textExpander;

#pragma mark - 노트 in Managed Object Context
- (void)note:(DropboxNote *)note inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;   //스토리보드

@end
