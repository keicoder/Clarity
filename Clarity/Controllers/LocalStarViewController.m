//
//  LocalStarViewController.m
//  SwiftNote
//
//  Created by jun on 5/15/14.
//  Copyright (c) 2014 jun. All rights reserved.
//
/*
 indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
 indexPath = [self.tableView indexPathForSelectedRow];
 */


#import "LocalStarViewController.h"
#import "AppDelegate.h"                                     //AppDelegate 참조
#import "NoteDataManager.h"                                 //노트 데이터 매니저
#import "Note.h"                                       //노트 데이터 모델
#import "LocalAddEditViewController.h"                      //로컬 노트 생성 및 편집 뷰
#import "NoteTableViewCell.h"                               //커스텀 셀
#import "UIImage+ChangeColor.h"                             //이미지 컬러 변경


@interface LocalStarViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;                        //테이블 뷰
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;                        //서치바
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController; //fetchedResultsController
@property (nonatomic, strong) NSMutableArray *searchResultNotes;                    //서치바 검색결과를 담을 뮤터블 배열
@property (nonatomic, strong) Note *selectedNote;                              //AddEdit View로 넘겨 줄 노트
@property (nonatomic, strong) UIButton *infoButton;                                 //인포 버튼
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;                            //헬프 레이블

@end


@implementation LocalStarViewController
{
    int _totalNotes;                                                                //노트 갯수
}

