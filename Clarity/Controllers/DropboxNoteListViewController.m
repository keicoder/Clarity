//
//  DropboxNoteListViewController.m
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 19..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//
/*
 indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
 indexPath = [self.tableView indexPathForSelectedRow];
 */


#import "DropboxNoteListViewController.h"
//#import "FRLayeredNavigationController/FRLayeredNavigation.h"
#import "AppDelegate.h"                                     //앱델리게이트 참조
#import "NoteDataManager.h"                                 //노트 데이터 매니저
#import "DropboxNote.h"                                     //노트 데이터 모델
#import "DropboxAddEditViewController.h"                    //AddEdit View
#import "DropboxStarViewController.h"                       //스타 뷰 컨트롤러
#import "NoteTableViewCell.h"                               //커스텀 셀
#import "UIImage+ChangeColor.h"                             //이미지 컬러 변경
#import "NSUserDefaults+Extension.h"                        //셀 선택시 인덱스패스 유저 디폴트에 저장
#import "WelcomePageViewController.h"                       //Welcome 뷰 > 앱 처음 실행인지 체크 > Welcome 뷰 보여줌
#import "MTZWhatsNew.h"
#import "MTZWhatsNewGridViewController.h"


@interface DropboxNoteListViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;                        //테이블 뷰
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;                        //서치바
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIViewController *starViewController;                 //스타 뷰
@property (nonatomic, strong) NSMutableArray *searchResultNotes;                    //서치바 검색결과를 담을 뮤터블 배열
@property (nonatomic, strong) DropboxNote *selectedNote;                            //AddEdit View로 넘겨 줄 노트
@property (nonatomic, strong) NSDateFormatter *formatter;                           //데이트 Formatter
@property (nonatomic, strong) UIBarButtonItem *barButtonItemStarred;                //바 버튼 아이템
@property (nonatomic, strong) UIButton *buttonStar;                                 //바 버튼 아이템
@property (nonatomic, strong) UIButton *infoButton;                                 //인포 버튼
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;                            //헬프 레이블

@end


@implementation DropboxNoteListViewController
{
    int _totalNotes;                                          //노트 갯수
    NSString *_titleString;                                   //new 노트 타이틀 스트링
}


#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewAndTableView];
    [self addBarButtonItem];                                                        //바 버튼
    [self checkWhetherShowWelcomeView];                                             //앱 처음 실행인지 체크 > Welcome 뷰 보여줌
    [self addObserverForNewNote];                                                   //애드,에딧 뷰에서 뉴 노트 생성 버튼 누를 때 필요한 옵저버
    [self addObserverForWelcomeViewControllerDismissed];                            //웰컴 뷰 해제
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showStatusBar];
    [self showNavigationBar];
    [self executePerformFetch];                                                     //패치 코어데이터 아이템
    [self initializeSearchResultNotes];                                             //서치 results 초기화
    [self.tableView reloadData];                                                    //테이블 뷰 업데이트
    [self performUpdateInfoButton];                                                 //업데이트 인포
    [self performCheckNoNote];                                                      //노트 없으면 헬프 레이블 보여줄 것
    [self saveCurrentView];                                                         //현재 뷰 > 유저 디폴트 저장
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkToShowWhatsNewView];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self cancelCurrentView];                   //현재 뷰 > 유저 디폴트 캔슬
    [self deActivateSearchDisplayController];   //서치 디스플레이 컨트롤러 비활성화 (애드에딧 뷰에서 나올때 서치 디스플레이 컨트롤러를 거치지 않고 테이블뷰로 바로 돌아옴)
    self.formatter = nil;                       //데이트 Formatter > nil
    _fetchedResultsController = nil;
    self.title = @"";
}


#pragma mark - 검색결과를 담을 뮤터블 배열 초기화

- (void)initializeSearchResultNotes
{
    self.searchResultNotes = [NSMutableArray arrayWithCapacity:[[self.fetchedResultsController fetchedObjects] count]];
}


#pragma mark - 서치 디스플레이 컨트롤러 비활성화 (애드에딧 뷰에서 나올때 서치 디스플레이 컨트롤러를 거치지 않고 테이블뷰로 바로 돌아옴)

- (void)deActivateSearchDisplayController
{
    if ([self.searchDisplayController isActive])    // check if searchDisplayController still active..
    {
        [self.searchDisplayController setActive:NO];
    }
}


