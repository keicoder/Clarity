//
//  ClarityConstants.h
//  SwiftNote
//
//  Created by jun on 2014. 6. 27..
//  Copyright (c) 2014년 Overcommitted, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef                 kCFCoreFoundationVersionNumber_iOS_7_0
#define                 kCFCoreFoundationVersionNumber_iOS_7_0 838.00
#endif

#define iOS7            (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)
#define iPad            [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define iPhone          [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
extern BOOL const       kHasLaunchedOnce;
extern NSString * const kIS_FIRST_TIME;


#define debug 1
#define kLOGBOOL(BOOL) NSLog(@"%s: %@",#BOOL, BOOL ? @"YES" : @"NO" )   //사용법: BOOL success = NO;,
//kLOGBOOL(success);, Prints out 'success: NO' to the console


#pragma mark - FRLayeredNavigationController
#define kFRLAYERED_NAVIGATION_ITEM_WIDTH_LEFT               260
#define kFRLAYERED_NAVIGATION_ITEM_WIDTH_MIDDLE             320
#define kFRLAYERED_NAVIGATION_ITEM_WIDTH_RIGHT              CGRectGetWidth(self.view.bounds)

#define kFRLAYERED_NAVIGATION_ITEM_NEXT_ITEM_DISTANCE       0
#define kFRLAYERED_NAVIGATION_ITEM_MAXIMUM_WIDTH            NO


#pragma mark - JASidePanelController
#define kJASIDEPANEL_LEFTGAP_PERCENTAGE                     0.84


#pragma mark - WebView
#define kWEBVIEW_SCROLLVIEW_CONTENTINSET                    50.0


#define kCURRENT_VIEW_IS_LOCAL                              @"currentViewIsLocal"
#define kSELECTED_LOCAL_NOTE_INDEX                          @"selectedLocalNoteIndex"
#define kSELECTED_LOCAL_NOTE_INDEXPATH                      @"selectedLocalNoteIndexPath"
#define kCURRENT_VIEW_IS_DROPBOX                            @"currentViewIsDropbox"
#define kSELECTED_DROPBOX_NOTE_INDEX                        @"selectedDropboxNoteIndex"
#define kSELECTED_DROPBOX_NOTE_INDEXPATH                    @"selectedDropboxNoteIndexPath"
#define kCURRENT_VIEW_IS_ICLOUD                             @"currentViewIsiCloud"
#define kSELECTED_NOTE_INDEX                                @"selectedNoteIndex"
#define kSELECTED_NOTE_INDEXPATH                            @"selectedNoteIndexPath"

#define kSHOW_GUIDE                                         @"showGuide"
#define kDIDSHOW_NOTEVIEW_HELP                              @"didShowNoteViewHelp"


#pragma mark - 뷰
#define kTOOLBAR_DROPBOX_LIST_VIEW_BACKGROUND_COLOR         [UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:1]
#define kTOOLBAR_LOCAL_LIST_VIEW_BACKGROUND_COLOR           kTOOLBAR_DROPBOX_LIST_VIEW_BACKGROUND_COLOR
#define kTOOLBAR_LEFT_VIEW_BACKGROUND_COLOR                 kTOOLBAR_DROPBOX_LIST_VIEW_BACKGROUND_COLOR
#define kBUTTON_IMAGEVIEW_WIDTH_STAR                        28.0
#define kBUTTON_IMAGEVIEW_HEIGHT_STAR                       28.0
#define kNAVIGATIONBAR_ICONIMAGE_COLOR                      kWHITE_COLOR
#define kNAVIGATIONBAR_ICONIMAGE_COLOR_PRESSED              [UIColor colorWithRed:0.282 green:0.82 blue:0.529 alpha:1]


#pragma mark - 컬러
#define kCLEAR_COLOR                                        [UIColor clearColor]
#define kWHITE_COLOR                                        [UIColor whiteColor]
#define kBLACK_COLOR                                        [UIColor blackColor]
#define kGOLD_COLOR                                         [UIColor colorWithRed:0.847 green:0.702 blue:0.329 alpha:1]
#define kTOOLBAR_TEXT_COLOR                                 [UIColor colorWithRed:0.325 green:0.740 blue:0.857 alpha:1.000]


