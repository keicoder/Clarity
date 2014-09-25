/**
* ICTextView.m - 1.0.2
**/

#import "ICTextView.h"
#import <QuartzCore/QuartzCore.h>
#include <tgmath.h>

// Document subview tag
enum
{
    ICTagTextSubview = 181337
};


// Private iVars
@interface ICTextView ()
{
    // Highlights
    NSMutableDictionary *_highlightsByRange;
    NSMutableArray *_primaryHighlights;
    NSMutableOrderedSet *_secondaryHighlights;
    
    // Work variables
    NSRegularExpression *_regex;
    NSTimer *_autoRefreshTimer;
    NSRange _searchRange;
    NSUInteger _scanIndex;
    BOOL _performedNewScroll;
    BOOL _shouldUpdateScanIndex;
    
    BOOL _appliedCharacterRangeAtPointBugfix;
    
    CGRect _keyboardRect; //origin, size
}
@end


// Search results highlighting
static BOOL _highlightingSupported;



@implementation ICTextView

#pragma mark - Synthesized properties

@synthesize primaryHighlightColor = _primaryHighlightColor;
@synthesize secondaryHighlightColor = _secondaryHighlightColor;
@synthesize highlightCornerRadius = _highlightCornerRadius;
@synthesize highlightSearchResults = _highlightSearchResults;
@synthesize maxHighlightedMatches = _maxHighlightedMatches;
@synthesize scrollAutoRefreshDelay = _scrollAutoRefreshDelay;
@synthesize rangeOfFoundString = _rangeOfFoundString;


#pragma mark -
#pragma mark JTextiew

#pragma mark - 텍스트 뷰 속성

- (void)assignTextViewAttribute
{
    self.font = kTEXTVIEW_FONT;
    self.backgroundColor = kTEXTVIEW_BACKGROUND_COLOR;
    self.textColor = kTEXTVIEW_TEXT_COLOR;
    
    [[UITextView appearance] setTintColor:[UIColor colorWithRed:0.949 green:0.427 blue:0.188 alpha:1]];
    self.alwaysBounceVertical = YES;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.layer.cornerRadius = 0.0;
    self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.autocorrectionType = UITextAutocorrectionTypeYes;
    
    if (iPad) {
        self.textContainer.lineFragmentPadding = kTEXTVIEW_PADDING_IPAD;
        UIEdgeInsets contentInset = UIEdgeInsetsMake(kINSET_TOP_IPAD, kINSET_LEFT_IPAD, kINSET_BOTTOM_IPAD, kINSET_RIGHT_IPAD);
        self.contentInset = contentInset;
    } else {
        self.textContainer.lineFragmentPadding = kTEXTVIEW_PADDING;
        UIEdgeInsets contentInset = UIEdgeInsetsMake(kINSET_TOP, kINSET_LEFT, kINSET_BOTTOM, kINSET_RIGHT);
        self.contentInset = contentInset;
    }
}


#pragma mark - 텍스트 뷰

#pragma mark 텍스트 뷰 인셋 조정

- (void)updateNoteTextViewInsetWithKeyboard
{
    CGFloat scrollIndicatorInsetTop = 0.f;
    CGFloat contentInsetBottom = 0.f;
    
    if (iPad) {
        CGFloat contentInsetTop = kINSET_TOP_IPAD;
        contentInsetBottom = __tg_fmin(CGRectGetHeight(_keyboardRect), CGRectGetWidth(_keyboardRect));
        UIEdgeInsets contentInset = UIEdgeInsetsMake(contentInsetTop, kINSET_LEFT_IPAD, contentInsetBottom, kINSET_RIGHT_IPAD);
        self.contentInset = contentInset;
        self.scrollIndicatorInsets = UIEdgeInsetsMake(scrollIndicatorInsetTop, kINSET_LEFT_IPAD, contentInsetBottom, kINSET_RIGHT_IPAD);
    } else {
        CGFloat contentInsetTop = kINSET_TOP;
        contentInsetBottom = __tg_fmin(CGRectGetHeight(_keyboardRect), CGRectGetWidth(_keyboardRect));
        UIEdgeInsets contentInset = UIEdgeInsetsMake(contentInsetTop, kINSET_LEFT, contentInsetBottom, kINSET_RIGHT);
        self.contentInset = contentInset;
        self.scrollIndicatorInsets = UIEdgeInsetsMake(scrollIndicatorInsetTop, kINSET_LEFT, contentInsetBottom, kINSET_RIGHT);
    }
}


- (void)updateNoteTextViewInsetWithoutKeyboard
{
    CGFloat contentInsetTop = 0.f;
    CGFloat scrollIndicatorInsetTop = contentInsetTop;
    CGFloat contentInsetBottom = 0.f;
    
    if (iPad) {
        UIEdgeInsets contentInset = UIEdgeInsetsMake(kINSET_TOP_IPAD, kINSET_LEFT_IPAD, kINSET_BOTTOM_IPAD, kINSET_RIGHT_IPAD);
        self.contentInset = contentInset;
        self.scrollIndicatorInsets = UIEdgeInsetsMake(scrollIndicatorInsetTop, kINSET_LEFT_IPAD, contentInsetBottom, kINSET_RIGHT_IPAD);
    } else {
        UIEdgeInsets contentInset = UIEdgeInsetsMake(kINSET_TOP, kINSET_LEFT, kINSET_BOTTOM, kINSET_RIGHT);
        self.contentInset = contentInset;
        self.scrollIndicatorInsets = UIEdgeInsetsMake(scrollIndicatorInsetTop, kINSET_LEFT, contentInsetBottom, kINSET_RIGHT);
    }
}