#pragma mark - 뷰 및 테이블 뷰 속성

- (void)configureViewAndTableView
{
    self.view.backgroundColor = kTEXTVIEW_BACKGROUND_COLOR;
    self.tableView.backgroundColor = kTABLE_VIEW_BACKGROUND_COLOR;
    self.tableView.separatorColor = kTEXTVIEW_BACKGROUND_COLOR;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


#pragma mark 데이터 소스
#pragma mark 섹션 갯수

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
            return 0;
        }
        else {
            return 1;
        }
    }
    else {
        return [[self.fetchedResultsController sections] count];
    }
}


#pragma mark 셀 갯수

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return self.searchResultNotes.count;
    }
    else
    {
        return [[self.fetchedResultsController sections][section] numberOfObjects];
    }
}


#pragma mark 셀

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NoteTableViewCell *cell = (NoteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = (NoteTableViewCell *) [[[NSBundle mainBundle] loadNibNamed:@"NoteTableViewCell" owner:self options:nil] lastObject];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        //테이블 뷰 속성
        tableView.backgroundColor = kTABLE_VIEW_BACKGROUND_COLOR;
        tableView.separatorColor = kTABLE_VIEW_SEPARATOR_COLOR;
        
        DropboxNote *note = self.searchResultNotes[indexPath.row];
        cell.noteTitleLabel.text = note.noteTitle;
        cell.noteSubtitleLabel.text = note.noteBody;
        cell.dateLabel.text = note.dateString;
        cell.dayLabel.text = note.dayString;
        
        [self configureCell:cell atIndexPath:indexPath];
        [self configureImages:note cell:cell];
    }
    else {
        DropboxNote *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.noteTitleLabel.text = note.noteTitle;
        cell.noteSubtitleLabel.text = note.noteBody;
        cell.dateLabel.text = note.dateString;
        cell.dayLabel.text = note.dayString;
        
        [self configureCell:cell atIndexPath:indexPath];
        [self configureImages:note cell:cell];
    }
    return cell;
}


#pragma mark 셀 속성

- (void)configureCell:(NoteTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //셀 속성
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) { cell.separatorInset = UIEdgeInsetsZero; }
    cell.backgroundColor = kTABLE_VIEW_BACKGROUND_COLOR;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.noteTitleLabel.font = kTABLE_VIEW_CELL_TEXTLABEL_FONT;
    cell.noteTitleLabel.textColor = kTABLE_VIEW_CELL_TEXTLABEL_TEXTCOLOR;
    cell.noteSubtitleLabel.font = kTABLE_VIEW_CELL_DETAILTEXTLABEL_FONT;
    cell.noteSubtitleLabel.textColor = kTABLE_VIEW_CELL_DETAILTEXTLABEL_TEXTCOLOR;
    
    if ([cell.dateLabel.text isEqualToString:@"SAT"])
    {
        cell.dayLabel.textColor = kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_SATURDAY;
    }
    else if ([cell.dateLabel.text isEqualToString:@"SUN"]) {
        cell.dayLabel.textColor = kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_SUNDAY;
    }
    else {
        cell.dayLabel.textColor = kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_DEFAULT;
    }
    cell.dateLabel.textColor = kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_DEFAULT;
    cell.dayLabel.font = kTABLE_VIEW_CELL_DAYLABEL_FONT;
    cell.dateLabel.font = kTABLE_VIEW_CELL_DATELABEL_FONT;
}


#pragma mark 셀 이미지

- (void)configureImages:(DropboxNote *)note cell:(NoteTableViewCell *)cell
{
    UIImage *starredImage = [UIImage imageNameForChangingColor:@"star-256-white" color:kGOLD_COLOR];
    BOOL hasNoteStarCurrentState = [note.hasNoteStar boolValue];    //불리언 값, kLOGBOOL(hasNoteStarCurrentState);
    
    if (hasNoteStarCurrentState) {
        cell.starImageView.image = starredImage;
    } else {
        cell.starImageView.image = nil;
    }
}


#pragma mark 델리게이트 메소드
#pragma mark 섹션 헤더 속성

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
    [header.textLabel setTextColor:[UIColor colorWithRed:0.467 green:0.482 blue:0.482 alpha:1]];
    header.contentView.backgroundColor = [UIColor colorWithWhite:0.904 alpha:1.000];                //데이 모드
    //header.contentView.backgroundColor = [UIColor colorWithWhite:0.379 alpha:1.000];              //나이트 모드
}