#pragma mark - 테이블 뷰
#define kTABLE_VIEW_BACKGROUND_COLOR_LEFTVIEW               [UIColor colorWithRed:0.993 green:0.990 blue:0.981 alpha:1.000]
#define kTABLE_VIEW_BACKGROUND_COLOR                        [UIColor colorWithRed:0.976 green:0.973 blue:0.957 alpha:1]
#define kTABLE_VIEW_SEPARATOR_COLOR                         [UIColor colorWithRed:0.82 green:0.82 blue:0.808 alpha:1]
#define kTABLE_CELL_SECTION_HEADER_HEIGHT                   28.0
#define kSEARCH_TABLE_CELL_HEIGHT                           88.0
#define kTABLE_CELL_HEIGHT                                  88.0
#define kSEARCH_TABLE_CELL_HEIGHT_STARVIEW                  50.0
#define kTABLE_CELL_HEIGHT_STARVIEW                         50.0

#define kTABLE_VIEW_CELL_TEXTLABEL_FONT                     [UIFont fontWithName:@"AvenirNext-Regular" size:18.0]
#define kTABLE_VIEW_CELL_DETAILTEXTLABEL_FONT               [UIFont fontWithName:@"AvenirNext-Regular" size:14.0]
#define kTABLE_VIEW_CELL_TEXTLABEL_TEXTCOLOR                [UIColor colorWithRed:0.117 green:0.121 blue:0.132 alpha:1.000]
#define kTABLE_VIEW_CELL_DETAILTEXTLABEL_TEXTCOLOR          [UIColor colorWithRed:0.565 green:0.559 blue:0.559 alpha:1.000]

#define kTABLE_VIEW_CELL_DAYLABEL_FONT                      [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:33]
#define kTABLE_VIEW_CELL_DATELABEL_FONT                     [UIFont fontWithName:@"Avenir-Light" size:14.0]
#define kTABLE_VIEW_CELL_TEXTLABEL_FONT                     [UIFont fontWithName:@"AvenirNext-Regular" size:18.0]
#define kTABLE_VIEW_CELL_DETAILTEXTLABEL_FONT               [UIFont fontWithName:@"AvenirNext-Regular" size:14.0]

#define kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_DEFAULT         [UIColor colorWithRed:0.51 green:0.506 blue:0.498 alpha:1] //[UIColor colorWithRed:0.953 green:0.839 blue:0.706 alpha:1]
#define kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_MONDAY          [UIColor colorWithRed:0.996 green:0.937 blue:0.51 alpha:1]
#define kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_TUESDAY         [UIColor colorWithRed:0.98 green:0.82 blue:0.282 alpha:1]
#define kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_WEDNESDAY       [UIColor colorWithRed:0.984 green:0.639 blue:0.18 alpha:1]
#define kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_THURSDAY        [UIColor colorWithRed:0.973 green:0.545 blue:0.165 alpha:1]
#define kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_FRIDAY          [UIColor colorWithRed:0.416 green:0.714 blue:0.706 alpha:1]
#define kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_SATURDAY        [UIColor colorWithRed:0.973 green:0.545 blue:0.165 alpha:1] //[UIColor colorWithRed:0.070 green:0.522 blue:0.780 alpha:1.000]
#define kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_SUNDAY          [UIColor colorWithRed:0.373 green:0.494 blue:0.604 alpha:1] //[UIColor colorWithRed:0.548 green:0.371 blue:0.000 alpha:1.000]

#define kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_DEFAULT        kTABLE_VIEW_CELL_DETAILTEXTLABEL_TEXTCOLOR
#define kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_MONDAY         kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_MONDAY
#define kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_TUESDAY        kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_TUESDAY
#define kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_WEDNESDAY      kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_WEDNESDAY
#define kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_THURSDAY       kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_THURSDAY
#define kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_FRIDAY         kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_FRIDAY
#define kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_SATURDAY       kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_SATURDAY
#define kTABLE_VIEW_CELL_DATELABEL_TEXTCOLOR_SUNDAY         kTABLE_VIEW_CELL_DAYLABEL_TEXTCOLOR_SUNDAY