#pragma mark 키보드 반응

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfoDictionary = notification.userInfo;
    CGFloat duration = [[userInfoDictionary objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //int curve = [[userInfoDictionary objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    _keyboardRect = [[userInfoDictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{ 
                        [self updateNoteTextViewInsetWithKeyboard];
                    } completion:^(BOOL finished) {
                        [self scrollToVisibleCaretAnimated];
                    }];
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfoDictionary = notification.userInfo;
    CGFloat duration = [[userInfoDictionary objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[userInfoDictionary objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    _keyboardRect = [[userInfoDictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //NSLog (@"_keyboardRect: %@", NSStringFromCGRect(_keyboardRect));
    
    [UIView animateWithDuration:kMOVE_TEXT_POSITION_DURATION delay:duration options:curve animations:^
    {
        [self updateNoteTextViewInsetWithoutKeyboard];      //텍스트 뷰 인셋 조정
    } 
    completion:^(BOOL finished) { }];
}


- (void)keyboardDidHide:(NSNotification *)notification
{
    
}


#pragma mark JTextiew 캐럿 위치 이동 (사용하지 않음 > 아래 PSPDFTextView > scrollToVisibleCaretAnimated로 대체)

- (void)moveTextPositionAboveKeyboard:(UITextView *)textView withAnimation:(BOOL)shouldAnimate
{
    CGRect line = [textView caretRectForPosition: textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
    CGPoint offset = textView.contentOffset;
    if ( overflow > 0 ) {
        offset.y += overflow;
        [UIView animateWithDuration:0.2 animations:^{
            //[textView setContentOffset:offset];
            [self scrollToVisibleCaretAnimated];
        }];
    }
}


#pragma mark -
#pragma mark PSPDFTextView 

#pragma mark - 캐럿 위치 이동 (위 JTextiew 캐럿 위치 이동 대체)

- (void)scrollToVisibleCaretAnimated 
{
    [UIView animateWithDuration:0.2 animations:^
    {
        [self scrollRectToVisibleConsideringInsets:[self caretRectForPosition:self.selectedTextRange.end] animated:NO];
    }];
}


- (void)scrollRectToVisibleConsideringInsets:(CGRect)rect animated:(BOOL)animated 
{
    // Don't scroll if rect is currently visible.
    UIEdgeInsets insets = UIEdgeInsetsMake(self.contentInset.top + self.textContainerInset.top,
                                           self.contentInset.left + self.textContainerInset.left,
                                           self.contentInset.bottom + self.textContainerInset.bottom,
                                           self.contentInset.right + self.textContainerInset.right);
    CGRect visibleRect = UIEdgeInsetsInsetRect(self.bounds, insets);
    if (!CGRectContainsRect(visibleRect, rect)) {
        CGPoint contentOffset = self.contentOffset;                 // Calculate new content offset.
        if (CGRectGetMinY(rect) < CGRectGetMinY(visibleRect)) {
            contentOffset.y = CGRectGetMinY(rect) - insets.top;     // scroll up
        } else {                                                    // scroll down
            contentOffset.y = CGRectGetMaxY(rect) + insets.bottom - CGRectGetHeight(self.bounds); 
        }
        [self setContentOffset:contentOffset animated:animated];
    }
}


#pragma mark -
#pragma mark JTextiew

#pragma mark - delegate method (change text, editing)

- (void)textViewDidChange:(UITextView *)textView
{
    //[self moveTextPositionAboveKeyboard:self withAnimation:YES];    //캐럿 위치 조정
    [self scrollToVisibleCaretAnimated];                            //PSPDFTextView 캐럿 위치 이동
}


#pragma mark 

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //self.selectedRange = self.curSelectedRange;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    //self.curSelectedRange = self.selectedRange;
    [textView resignFirstResponder];
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}


#pragma mark delegate method (change selection, text)

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}


- (void)textViewDidChangeSelection:(UITextView *)textView
{ 
    
}


#pragma mark - Undo Redo

- (void)undoButtonPressed:(id)sender {
    [[self undoManager] undo];
}


- (void)redoButtonPressed:(id)sender {
    [[self undoManager] redo];
}


#pragma mark - 스트링 메소드

- (void)goToPreviousWord:(UITextView *)textView
{
    NSRange selectedRange = textView.selectedRange;
    NSInteger currentLocation = selectedRange.location;
    
    if ( currentLocation == 0 ) {
        return;
    }
    
    NSRange newRange = [textView.text
                        rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                        options:NSBackwardsSearch
                        range:NSMakeRange(0, (currentLocation - 1))];
    
    if ( newRange.location != NSNotFound ) {
        
        textView.selectedRange = NSMakeRange((newRange.location + 1), 0);
        
    } else {
        
        textView.selectedRange = NSMakeRange(0, 0);
    }
}



- (void)goToPreviousChar:(UITextView *)textView
{
    UITextRange *selectedRange = [textView selectedTextRange];
    //Calculate the new position, - for left and + for right
    
    if (textView.selectedRange.location > 0) {
        UITextPosition *newPosition = [textView positionFromPosition:selectedRange.start offset:-1];
        
        UITextRange *newRange = [textView textRangeFromPosition:newPosition toPosition:newPosition];
        
        //Set new range
        [textView setSelectedTextRange:newRange];
    }
}


- (void)tagHash:(UITextView *)textView
{
//    //기존 메소드
//    UITextRange *selectedRange = [self selectedTextRange];
//    
//    //if (selectedRange == nil) { } //no selection or insertion point
//    if (selectedRange.empty) { [self addTextOnSelectedRange:@"#"]; }
//    else { [self addTextOnSelectedRange:@"#"]; }
    
    //대체 메소드
    // Find the range of the selected text
	NSRange range = self.selectedRange;
	
	// Get the relevant strings
	NSString *firstHalfString = [self.text substringToIndex:range.location];
	NSString *insertingString = @"#";
	NSString *secondHalfString = [self.text substringFromIndex:range.location+range.length];
	
	// Update the textView's text
	self.scrollEnabled = NO;
	self.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
	self.scrollEnabled = YES;
    
	// More the selection to after our inserted text
	range.location += insertingString.length;
	range.length = 0;
	self.selectedRange = range;
}


- (void)tagAsterisk:(UITextView *)textView
{
    UITextRange *selectedRange = [self selectedTextRange];
    
    //if (selectedRange == nil) { } //no selection or insertion point
    if (selectedRange.empty) { [self addTextOnSelectedRange:@"*"]; }
    else { [self addTextBothSidesOnSelectedRange:@"*"]; }
}


- (void)tagGreaterThan:(UITextView *)textView
{
    UITextRange *selectedRange = [self selectedTextRange];
    
    //if (selectedRange == nil) { } //no selection or insertion point
    if (selectedRange.empty) { [self addTextOnSelectedRange:@">"]; }
    else { [self addTextOnSelectedRange:@">"]; }
}


- (void)selectWord:(UITextView *)textView
{
    NSRange selectedRange = textView.selectedRange;

    if (![self hasText])
    {
        [textView select:self];
    }
    
    else if ([self hasText] && selectedRange.length == 0) 
    {
        [textView select:self];
    } 
    
    else if ([self hasText] && selectedRange.length > 0)  
    {
        selectedRange.location = selectedRange.location + selectedRange.length;
        selectedRange.length = 0;
        textView.selectedRange = selectedRange;
    }
    
    [self calculateSelectedTextRange];
    
    [self cursorPosition];
}


- (void)selectParagraph:(UITextView *)textView
{
    [self cursorPosition];
    
    NSRange selectedRange = textView.selectedRange;
    
    if (![self hasText])
    {
        [textView select:self];
    }
    
    else if ([self hasText] && selectedRange.length == 0) 
    {
        [textView select:self];
        NSRange selectedRange = [self firstParagraphRangeFromTextRange:self.selectedRange];
        [self setSelectedRange:selectedRange];
    }
    
    else if ([self hasText] && selectedRange.length > 0) 
    {
        selectedRange.location = selectedRange.location + selectedRange.length;
        selectedRange.length = 0;
        textView.selectedRange = selectedRange;
    }
    
    [self calculateSelectedTextRange];
}

//
//- (void)selectAll:(UITextView *)textView
//{
//    [self selectAll:self];
//}


- (void)keyboardDown:(UITextView *)textView
{
    [textView resignFirstResponder];
}



- (void)goToNextChar:(UITextView *)textView
{
    UITextRange *selectedRange = [textView selectedTextRange];
    //Calculate the new position, - for left and + for right
    
    if (textView.selectedRange.location < textView.text.length) {
        UITextPosition *newPosition = [textView positionFromPosition:selectedRange.start offset:1];
        
        UITextRange *newRange = [textView textRangeFromPosition:newPosition toPosition:newPosition];
        
        //Set new range
        [textView setSelectedTextRange:newRange];
    }
    
    [self moveTextPositionAboveKeyboard:textView withAnimation:YES];
}



- (void)goToNextWord:(UITextView *)textView
{
    NSRange selectedRange = textView.selectedRange;
    NSInteger currentLocation = selectedRange.location + selectedRange.length;
    NSInteger textLength = [textView.text length];
    
    if ( currentLocation == textLength ) {
        return;
    }
    
    NSRange newRange = [textView.text
                        rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                        options:NSCaseInsensitiveSearch
                        range:NSMakeRange((currentLocation + 1), (textLength - 1 - currentLocation))];
    
    if ( newRange.location != NSNotFound ) {
        textView.selectedRange = NSMakeRange(newRange.location, 0);
    } else {
        textView.selectedRange = NSMakeRange(textLength, 0);
    }
    
    [self moveTextPositionAboveKeyboard:textView withAnimation:YES];
}


#pragma mark 텍스트 Appending

- (void)addTextOnSelectedRange:(NSString *)text 
{
    UITextRange *selectedTextRange = [self selectedTextRange];
    
    NSRange selectedRange = self.selectedRange;
    NSString *textFromRange = [self textFromRange:selectedRange];
    NSLog (@"texts from substringWithRange are: %@\n", textFromRange);
    
    if (0 == self.selectedRange.length) 
    {
        [self replaceRange:selectedTextRange withText:text];
        self.selectedRange = NSMakeRange(self.selectedRange.location, 0);
    } 
    else 
    {
        NSString *selectedText = [self textFromRange:self.selectedRange];
        NSString *textToChange = [NSString stringWithFormat:@"%@%@", text, selectedText];
        [self replaceRange:selectedTextRange withText:textToChange];
        self.selectedRange = NSMakeRange(self.selectedRange.location + text.length - text.length, 0);
    }
}


- (void)addTextBothSidesOnSelectedRange:(NSString *)text 
{
    UITextRange *selectedTextRange = [self selectedTextRange];
    
    NSRange selectedRange = self.selectedRange;
    NSString *textFromRange = [self textFromRange:selectedRange];
    NSLog (@"texts from substringWithRange are: %@\n", textFromRange);
    
    if (0 == self.selectedRange.length) 
    {
        [self replaceRange:selectedTextRange withText:text];
        self.selectedRange = NSMakeRange(self.selectedRange.location, 0);
    } 
    else 
    {
        NSString *selectedText = [self textFromRange:self.selectedRange];
        NSString *textToChange = [NSString stringWithFormat:@"%@%@%@", text, selectedText, text];
        [self replaceRange:selectedTextRange withText:textToChange];
        self.selectedRange = NSMakeRange(self.selectedRange.location + text.length - text.length, 0);
    }
}


- (NSString *)textFromRange:(NSRange)range 
{
    return [self.text substringWithRange:range];
}


#pragma mark 단락 (Paragraph) 가져오기

- (NSRange)firstParagraphRangeFromTextRange:(NSRange)range
{
	NSInteger start = -1;
	NSInteger end = -1;
	NSInteger length = 0;
	
	NSInteger startingRange = (range.location == self.text.length || [self.text characterAtIndex:range.location] == '\n') ?
    range.location-1 :
    range.location;
	
	for (int i=(int)startingRange ; i>=0 ; i--)
	{
		char c = [self.text characterAtIndex:i];
		if (c == '\n')
		{
			start = i+1;
			break;
		}
	}
	
	start = (start == -1) ? 0 : start;
	
	NSInteger moveForwardIndex = (range.location > start) ? range.location : start;
	
	for (int i=(int)moveForwardIndex; i<= self.text.length-1 ; i++)
	{
		char c = [self.text characterAtIndex:i];
		if (c == '\n')
		{
			end = i;
			break;
		}
	}
	
	end = (end == -1) ? self.text.length : end;
	length = end - start;
	
	return NSMakeRange(start, length);
}


#pragma mark 커서 포지션

- (CGPoint)cursorPosition;
{
    CGPoint cursorPosition = [self caretRectForPosition:self.selectedTextRange.start].origin;
    //NSLog (@": cursorPosition.x %f, cursorPosition.y %f\n", cursorPosition.x, cursorPosition.y);
    return cursorPosition;
}


#pragma mark Calculate Selected Text Range

- (void)calculateSelectedTextRange
{
    long start = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSLog (@"self.selectedTextRange.start: %ld\n", start);
    long end = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.end];
    NSLog (@"self.selectedTextRange.end: %ld\n", end);
}


#pragma mark Range Of Paragraphs From TextRange

- (NSArray *)rangeOfParagraphsFromTextRange:(NSRange)textRange
{
	NSMutableArray *paragraphRanges = [NSMutableArray array];
	NSInteger rangeStartIndex = textRange.location;
	
	while (true)
	{
		NSRange range = [self firstParagraphRangeFromTextRange:NSMakeRange(rangeStartIndex, 0)];
		rangeStartIndex = range.location + range.length + 1;
		
		[paragraphRanges addObject:[NSValue valueWithRange:range]];
		
		if (range.location + range.length >= textRange.location + textRange.length)
			break;
	}
	
    NSLog (@":paragraphRanges > %@\n", paragraphRanges);
	return paragraphRanges;
}


#pragma mark -
#pragma mark ICTextiew

#pragma mark -
#pragma mark 초기화

#pragma mark Class methods

+ (void)initialize
{
    if (self == [ICTextView class])
        _highlightingSupported = [self conformsToProtocol:@protocol(UITextInput)];
}


// Convenience method used in init overrides
- (void)initialize
{
    _highlightCornerRadius = -1.0;
    _highlightsByRange = [[NSMutableDictionary alloc] init];
    _highlightSearchResults = YES;
    _maxHighlightedMatches = 100;
    _scrollAutoRefreshDelay = 0.2;
    _primaryHighlights = [[NSMutableArray alloc] init];
    _primaryHighlightColor = [UIColor colorWithRed:150.0/255.0 green:200.0/255.0 blue:1.0 alpha:1.0];
    _secondaryHighlights = [[NSMutableOrderedSet alloc] init];
    _secondaryHighlightColor = [UIColor colorWithRed:215.0/255.0 green:240.0/255.0 blue:1.0 alpha:1.0];
    
    // Detects _UITextContainerView or UIWebDocumentView (subview with text) for highlight placement
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"_UITextContainerView")] || [view isKindOfClass:NSClassFromString(@"UIWebDocumentView")])
        {
            view.tag = ICTagTextSubview;
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}