#pragma mark 섹션 헤더 타이틀

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}


#pragma mark 섹션 헤더 높이

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTABLE_CELL_SECTION_HEADER_HEIGHT;
}


#pragma mark 셀 높이

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return kSEARCH_TABLE_CELL_HEIGHT;
    }
    else
    {
        return kTABLE_CELL_HEIGHT;
    }
}


#pragma mark 편집

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            [self.searchResultNotes removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self deleteCoreDataNoteObject:indexPath];  //코어 데이터 노트
        }
        else
        {
            [self deleteCoreDataNoteObject:indexPath];  //코어 데이터 노트
        }
    }
    [self performUpdateInfoButton];                                                 //업데이트 인포
    [self performCheckNoNote];                                                      //노트 없으면 헬프 레이블 보여줄 것
}


- (void)deleteCoreDataNoteObject:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSManagedObjectContext *managedObjectContext = [NoteDataManager sharedNoteDataManager].managedObjectContext;
    [managedObjectContext deleteObject:managedObject];
    NSError *error = nil;
    [managedObjectContext save:&error];
}


#pragma mark 셀 이동

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark 셀 선택

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DropboxAddEditViewController *controller = (DropboxAddEditViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxAddEditViewController"];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        self.selectedNote = (DropboxNote *)[self.searchResultNotes objectAtIndex:indexPath.row];
        
        controller.isSearchResultNote = YES;
        controller.currentNote = self.selectedNote;
        
        [self.searchDisplayController.searchBar setText:self.searchDisplayController.searchBar.text];
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
//        NSManagedObjectContext *managedObjectContext = [NoteDataManager sharedNoteDataManager].managedObjectContext;
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc]
                                                        initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [managedObjectContext setParentContext:[NoteDataManager sharedNoteDataManager].managedObjectContext];
        
        [self saveIndexPath:indexPath]; //유저 디폴트 > 현재 인덱스패스 저장
        
        self.selectedNote = (DropboxNote *)[managedObjectContext objectWithID:[[self.fetchedResultsController objectAtIndexPath:indexPath] objectID]];
        
//        self.selectedNote = (DropboxNote *)[self.fetchedResultsController objectAtIndexPath:indexPath]; //위 코드와 결과 동일
        [controller note:self.selectedNote inManagedObjectContext:managedObjectContext];
        
        controller.isSearchResultNote = NO;
        controller.currentNote = self.selectedNote;
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [self.navigationController pushViewController:controller animated:YES]; //Push
}


#pragma mark - Add 노트

- (void)addNewNote:(id)sender
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc]
                                                    initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext setParentContext:[NoteDataManager sharedNoteDataManager].managedObjectContext];
//    NSManagedObjectContext *managedObjectContext = [NoteDataManager sharedNoteDataManager].managedObjectContext;
    
    DropboxNote *note = [NSEntityDescription insertNewObjectForEntityForName:@"DropboxNote"
                                                         inManagedObjectContext:managedObjectContext];
    
    DropboxAddEditViewController *controller = (DropboxAddEditViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxAddEditViewController"];
    [controller note:note inManagedObjectContext:managedObjectContext];
    
    [self formatter];
    [self buildTitleString];
    
    controller.isSearchResultNote = NO;
    controller.isNewNote = YES;
    controller.isDropboxNote = YES;
    controller.isLocalNote = NO;
    controller.isiCloudNote = NO;
    controller.isOtherCloudNote = NO;
    controller.currentNote.noteTitle = _titleString;
    
    [self.navigationController pushViewController:controller animated:YES];
//    [self presentNote:newNote inManagedObjectContext:managedObjectContext];
}


#pragma mark Present 노트

//- (void)presentNote:(DropboxNote *)aNote inManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
//{
//    DropboxAddEditViewController *controller = (DropboxAddEditViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxAddEditViewController"];
////    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//    
//    [controller note:aNote inManagedObjectContext:aManagedObjectContext];
//    controller.isNewNote = YES;
//    controller.isSearchResultNote = NO;
//    controller.isDropboxNote = YES;
//    [self formatter];                                       //데이트 Formatter
//    [self setTitleString];                                  //데이트 Formatter > 타이틀 스트링
//    controller.currentNote.noteTitle = _titleString;
//    
////    [self presentViewController:navigationController animated:YES completion:^{ }];
//    [self.navigationController pushViewController:controller animated:YES];
//}