#pragma mark - 인포 버튼
#define kINFOBUTTON_TEXTCOLOR                               [UIColor colorWithWhite:0.706 alpha:1.000];

#pragma mark - 윈도우, 상태바 및 내비게이션바
#define kNAVIGATIONBAR_DROPBOX_LIST_VIEW_BAR_TINT_COLOR     [UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:1]
#define kWINDOW_BACKGROUND_COLOR                            kNAVIGATIONBAR_DROPBOX_LIST_VIEW_BAR_TINT_COLOR
#define kSSTATUSBAR_STYLE_DEFAULT                           UIStatusBarStyleDefault
#define kSSTATUSBAR_STYLE_LIGHTCONTENT                      UIStatusBarStyleLightContent

#define kNAVIGATIONBAR_BUTTON_ITEM_LIGHTYELLOW_COLOR        [UIColor colorWithRed:0.859 green:1.000 blue:0.661 alpha:1.000]


#pragma mark - 서치 디스플레이 컨트롤러
#define kSEARCH_DISPLAYCONTROLLER_SEARCHBAR_TINTCOLOR       [UIColor colorWithWhite:0.250 alpha:1.000]


#pragma mark - 텍스트 뷰

#define kINSET_TOP_IPAD                                    150.0     // 텍스트 뷰 인셋 top
#define kINSET_LEFT_IPAD                                     0.0     // 텍스트 뷰 인셋 left
#define kINSET_BOTTOM_IPAD                                  88.0     // 텍스트 뷰 인셋 bottom
#define kINSET_RIGHT_IPAD                                    0.0     // 텍스트 뷰 인셋 right
#define kTEXTVIEW_PADDING_IPAD                             100.0     // 텍스트 뷰 padding
#define kMOVE_TEXT_POSITION_DURATION_IPAD                   0.40     // 캐럿 이동 시간
//폰트
#define kTEXTVIEW_FONT_IPAD                                      [UIFont fontWithName:@"AvenirNext-Regular" size:22.f]
#define kTEXTVIEW_LABEL_FONT_IPAD                                [UIFont fontWithName:@"Avenir-Black" size:24.f]


#define kINSET_TOP                                         120.0     //78.0  //120.0   // 텍스트 뷰 인셋 top
#define kINSET_LEFT                                          0.0     // 텍스트 뷰 인셋 left
#define kINSET_BOTTOM                                       44.0     // 텍스트 뷰 인셋 bottom
#define kINSET_RIGHT                                         0.0     // 텍스트 뷰 인셋 right
#define kTEXTVIEW_PADDING                                   20.0     // 텍스트 뷰 padding
#define kMOVE_TEXT_POSITION_DURATION                        0.40     // 캐럿 이동 시간
//폰트
#define kTEXTVIEW_FONT                                      [UIFont fontWithName:@"AvenirNext-Regular" size:20.f]
#define kTEXTVIEW_LABEL_FONT                                [UIFont fontWithName:@"Avenir-Black" size:22.f]
//배경 컬러 > 데이 모드
#define kTEXTVIEW_BACKGROUND_COLOR                          [UIColor colorWithRed:0.953 green:0.957 blue:0.941 alpha:1]
#define kNOTE_TITLELABEL_BACKGROUNDVIEW_BACKGROUND_COLOR    [UIColor colorWithWhite:0.890 alpha:1.000]
#define kTEXTVIEW_TEXT_COLOR                                [UIColor colorWithRed:0.086 green:0.086 blue:0.086 alpha:1]
#define kTEXTVIEW_LABEL_BACKGROUND_COLOR                    [UIColor colorWithRed:0.953 green:0.957 blue:0.941 alpha:1]
#define kTEXTVIEW_LABEL_TEXT_COLOR                           [UIColor colorWithWhite:0.328 alpha:1.000] //[UIColor colorWithWhite:0.137 alpha:1.000]                          