// Initializes highlights
- (void)initializeHighlights
{
    [self initializePrimaryHighlights];
    [self initializeSecondaryHighlights];
}


// Initializes primary highlights
- (void)initializePrimaryHighlights
{
    // Moves primary highlights to secondary highlights array
    for (UIView *hl in _primaryHighlights)
    {
        hl.backgroundColor = _secondaryHighlightColor;
        [_secondaryHighlights addObject:hl];
    }
    [_primaryHighlights removeAllObjects];
}


// Initializes secondary highlights
- (void)initializeSecondaryHighlights
{
    // Removes secondary highlights from their superview
    for (UIView *hl in _secondaryHighlights)
        [hl removeFromSuperview];
    [_secondaryHighlights removeAllObjects];
    
    // Removes all objects in _highlightsByRange, eventually except _rangeOfFoundString (primary)
    if (_primaryHighlights.count)
    {
        NSValue *rangeValue = [NSValue valueWithRange:_rangeOfFoundString];
        NSMutableArray *primaryHighlights = [_highlightsByRange objectForKey:rangeValue];
        [_highlightsByRange removeAllObjects];
        [_highlightsByRange setObject:primaryHighlights forKey:rangeValue];
    }
    else
        [_highlightsByRange removeAllObjects];
    
    // Sets _performedNewScroll status in order to refresh the highlights
    _performedNewScroll = YES;
}