#pragma mark 타이틀 스트링

- (NSString *)buildTitleString
{
    NSDate *current = [NSDate date];
    
    [self.formatter setDateFormat:@"dd"];
    NSString *stringDay = [self.formatter stringFromDate:current];
    
    [self.formatter setDateFormat:@"EEEE"];
    NSString *stringDate = [self.formatter stringFromDate:current];
    NSString *stringdaysOfTheWeek = [[stringDate substringToIndex:3] uppercaseString];
    
    [self.formatter setDateFormat:@"H"];
    NSString *stringHour = [self.formatter stringFromDate:current];
    
    [self.formatter setDateFormat:@"m"];
    NSString *stringMinute = [self.formatter stringFromDate:current];
    
    [self.formatter setDateFormat:@"s"];
    NSString *stringSeconds = [self.formatter stringFromDate:current];
    
    _titleString = nil;
//    NSString *untitled = @"Untitled";
    NSString *blank = @" ";
    NSString *colon = @":";
    _titleString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", stringdaysOfTheWeek, blank, stringDay, blank, stringHour, colon, stringMinute, colon, stringSeconds];
//    NSLog (@"_titleString: %@\n", _titleString);
    
    return _titleString;
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


#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    else if (_fetchedResultsController == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DropboxNote"];
        [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"noteModifiedDate" ascending:NO]]];
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:[NoteDataManager sharedNoteDataManager].managedObjectContext
                                     sectionNameKeyPath:@"sectionName" cacheName:nil];
        [fetchRequest setFetchBatchSize:20];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}


#pragma mark Perform Fetch

- (void)executePerformFetch
{
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog (@"executePerformFetch > error occurred");
        //abort();
    } else {
    }
}


#pragma mark - NSFetched Results Controller Delegate (수정사항 반영)

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
    [self performUpdateInfoButton];                                                 //업데이트 인포
    [self performCheckNoNote];                                                      //노트 없으면 헬프 레이블 보여줄 것
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadData];                 //테이블 뷰 업데이트
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
    [self performUpdateInfoButton];                                                 //업데이트 인포
    [self performCheckNoNote];                                                      //노트 없으면 헬프 레이블 보여줄 것
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - 바 버튼 및 메소드

- (void)addBarButtonItem
{
    UIBarButtonItem *barButtonItemFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barButtonItemFixed.width = 22.0f;
    UIBarButtonItem *barButtonItemNarrow = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barButtonItemNarrow.width = 5.0f;
    
    UIImage *star = [UIImage imageNamed:@"star-256"];
    self.buttonStar = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonStar addTarget:self action:@selector(barButtonItemStarredPressed:)forControlEvents:UIControlEventTouchUpInside];
    [self.buttonStar setBackgroundImage:star forState:UIControlStateNormal];
    self.buttonStar.frame = CGRectMake(0 ,0, 26, 26);
    self.barButtonItemStarred = [[UIBarButtonItem alloc] initWithCustomView:self.buttonStar];
    
    UIImage *add = [UIImage imageNamed:@"plus-256"];
    UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonAdd addTarget:self action:@selector(addNewNote:)forControlEvents:UIControlEventTouchUpInside];
    [buttonAdd setBackgroundImage:add forState:UIControlStateNormal];
    buttonAdd.frame = CGRectMake(0 ,0, 20, 20);
    UIBarButtonItem *barButtonItemAdd = [[UIBarButtonItem alloc] initWithCustomView:buttonAdd];
    
    UIView* infoButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    self.infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.infoButton.backgroundColor = [UIColor clearColor];
    self.infoButton.frame = infoButtonView.frame;
    [self.infoButton setTitle:@"" forState:UIControlStateNormal];
    self.infoButton.tintColor = kINFOBUTTON_TEXTCOLOR;
    self.infoButton.autoresizesSubviews = YES;
    self.infoButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    self.infoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.infoButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.infoButton.userInteractionEnabled = NO;
    [infoButtonView addSubview:self.infoButton];
    
    self.navigationItem.rightBarButtonItems = @[barButtonItemNarrow, barButtonItemAdd, barButtonItemFixed, self.barButtonItemStarred];
    self.navigationItem.titleView = infoButtonView;
}


