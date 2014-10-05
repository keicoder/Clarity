
#import <UIKit/UIKit.h>

@interface ICTextView : UITextView


#pragma mark - Property

@property (strong, nonatomic) UIColor *primaryHighlightColor;       // Color of the primary search highlight (default = RGB 150/200/255)
@property (strong, nonatomic) UIColor *secondaryHighlightColor;     // Color of the secondary search highlights (default = RGB 215/240/255)
@property (nonatomic) CGFloat highlightCornerRadius;                // Highlight corner radius (default = fontSize * 0.2)
@property (nonatomic) BOOL highlightSearchResults;                  // Toggles highlights for search results (default = YES // NO = only scrolls) 
@property (nonatomic) NSUInteger maxHighlightedMatches;             // Maximum number of cached highlighted matches (default = 100), *Note 1: setting this too high will impact memory usage, *Note 2: this value is indicative. More search results will be highlighted if they are on-screen
@property (nonatomic) NSTimeInterval scrollAutoRefreshDelay;        // Delay for the auto-refresh while scrolling feature (default = 0.2 // min = 0.1 // off = 0.0), *Note: decreasing/disabling this may improve performance when self.text is very big
@property (nonatomic, readonly) NSRange rangeOfFoundString;         // Range of string found during last search ({0, 0} on init and after resetSearch // {NSNotFound, 0} if not found)


#pragma mark -
#pragma mark 텍스트 뷰 속성

- (void)assignTextViewAttribute;


#pragma mark -
#pragma mark ICTextiew

#pragma mark -- Search --

- (NSString *)foundString;              // Returns string found during last search
- (void)resetSearch;                    // Resets search, starts from top

// Scrolls to regex match (returns YES if found, NO otherwise)
- (BOOL)scrollToMatch:(NSString *)pattern;
- (BOOL)scrollToMatch:(NSString *)pattern searchOptions:(NSRegularExpressionOptions)options;
- (BOOL)scrollToMatch:(NSString *)pattern searchOptions:(NSRegularExpressionOptions)options range:(NSRange)range;

// Scrolls to string (returns YES if found, NO otherwise)
- (BOOL)scrollToString:(NSString *)stringToFind;
- (BOOL)scrollToString:(NSString *)stringToFind searchOptions:(NSRegularExpressionOptions)options;
- (BOOL)scrollToString:(NSString *)stringToFind searchOptions:(NSRegularExpressionOptions)options range:(NSRange)range;

#pragma mark -- Misc --

- (void)scrollRangeToVisible:(NSRange)range consideringInsets:(BOOL)considerInsets;     // Scrolls to visible range, eventually considering insets
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated consideringInsets:(BOOL)considerInsets;    // Scrolls to visible rect, eventually considering insets

// Returns visible range, with start and end position, eventually considering insets
- (NSRange)visibleRangeConsideringInsets:(BOOL)considerInsets;
- (NSRange)visibleRangeConsideringInsets:(BOOL)considerInsets startPosition:(UITextPosition *__autoreleasing *)startPosition endPosition:(UITextPosition *__autoreleasing *)endPosition;

// Returns visible rect, eventually considering insets
- (CGRect)visibleRectConsideringInsets:(BOOL)considerInsets;


#pragma mark -
#pragma mark JTextiew

#pragma mark - When keyboard pops up
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification*)notification;

#pragma mark - Caret 이동
- (void)scrollToVisibleCaretAnimated;

#pragma mark - 스트링 메소드
- (void)goToPreviousWord:(UITextView *)textView;
- (void)selectParagraph:(UITextView *)textView;
- (void)goToNextWord:(UITextView *)textView;

#pragma mark - Move text caret position
- (void)moveTextPositionAboveKeyboard:(UITextView *)textView withAnimation:(BOOL)shouldAnimate;

#pragma mark - 키보드 액세서리 뷰 액션 메소드
- (void)previousCharacterButtonPressed:(id)sender;
- (void)nextCharacterButtonPressed:(id)sender;
- (void)hideKeyboardButtonPressed:(id)sender;
- (void)hashButtonPressed:(id)sender;
- (void)asteriskButtonPressed:(id)sender;
- (void)tabButtonPressed:(id)sender;
- (void)selectWordButonPressed:(id)sender;
- (void)angleBracketButtonPressed:(id)sender;
- (void)exclamationMarkButtonPressed:(id)sender;


@end