- (void)characterRangeAtPointBugFix
{
    [self select:self];
    [self setSelectedTextRange:nil];
    _appliedCharacterRangeAtPointBugfix = YES;
}


// Called when scroll animation has ended
- (void)scrollEnded
{
    // Refreshes highlights
    [self highlightOccurrencesInMaskedVisibleRange];
    
    // Disables auto-refresh timer
    [_autoRefreshTimer invalidate];
    _autoRefreshTimer = nil;
    
    // scrollView has finished scrolling
    _performedNewScroll = NO;
}


// Sets primary highlight
- (void)setPrimaryHighlightAtRange:(NSRange)range
{
    [self initializePrimaryHighlights];
    NSValue *rangeValue = [NSValue valueWithRange:range];
    NSMutableArray *highlightsForRange = [_highlightsByRange objectForKey:rangeValue];
    
    for (UIView *hl in highlightsForRange)
    {
        hl.backgroundColor = _primaryHighlightColor;
        [_primaryHighlights addObject:hl];
        [_secondaryHighlights removeObject:hl];
    }
}


- (void)textChanged
{
    UITextRange *selectedTextRange = self.selectedTextRange;
    if (selectedTextRange)
        [self scrollRectToVisible:[self caretRectForPosition:selectedTextRange.end] animated:NO consideringInsets:YES];
}