#pragma mark 버튼 액션 메소드

- (void)buttonSearchPressed:(id)sender
{
    [self.searchDisplayController.searchBar becomeFirstResponder];
}


- (void)barButtonItemStarredPressed:(id)sender
{
    self.starViewController = (DropboxStarViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DropboxStarViewController"];
    [self.navigationController pushViewController:self.starViewController animated:YES];
}


#pragma mark 업데이트 인포 버튼

- (void)performUpdateInfoButton
{
    [self performSelector:@selector(updateInfoButton) withObject:self.infoButton afterDelay:0.5];
}


- (void)updateInfoButton
{
    _totalNotes = (int)[[_fetchedResultsController fetchedObjects] count];        //노트 갯수
    
    if (_totalNotes == 0) {
        [self.infoButton setTitle:@"Dropbox" forState:UIControlStateNormal];
    }
    else if (_totalNotes == 1)
    {
        [self.infoButton setTitle:@"1 note" forState:UIControlStateNormal];
    }
    else if (_totalNotes > 1)
    {
        [self.infoButton setTitle:[NSString stringWithFormat:@"%d notes", _totalNotes] forState:UIControlStateNormal];
    }
}


#pragma mark - 내비게이션 및 상태 바 컨트롤

- (void)showNavigationBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)hideNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}


- (void)hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}


#pragma mark - 서치바 및 서치 디스플레이 컨트롤러
#pragma mark 뷰가 처음 나타날 때 서치바 감출지 여부 check

- (void)hideSearchBar
{
    if ((unsigned long)[[_fetchedResultsController fetchedObjects] count] == 0) {
        CGRect newBounds = self.tableView.bounds;
        newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
        self.tableView.bounds = newBounds;
    }
}


#pragma mark 서치 디스플레이 컨트롤러 - 노트 필터링

- (void)filterNoteAllFromFetchedObjects:(NSArray *)fetchedObjects forSearchText:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"noteAll contains[cd] %@", searchText]; //@"SELF.noteAll contains[cd] %@" > noteAll refers to the noteAll property, NSPredicate supports > BEGINSWITH, ENDSWITH, LIKE, MATCHES, CONTAINS
    [self.searchResultNotes addObjectsFromArray:[fetchedObjects filteredArrayUsingPredicate:predicate]];
}


- (void)filterNoteTitleFromFetchedObjects:(NSArray *)fetchedObjects forSearchText:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"noteTitle contains[cd] %@", searchText];
    [self.searchResultNotes addObjectsFromArray:[fetchedObjects filteredArrayUsingPredicate:predicate]];
}


- (void)filterNotesWithSearchText:(NSString*)searchText forScopeIndex:(NSInteger)scopeIndex
{
    [self.searchResultNotes removeAllObjects];
    if (scopeIndex == 0)
    {
        [self filterNoteAllFromFetchedObjects:[self.fetchedResultsController fetchedObjects]
                                forSearchText:searchText];
    }
    if (scopeIndex == 1) {
        [self filterNoteTitleFromFetchedObjects:[self.fetchedResultsController fetchedObjects]
                                  forSearchText:searchText];
    }
}


#pragma mark 서치 디스플레이 델리게이트 메소드

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterNotesWithSearchText:searchString
                      forScopeIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterNotesWithSearchText:self.searchDisplayController.searchBar.text
                      forScopeIndex:searchOption];
    return YES;
}


- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.searchDisplayController.searchBar.tintColor = kSEARCH_DISPLAYCONTROLLER_SEARCHBAR_TINTCOLOR;
}


- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    
}


#pragma mark - 헬프 레이블

- (void)performCheckNoNote
{
    [self performSelector:@selector(checkNoNote) withObject:self.infoButton afterDelay:0.0];
}


- (void)checkNoNote
{
    if ([[_fetchedResultsController fetchedObjects] count] == 0)
    {
        self.helpLabel.alpha = 1.0;
        self.helpLabel.textColor = [UIColor lightGrayColor];
        self.tableView.separatorColor = kCLEAR_COLOR;
    }
    else
    {
        self.helpLabel.alpha = 0.0;
        self.helpLabel.textColor = [UIColor clearColor];
        self.tableView.separatorColor = kCLEAR_COLOR; //kTEXTVIEW_BACKGROUND_COLOR;
    }
}