#pragma mark - 뷰 life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewAndTableView];
    [self addNavigationBarButtonItem];                                              //내비게이션 바 버튼
    [self hideSearchBar];                                                           //서치바 감춤
    [self addObserverForStarListViewWillShow];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Starred";
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
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.title = @"";
    [self cancelCurrentView];                   //현재 뷰 > 유저 디폴트 캔슬
    [self deActivateSearchDisplayController];   //서치 디스플레이 컨트롤러 비활성화 (애드에딧 뷰에서 나올때 서치 디스플레이 컨트롤러를 거치지 않고 테이블뷰로 바로 돌아옴)
    _fetchedResultsController = nil;
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
    self.view.backgroundColor = kTEXTVIEW_BACKGROUND_COLOR;//kTOOLBAR_DROPBOX_LIST_VIEW_BACKGROUND_COLOR;          //뷰
    self.tableView.backgroundColor = kTABLE_VIEW_BACKGROUND_COLOR;                                    //테이블 뷰 배경 색상
    self.tableView.separatorColor = kTEXTVIEW_BACKGROUND_COLOR; //[UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:0.1]; //구분선 색상
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
        
        Note *note = self.searchResultNotes[indexPath.row];
        cell.noteTitleLabel.text = note.noteTitle;
        cell.noteSubtitleLabel.text = note.noteBody;
        cell.dateLabel.text = note.dateString;
        cell.dayLabel.text = note.dayString;
        
        [self configureCell:cell atIndexPath:indexPath];
        [self configureImages:note cell:cell];
    }
    else {
        Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
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

- (void)configureImages:(Note *)note cell:(NoteTableViewCell *)cell
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
    LocalAddEditViewController *controller = (LocalAddEditViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LocalAddEditViewController"];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) 
    {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        self.selectedNote = (Note *)[self.searchResultNotes objectAtIndex:indexPath.row];
        
        controller.isSearchResultNote = YES;
        controller.isNewNote = NO;
        controller.currentNote = self.selectedNote;
        
        [self.searchDisplayController.searchBar setText:self.searchDisplayController.searchBar.text];
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
    } 
    else 
    {
        NSManagedObjectContext *managedObjectContext = [NoteDataManager sharedNoteDataManager].managedObjectContext;
//        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] 
//                                                        initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        [managedObjectContext setParentContext:[NoteDataManager sharedNoteDataManager].managedObjectContext];
        
        self.selectedNote = (Note *)[managedObjectContext objectWithID:[[self.fetchedResultsController objectAtIndexPath:indexPath] objectID]];
        
//        self.selectedNote = (Note *)[self.fetchedResultsController objectAtIndexPath:indexPath]; //위 코드와 결과 동일
        [controller note:self.selectedNote inManagedObjectContext:managedObjectContext];
        
        controller.isSearchResultNote = NO;
        controller.isNewNote = NO;
        controller.currentNote = self.selectedNote;
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 유저 디폴트

#pragma mark 유저 디폴트 > 현재 뷰 저장

- (void)saveCurrentView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:kCURRENT_VIEW_IS_LOCAL];                         //현재 뷰
    [standardUserDefaults synchronize];
}


- (void)cancelCurrentView
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:NO forKey:kCURRENT_VIEW_IS_LOCAL];                          //현재 뷰
    [standardUserDefaults synchronize];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    else if (_fetchedResultsController == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
        NSPredicate *predicateIsLocalNote = [NSPredicate predicateWithFormat:@"isLocalNote == %@", [NSNumber numberWithBool: YES] ];
        NSPredicate *predicateHasNoteStar = [NSPredicate predicateWithFormat:@"hasNoteStar == %@", [NSNumber numberWithBool: YES] ];
        
        NSArray *predicatesArray = [NSArray arrayWithObjects:predicateIsLocalNote, predicateHasNoteStar, nil];
        NSPredicate * compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
        [fetchRequest setPredicate:compoundPredicate];
        
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

- (void)addNavigationBarButtonItem
{
    UIBarButtonItem *barButtonItemFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barButtonItemFixed.width = 20.0f;
    
    
    UIView* infoButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    self.infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.infoButton.backgroundColor = [UIColor clearColor];
    self.infoButton.frame = infoButtonView.frame;
    [self.infoButton setTitle:@"" forState:UIControlStateNormal];
    self.infoButton.tintColor = kINFOBUTTON_TEXTCOLOR;
    self.infoButton.autoresizesSubviews = YES;
    self.infoButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [self.infoButton addTarget:self action:@selector(noAction:) forControlEvents:UIControlEventTouchUpInside];
    self.infoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.infoButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
    [infoButtonView addSubview:self.infoButton];
    UIBarButtonItem* barButtonItemInfo = [[UIBarButtonItem alloc]initWithCustomView:infoButtonView];
    
    self.navigationItem.rightBarButtonItems = @[barButtonItemInfo];
}


#pragma mark 버튼 액션 메소드

- (void)noAction:(id)sender
{
    
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
        [self.infoButton setTitle:@"" forState:UIControlStateNormal];
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
    else
    {
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
        self.tableView.separatorColor = kCLEAR_COLOR;
    }
    else
    {
        self.helpLabel.alpha = 0.0;
        self.tableView.separatorColor = kCLEAR_COLOR; //kTEXTVIEW_BACKGROUND_COLOR;
    }
}


#pragma mark - StarListViewWillShow Notification 옵저버 등록

- (void)addObserverForStarListViewWillShow
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveStarListViewWillShowNotification:)
                                                 name:@"StarListViewWillShowNotification"
                                               object:nil];
}


#pragma mark StarListViewWillShow 노티피케이션 수신 후 후속작업

- (void)didReceiveStarListViewWillShowNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"StarListViewWillShowNotification"])
    {
        [self executePerformFetch];                                                     //패치 코어데이터 아이템
        [self initializeSearchResultNotes];                                             //서치 results 초기화
        [self.tableView reloadData];                                                    //테이블 뷰 업데이트
        [self performUpdateInfoButton];                                                 //업데이트 인포
        [self performCheckNoNote];                                                      //노트 없으면 헬프 레이블 보여줄 것
        [self saveCurrentView];                                                         //현재 뷰 > 유저 디폴트 저장
    }
}


#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];     //Remove 옵저버
    _fetchedResultsController = nil;                                //fetchedResultsController
    self.searchResultNotes = nil;                                   //검색결과를 담을 뮤터블 배열
    NSLog(@"dealloc %@", self);
}


#pragma mark - 메모리 경고

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