#pragma mark - Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && !_appliedCharacterRangeAtPointBugfix)
        [self characterRangeAtPointBugFix];
}


//// Resets search if editable
//- (BOOL)becomeFirstResponder
//{
////    if (self.editable)
////        [self resetSearch];
////    return [super becomeFirstResponder];
//}


// Init overrides for custom initialization
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self && _highlightingSupported)
        [self initialize];
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame textContainer:nil];
}


- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    [textStorage addLayoutManager:layoutManager];
    
    if (!textContainer)
    {
        textContainer = [[NSTextContainer alloc] initWithSize:frame.size];
    }
    
    textContainer.heightTracksTextView = YES;
    
    [layoutManager addTextContainer:textContainer];
    
    self = [super initWithFrame:frame textContainer:textContainer];
    
    if (self && _highlightingSupported)
    {
        [self initialize];
    }
    
    [self assignTextViewAttribute];
    
    return self;
}


// Executed while scrollView is scrolling
- (void)setContentOffset:(CGPoint)contentOffset textView:(UITextView *)textView
{
    [super setContentOffset:contentOffset];
    if (_highlightingSupported && _highlightSearchResults)
    {
        // scrollView has scrolled
        _performedNewScroll = YES;
        
        // _shouldUpdateScanIndex check
        if (!_shouldUpdateScanIndex)
            _shouldUpdateScanIndex = ([self.panGestureRecognizer velocityInView:self].y != 0.0);
        
        // Eventually starts auto-refresh timer
        if (_regex && _scrollAutoRefreshDelay && !_autoRefreshTimer)
        {
            _autoRefreshTimer = [NSTimer timerWithTimeInterval:_scrollAutoRefreshDelay target:self selector:@selector(highlightOccurrencesInMaskedVisibleRange) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_autoRefreshTimer forMode:UITrackingRunLoopMode];
        }
        
        // Cancels previous request and performs new one
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollEnded) object:nil];
        [self performSelector:@selector(scrollEnded) withObject:nil afterDelay:0.1];
    }
}


// Resets highlights on frame change
- (void)setFrame:(CGRect)frame
{
    if (_highlightingSupported && _highlightsByRange.count)
        [self initializeHighlights];
    [super setFrame:frame];
}


// Doesn't allow _scrollAutoRefreshDelay values between 0.0 and 0.1
- (void)setScrollAutoRefreshDelay:(NSTimeInterval)scrollAutoRefreshDelay
{
    _scrollAutoRefreshDelay = (scrollAutoRefreshDelay > 0.0 && scrollAutoRefreshDelay < 0.1) ? 0.1 : scrollAutoRefreshDelay;
}