#pragma mark - Notification

#pragma mark 뉴 노트 생성 Notification 옵저버 등록

- (void)addObserverForNewNote
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewNote:)
                                                 name:@"AddNewNoteNotification"
                                               object:nil];
}


#pragma mark WelcomeViewControllerDismissed Notification 옵저버 등록

- (void)addObserverForWelcomeViewControllerDismissed
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveWelcomeViewControllerDismissedNotification:)
                                                 name:@"WelcomeViewControllerDismissedNotification"
                                               object:nil];
}


#pragma mark WelcomeViewControllerDismissed 노티피케이션 수신 후 후속작업

- (void)didReceiveWelcomeViewControllerDismissedNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"WelcomeViewControllerDismissedNotification"])
    {
        NSLog(@"WelcomeViewControllerDismissed Notification Received");
        
        NSString *versionString = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
        NSLog (@"versionString: %@\n", versionString);
        
        NSString *lastVersionString = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentVersion"];
        NSLog (@"lastVersionString: %@\n", lastVersionString);
        
        if ([versionString isEqualToString:lastVersionString]) {
            
        }
        else {
            [self performSelector:@selector(showWhatsNewView) withObject:nil afterDelay:1.0];
            [[NSUserDefaults standardUserDefaults] setObject:versionString forKey:@"currentVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}


#pragma mark 옵저버 해제

- (void)deregisterForNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"WelcomeViewControllerDismissedNotification" object:nil];
    [center removeObserver:self name:@"AddNewNoteNotification" object:nil];
    
    [center removeObserver:self];
}


#pragma mark - Dealloc

- (void)dealloc
{
    [self deregisterForNotifications];                              //Remove 옵저버
    _fetchedResultsController = nil;                                //fetchedResultsController
    self.searchResultNotes = nil;                                   //검색결과를 담을 뮤터블 배열
    NSLog(@"dealloc %@", self);
}


#pragma mark - 유저 디폴트
#pragma mark 유저 디폴트 > 현재 인덱스패스 저장

- (void)saveIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setInteger:indexPath.row forKey:kSELECTED_DROPBOX_NOTE_INDEX];        //인덱스
    [standardUserDefaults setIndexPath:indexPath forKey:kSELECTED_DROPBOX_NOTE_INDEXPATH];      //인덱스패스
    [standardUserDefaults synchronize];
    //    NSLog(@"didSelectRowAtIndex > _selectedIndex > saved Index: %d\n", [[NSUserDefaults standardUserDefaults] integerForKey:kSELECTED_DROPBOX_NOTE_INDEX]);
    //    NSLog(@"didSelectRowAtIndexPath > _selectedIndexPath > saved IndexPath: %@", [standardUserDefaults indexPathForKey:kSELECTED_DROPBOX_NOTE_INDEXPATH]);
}


#pragma mark 유저 디폴트 > 현재 뷰 저장

- (void)saveCurrentView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:kCURRENT_VIEW_IS_DROPBOX];                         //현재 뷰
    [standardUserDefaults synchronize];
}


- (void)cancelCurrentView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:NO forKey:kCURRENT_VIEW_IS_DROPBOX];                          //현재 뷰
    [standardUserDefaults synchronize];
}


#pragma mark - 내비게이션 컨트롤러 델리게이트

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:kSELECTED_DROPBOX_NOTE_INDEX];
    }
}


#pragma mark - 메모리 경고

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - 디바이스 방향 지원

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark - 앱 처음 실행인지 체크 > Welcome 뷰 보여줌

- (void)checkWhetherShowWelcomeView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHasLaunchedOnce"] == YES)  // app already launched
    { }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHasLaunchedOnce"]; //app first launched
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showWelcomeView];       //Welcome 뷰 보여줌
    }
}