- (void)setSelectedTextRange:(UITextRange *)selectedTextRange
{
    [super setSelectedTextRange:selectedTextRange];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && selectedTextRange)
        [self scrollRectToVisible:[self caretRectForPosition:selectedTextRange.end] animated:NO consideringInsets:YES];
}


- (void)setText:(NSString *)text
{
    [super setText:text];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && !_appliedCharacterRangeAtPointBugfix && text.length > 1)
        [self characterRangeAtPointBugFix];
}


#pragma mark - Private methods

// Adds highlight at rect (returns highlight UIView)
- (UIView *)addHighlightAtRect:(CGRect)frame
{
    UIView *highlight = [[UIView alloc] initWithFrame:frame];
    highlight.layer.cornerRadius = _highlightCornerRadius < 0.0 ? frame.size.height * 0.2 : _highlightCornerRadius;
    highlight.backgroundColor = _secondaryHighlightColor;
    [_secondaryHighlights addObject:highlight];
    [self insertSubview:highlight belowSubview:[self viewWithTag:ICTagTextSubview]];
    return highlight;
}

// Adds highlight at text range (returns array of highlights for text range)
- (NSMutableArray *)addHighlightAtTextRange:(UITextRange *)textRange
{
    NSMutableArray *highlightsForRange = [[NSMutableArray alloc] init];
    
    CGRect previousRect = CGRectZero;
    NSArray *highlightRects = [self selectionRectsForRange:textRange];
    
    // Merges adjacent rects
    for (UITextSelectionRect *selectionRect in highlightRects)
    {
        CGRect currentRect = selectionRect.rect;
        if ((currentRect.origin.y == previousRect.origin.y) && (currentRect.origin.x == CGRectGetMaxX(previousRect)) && (currentRect.size.height == previousRect.size.height))
        {
            // Adjacent, add to previous rect
            previousRect = CGRectMake(previousRect.origin.x, previousRect.origin.y, previousRect.size.width + currentRect.size.width, previousRect.size.height);
        }
        else
        {
            // Not adjacent, add previous rect to highlights array
            [highlightsForRange addObject:[self addHighlightAtRect:previousRect]];
            previousRect = currentRect;
        }
    }
    // Adds last highlight
    [highlightsForRange addObject:[self addHighlightAtRect:previousRect]];
    
    return highlightsForRange;
}

// Highlights occurrences of found string in visible range masked by the user specified range
- (void)highlightOccurrencesInMaskedVisibleRange
{
    // Regex search
    if (_regex)
    {
        if (_performedNewScroll)
        {
            // Initial data
            UITextPosition *visibleStartPosition;
            NSRange visibleRange = [self visibleRangeConsideringInsets:YES startPosition:&visibleStartPosition endPosition:NULL];
            
            // Performs search in masked range
            NSRange maskedRange = NSIntersectionRange(_searchRange, visibleRange);
            NSMutableArray *rangeValues = [[NSMutableArray alloc] init];
            [_regex enumerateMatchesInString:self.text options:0 range:maskedRange usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                NSValue *rangeValue = [NSValue valueWithRange:match.range];
                [rangeValues addObject:rangeValue];
            }];
            
            ///// ADDS SECONDARY HIGHLIGHTS /////
            
            // Array must have elements
            if (rangeValues.count)
            {
                // Removes already present highlights
                NSMutableArray *rangesArray = [rangeValues mutableCopy];
                NSMutableIndexSet *indexesToRemove = [[NSMutableIndexSet alloc] init];
                [rangeValues enumerateObjectsUsingBlock:^(NSValue *rangeValue, NSUInteger idx, BOOL *stop){
                    if ([_highlightsByRange objectForKey:rangeValue])
                        [indexesToRemove addIndex:idx];
                }];
                [rangesArray removeObjectsAtIndexes:indexesToRemove];
                indexesToRemove = nil;
                
                // Filtered array must have elements
                if (rangesArray.count)
                {
                    // Gets text range of first result
                    NSValue *firstRangeValue = [rangesArray objectAtIndex:0];
                    NSRange previousRange = [firstRangeValue rangeValue];
                    UITextPosition *start = [self positionFromPosition:visibleStartPosition offset:(previousRange.location - visibleRange.location)];
                    UITextPosition *end = [self positionFromPosition:start offset:previousRange.length];
                    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
                    
                    // First range
                    [_highlightsByRange setObject:[self addHighlightAtTextRange:textRange] forKey:firstRangeValue];
                    
                    if (rangesArray.count > 1)
                    {
                        // Loops through ranges
                        for (NSUInteger idx = 1; idx < rangesArray.count; idx++)
                        {
                            NSValue *rangeValue = [rangesArray objectAtIndex:idx];
                            NSRange range = [rangeValue rangeValue];
                            start = [self positionFromPosition:end offset:range.location - (previousRange.location + previousRange.length)];
                            end = [self positionFromPosition:start offset:range.length];
                            textRange = [self textRangeFromPosition:start toPosition:end];
                            [_highlightsByRange setObject:[self addHighlightAtTextRange:textRange] forKey:rangeValue];
                            previousRange = range;
                        }
                    }
                    
                    // Memory management
                    NSInteger remaining = _maxHighlightedMatches - _highlightsByRange.count;
                    if (remaining < 0)
                    {
                        NSInteger tempMin = visibleRange.location - visibleRange.length;
                        NSUInteger min = tempMin > 0 ? tempMin : 0;
                        NSUInteger max = min + 3 * visibleRange.length;
                        // Scans highlighted ranges
                        NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
                        [_highlightsByRange enumerateKeysAndObjectsUsingBlock:^(NSValue *rangeValue, NSArray *highlightsForRange, BOOL *stop){
                            
                            // Removes ranges too far from visible range
                            NSUInteger location = [rangeValue rangeValue].location;
                            if ((location < min || location > max) && location != _rangeOfFoundString.location)
                            {
                                for (UIView *hl in highlightsForRange)
                                {
                                    [hl removeFromSuperview];
                                    [_secondaryHighlights removeObject:hl];
                                }
                                [keysToRemove addObject:rangeValue];
                            }
                        }];
                        [_highlightsByRange removeObjectsForKeys:keysToRemove];
                    }
                }
            }
            
            // Eventually updates _scanIndex to match visible range
            if (_shouldUpdateScanIndex)
                _scanIndex = visibleRange.location + (_regex ? visibleRange.length : 0);
        }
        
        // Sets primary highlight
        [self setPrimaryHighlightAtRange:_rangeOfFoundString];
    }
}


#pragma mark - Public methods

#pragma mark -- Search --

// Returns string found during last search
- (NSString *)foundString
{
    return [self.text substringWithRange:_rangeOfFoundString];
}


// Resets search, starts from top
- (void)resetSearch
{
    if (_highlightingSupported)
    {
        [self initializeHighlights];
        [_autoRefreshTimer invalidate];
        _autoRefreshTimer = nil;
    }
    _rangeOfFoundString = NSMakeRange(0,0);
    _regex = nil;
    _scanIndex = 0;
    _searchRange = NSMakeRange(0,0);
}


#pragma mark ---- Regex search ----

// Scroll to regex match (returns YES if found, NO otherwise)

- (BOOL)scrollToMatch:(NSString *)pattern
{
    return [self scrollToMatch:pattern searchOptions:0 range:NSMakeRange(0, self.text.length)];
}

- (BOOL)scrollToMatch:(NSString *)pattern searchOptions:(NSRegularExpressionOptions)options
{
    return [self scrollToMatch:pattern searchOptions:options range:NSMakeRange(0, self.text.length)];
}

- (BOOL)scrollToMatch:(NSString *)pattern searchOptions:(NSRegularExpressionOptions)options range:(NSRange)range
{
    // Calculates a valid range
    range = NSIntersectionRange(NSMakeRange(0, self.text.length), range);
    
    // Preliminary checks
    BOOL abort = NO;
    if (!pattern)
    {
#if DEBUG
        NSLog(@"Pattern cannot be nil.");
#endif
        abort = YES;
    }
    else if (range.length == 0)
    {
#if DEBUG
        NSLog(@"Specified range is out of bounds.");
#endif
        abort = YES;
    }
    if (abort)
    {
        [self resetSearch];
        return NO;
    }
    
    // Optimization and coherence checks
    BOOL samePattern = [pattern isEqualToString:_regex.pattern];
    BOOL sameOptions = (options == _regex.options);
    BOOL sameSearchRange = NSEqualRanges(range, _searchRange);
    
    // Sets new search range
    _searchRange = range;
    
    // Creates regex
    NSError *error;
    _regex = [[NSRegularExpression alloc] initWithPattern:pattern options:options error:&error];
    if (error)
    {
#if DEBUG
        NSLog(@"Error while creating regex: %@", error);
#endif
        [self resetSearch];
        return NO;
    }
    
    // Resets highlights
    if (_highlightingSupported && _highlightSearchResults)
    {
        [self initializePrimaryHighlights];
        if (!(samePattern && sameOptions && sameSearchRange))
            [self initializeSecondaryHighlights];
    }
    
    // Scan index logic
    if (sameSearchRange && sameOptions)
    {
        // Same search pattern, go to next match
        if (samePattern)
            _scanIndex += _rangeOfFoundString.length;
        // Scan index out of range
        if (_scanIndex < range.location || _scanIndex >= (range.location + range.length))
            _scanIndex = range.location;
    }
    else
        _scanIndex = range.location;
    
    // Gets match
    NSRange matchRange = [_regex rangeOfFirstMatchInString:self.text options:0 range:NSMakeRange(_scanIndex, range.location + range.length - _scanIndex)];
    
    // Match not found
    if (matchRange.location == NSNotFound)
    {
        _rangeOfFoundString = NSMakeRange(NSNotFound, 0);
        if (_scanIndex)
        {
            // Starts from top
            _scanIndex = range.location;
            return [self scrollToMatch:pattern searchOptions:options range:range];
        }
        _regex = nil;
        return NO;
    }
    
    // Match found, saves state
    _rangeOfFoundString = matchRange;
    _scanIndex = matchRange.location;
    _shouldUpdateScanIndex = NO;
    
    // Adds highlights
    if (_highlightingSupported && _highlightSearchResults)
        [self highlightOccurrencesInMaskedVisibleRange];
    
    // Scrolls
    [self scrollRangeToVisible:matchRange consideringInsets:YES];
    
    return YES;
}