- (void)showWelcomeView
{
    WelcomePageViewController *controller = (WelcomePageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WelcomePageViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - checkToShowWhatsNewView

- (void)checkToShowWhatsNewView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHasLaunchedOnce"] == YES)  // app already launched
    {
        NSString *versionString = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
        //NSLog (@"versionString: %@\n", versionString);
        
        NSString *lastVersionString = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentVersion"];
        //NSLog (@"lastVersionString: %@\n", lastVersionString);
        
        if ([versionString isEqualToString:lastVersionString]) {
            
        }
        else {
            [self performSelector:@selector(showWhatsNewView) withObject:nil afterDelay:0.3];
            [[NSUserDefaults standardUserDefaults] setObject:versionString forKey:@"currentVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else {
        
    }
}


#pragma mark Show What's New View

- (void)showWhatsNewView
{
    [MTZWhatsNew handleWhatsNew:^(NSDictionary *whatsNew)
     {
         MTZWhatsNewGridViewController *vc = [[MTZWhatsNewGridViewController alloc] initWithFeatures:whatsNew];
         
         vc.backgroundGradientTopColor = kWHITE_COLOR; //[UIColor colorWithHue:0.77 saturation:0.77 brightness:0.76 alpha:1];
         vc.backgroundGradientBottomColor = kWHITE_COLOR; //[UIColor colorWithHue:0.78 saturation:0.6 brightness:0.95 alpha:1];
         
         [self.navigationController presentViewController:vc animated:YES completion:nil];
         
         vc.dismissButtonTitle = @"Dismiss";
         
     } sinceVersion:@"1.0"];
}


#pragma mark - 테이블 푸터 뷰

- (void)addFooterViewToTableView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.tableView.frame))];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    //[view setBackgroundColor:[UIColor colorWithWhite:0.92 alpha:1]];
    [view setBackgroundColor:kCLEAR_COLOR];
    UIImage *image = [UIImage imageNamed:@"swiftNoteWideLogo102by38"];
    //UIImage *imageThumb = [image makeThumbnailOfSize:CGSizeMake(image.size.width, image.size.height)];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:image];
    //[logoImageView setCenter:view.center];
    [logoImageView setFrame:({
        CGRect frame = logoImageView.frame;
        frame.origin.x = 70; //(self.tableView.frame.size.width - frame.size.width) / 2;
        frame.origin.y = 20;
        CGRectIntegral(frame);
    })];
    
    [logoImageView setAlpha:1.0];
    
    [view addSubview:logoImageView];
    
    self.tableView.tableFooterView = view;
    
    //[self.tableView setBackgroundColor:view.backgroundColor];
    self.tableView.contentInset = self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, - CGRectGetHeight(view.bounds), 0);
}


#pragma mark - 유저 디폴트에 저장된 값 불러와 해당 노트 보여줌

- (void)showLastUsedNote
{
    //DBAccountManager *accountManager = [DBAccountManager sharedManager];
    //DBAccount *account = [accountManager linkedAccount];
    
    self.navigationController.delegate = self;
    
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:kSELECTED_DROPBOX_NOTE_INDEX];
    //NSLog (@"selectedDropboxNoteIndex: %d, fetchedObjects count: %d", index, [[_fetchedResultsController fetchedObjects] count]);
    
    if (index < 0 || index >= [[_fetchedResultsController fetchedObjects] count])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:kSELECTED_DROPBOX_NOTE_INDEX];  //해당 노트로 이동 방지
    }
    else if (index >= 0 && index < [[_fetchedResultsController fetchedObjects] count])
    {
        DropboxAddEditViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DropboxAddEditViewController"];
        
        NSIndexPath *indexPath = [[NSUserDefaults standardUserDefaults] indexPathForKey:kSELECTED_DROPBOX_NOTE_INDEXPATH];
        
        //NSManagedObjectContext *managedObjectContext = [NoteDataManager sharedNoteDataManager].managedObjectContext;
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc]
                                                        initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [managedObjectContext setParentContext:[NoteDataManager sharedNoteDataManager].managedObjectContext];
        
        self.selectedNote = (DropboxNote *)[managedObjectContext objectWithID:[[self.fetchedResultsController objectAtIndexPath:indexPath] objectID]];
        
        //self.selectedNote = (DropboxNote *)[self.fetchedResultsController objectAtIndexPath:indexPath]; //위 코드와 결과 동일
        [controller note:self.selectedNote inManagedObjectContext:managedObjectContext];
        
        controller.isSearchResultNote = NO;
        controller.currentNote = self.selectedNote;
        
        [self.navigationController pushViewController:controller animated:YES]; //Push
    }
}


@end