#pragma mark ---- String search ----

// Scroll to string (returns YES if found, NO otherwise)

- (BOOL)scrollToString:(NSString *)stringToFind
{
    return [self scrollToString:stringToFind searchOptions:0 range:NSMakeRange(0, self.text.length)];
}

- (BOOL)scrollToString:(NSString *)stringToFind searchOptions:(NSRegularExpressionOptions)options
{
    return [self scrollToString:stringToFind searchOptions:options range:NSMakeRange(0, self.text.length)];
}

- (BOOL)scrollToString:(NSString *)stringToFind searchOptions:(NSRegularExpressionOptions)options range:(NSRange)range
{
    // Preliminary check
    if (!stringToFind)
    {
#if DEBUG
        NSLog(@"Search string cannot be nil.");
#endif
        [self resetSearch];
        return NO;
    }
    
    // Escapes metacharacters
    stringToFind = [NSRegularExpression escapedPatternForString:stringToFind];
    
    // These checks allow better automatic search on UITextField or UISearchBar text change
    if (_regex)
    {
        NSString *lcStringToFind = [stringToFind lowercaseString];
        NSString *lcFoundString = [_regex.pattern lowercaseString];
        if (!([lcStringToFind hasPrefix:lcFoundString] || [lcFoundString hasPrefix:lcStringToFind]))
            _scanIndex += _rangeOfFoundString.length;
    }
    
    // Performs search
    return [self scrollToMatch:stringToFind searchOptions:options range:range];
}


#pragma mark -- Misc --

// Scrolls to visible range, eventually considering insets
- (void)scrollRangeToVisible:(NSRange)range consideringInsets:(BOOL)considerInsets
{
    // Calculates rect for range
    UITextPosition *startPosition = [self positionFromPosition:self.beginningOfDocument offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:startPosition offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    CGRect rect = [self firstRectForRange:textRange];
    
    
    [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Scrolls to visible rect
                         [self scrollRectToVisible:rect animated:YES consideringInsets:YES];
                     }
                     completion:^(BOOL finished) { }];
    // Scrolls to visible rect
    //[self scrollRectToVisible:rect animated:YES consideringInsets:YES];
}


// Scrolls to visible rect, eventually considering insets
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated consideringInsets:(BOOL)considerInsets
{
    // Gets bounds and calculates visible rect
    CGRect bounds = self.bounds;
    UIEdgeInsets contentInset = self.contentInset;
    CGRect visibleRect = [self visibleRectConsideringInsets:YES];
    
    // Do not scroll if rect is on screen
    if (!CGRectContainsRect(visibleRect, rect))
    {
        CGPoint contentOffset = self.contentOffset;
        // Calculates new contentOffset
        if (rect.origin.y < visibleRect.origin.y)
            // rect precedes bounds, scroll up
            contentOffset.y = rect.origin.y - contentInset.top;
        else
            // rect follows bounds, scroll down
            contentOffset.y = rect.origin.y + contentInset.bottom + rect.size.height - bounds.size.height;
        
        [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // Scrolls to visible rect
                             //[self setContentOffset:contentOffset animated:animated];
                         }
                         completion:^(BOOL finished) { }];
        //[self setContentOffset:contentOffset animated:animated];
    }
}


// Returns visible range, eventually considering insets
- (NSRange)visibleRangeConsideringInsets:(BOOL)considerInsets
{
    return [self visibleRangeConsideringInsets:considerInsets startPosition:NULL endPosition:NULL];
}


// Returns visible range, with start and end position, eventually considering insets
- (NSRange)visibleRangeConsideringInsets:(BOOL)considerInsets startPosition:(UITextPosition *__autoreleasing *)startPosition endPosition:(UITextPosition *__autoreleasing *)endPosition
{
    CGRect visibleRect = [self visibleRectConsideringInsets:considerInsets];
    CGPoint startPoint = visibleRect.origin;
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(visibleRect), CGRectGetMaxY(visibleRect));
    
    UITextPosition *start = [self characterRangeAtPoint:startPoint].start;
    UITextPosition *end = [self characterRangeAtPoint:endPoint].end;
    
    if (startPosition)
        *startPosition = start;
    if (endPosition)
        *endPosition = end;
    
    return NSMakeRange([self offsetFromPosition:self.beginningOfDocument toPosition:start], [self offsetFromPosition:start toPosition:end]);
}


// Returns visible rect, eventually considering insets
- (CGRect)visibleRectConsideringInsets:(BOOL)considerInsets
{
    CGRect bounds = self.bounds;
    if (considerInsets)
    {
        UIEdgeInsets contentInset = self.contentInset;
        CGRect visibleRect = self.bounds;
        visibleRect.origin.x += contentInset.left;
        visibleRect.origin.y += contentInset.top;
        visibleRect.size.width -= (contentInset.left + contentInset.right);
        visibleRect.size.height -= (contentInset.top + contentInset.bottom);
        return visibleRect;
    }
    return bounds;
}


#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"dealloc %@", self);
    NSLog(@"ICTextView dealloced");
}


@end
