

#import "JTextView.h"

@interface JTextView ()
{
    CGRect _keyboardRect;
}
@end


@implementation JTextView


#pragma mark - 텍스트 뷰 속성

- (void)assignTextViewAttribute
{
    if (iPad) {
        self.font = kTEXTVIEW_FONT_IPAD;
    } else {
        self.font = kTEXTVIEW_FONT;
    }
    
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


#pragma mark 인셋 조정

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


#pragma mark 키보드 handle

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfoDictionary = notification.userInfo;
    CGFloat duration = [[userInfoDictionary objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]; //int curve = [[userInfoDictionary objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    _keyboardRect = [[userInfoDictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{ 
                        [self updateNoteTextViewInsetWithKeyboard];
                    } completion:^(BOOL finished) {
                        [self scrollToVisibleCaretAnimated];
                    }];
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfoDictionary = notification.userInfo;
    CGFloat duration = [[userInfoDictionary objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[userInfoDictionary objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    _keyboardRect = [[userInfoDictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:kMOVE_TEXT_POSITION_DURATION delay:duration options:curve animations:^{
        [self updateNoteTextViewInsetWithoutKeyboard];
    } completion:^(BOOL finished) { }];
}


#pragma mark - 캐럿 위치 이동

- (void)scrollToVisibleCaretAnimated 
{
    [UIView animateWithDuration:0.2 animations:^{
        [self scrollRectToVisibleConsideringInsets:[self caretRectForPosition:self.selectedTextRange.end] animated:NO];
    }];
}


- (void)scrollRectToVisibleConsideringInsets:(CGRect)rect animated:(BOOL)animated 
{
    UIEdgeInsets insets = UIEdgeInsetsMake(self.contentInset.top + self.textContainerInset.top,
                                           self.contentInset.left + self.textContainerInset.left,
                                           self.contentInset.bottom + self.textContainerInset.bottom,
                                           self.contentInset.right + self.textContainerInset.right);
    CGRect visibleRect = UIEdgeInsetsInsetRect(self.bounds, insets);
    if (!CGRectContainsRect(visibleRect, rect)) {
        CGPoint contentOffset = self.contentOffset;
        if (CGRectGetMinY(rect) < CGRectGetMinY(visibleRect)) {
            contentOffset.y = CGRectGetMinY(rect) - insets.top;     //up
        } else {
            contentOffset.y = CGRectGetMaxY(rect) + insets.bottom - CGRectGetHeight(self.bounds); //down
        }
        [super setContentOffset:contentOffset animated:animated];
    }
}


#pragma mark - Overrides

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
    
    return self;
}


#pragma mark 키보드 액세서리 뷰 액션 메소드

- (void)previousWord:(id)sender
{
    NSRange selectedRange = self.selectedRange;
    NSInteger currentLocation = selectedRange.location;
    
    if ( currentLocation == 0 ) {
        return;
    }
    
    NSRange newRange = [self.text
                        rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                        options:NSBackwardsSearch
                        range:NSMakeRange(0, (currentLocation - 1))];
    
    if ( newRange.location != NSNotFound ) {
        
        self.selectedRange = NSMakeRange((newRange.location + 1), 0);
        
    } else {
        
        self.selectedRange = NSMakeRange(0, 0);
    }
    [self scrollToVisibleCaretAnimated];
}


- (void)previousCharacter:(id)sender
{
    UITextRange *selectedRange = [self selectedTextRange];
    
    if (self.selectedRange.location > 0)
    {
        UITextPosition *newPosition = [self positionFromPosition:selectedRange.start offset:-1];
        UITextRange *newRange = [self textRangeFromPosition:newPosition toPosition:newPosition];
        [super setSelectedTextRange:newRange];
    }
    [self scrollToVisibleCaretAnimated];
}


- (void)nextWord:(id)sender
{
    NSRange selectedRange = self.selectedRange;
    NSInteger currentLocation = selectedRange.location + selectedRange.length;
    NSInteger textLength = [self.text length];
    
    if ( currentLocation == textLength ) {
        return;
    }
    
    NSRange newRange = [self.text
                        rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                        options:NSCaseInsensitiveSearch
                        range:NSMakeRange((currentLocation + 1), (textLength - 1 - currentLocation))];
    
    if ( newRange.location != NSNotFound ) {
        self.selectedRange = NSMakeRange(newRange.location, 0);
    } else {
        self.selectedRange = NSMakeRange(textLength, 0);
    }
    [self scrollToVisibleCaretAnimated];
}


- (void)nextCharacter:(id)sender
{
    UITextRange *selectedRange = [self selectedTextRange];
    
    if (self.selectedRange.location < self.text.length)
    {
        UITextPosition *newPosition = [self positionFromPosition:selectedRange.start offset:1];
        UITextRange *newRange = [self textRangeFromPosition:newPosition toPosition:newPosition];
        [super setSelectedTextRange:newRange];
    }
    [self scrollToVisibleCaretAnimated];
}


- (void)hideKeyboard:(id)sender
{
    [self resignFirstResponder];
}


- (void)addHash:(id)sender
{
    NSRange range = self.selectedRange;
    
    NSString *firstHalfString = [self.text substringToIndex:range.location];
    NSString *insertingString = @"#";
    NSString *secondHalfString = [self.text substringFromIndex:range.location+range.length];
    
    self.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
    range.location += insertingString.length;
    range.length = 0;
    self.selectedRange = range;
}


- (void)addAsterisk:(id)sender
{
    NSRange range = self.selectedRange;
    
    NSString *firstHalfString = [self.text substringToIndex:range.location];
    NSString *insertingString = @"*";
    NSString *secondHalfString = [self.text substringFromIndex:range.location+range.length];
    
    self.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
    range.location += insertingString.length;
    range.length = 0;
    self.selectedRange = range;
}


- (void)addTab:(id)sender
{
    NSRange range = self.selectedRange;
    
    NSString *firstHalfString = [self.text substringToIndex:range.location];
    NSString *insertingString = @"\t";
    NSString *secondHalfString = [self.text substringFromIndex:range.location+range.length];
    
    self.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
    range.location += insertingString.length;
    range.length = 0;
    self.selectedRange = range;
}


- (void)selectWord:(id)sender
{
    NSRange selectedRange = self.selectedRange;
    
    if (![self hasText])
    {
        [self select:self];
    }
    else if ([self hasText] && selectedRange.length == 0)
    {
        [self select:self];
    }
    else if ([self hasText] && selectedRange.length > 0)
    {
        selectedRange.location = selectedRange.location + selectedRange.length;
        selectedRange.length = 0;
        self.selectedRange = selectedRange;
    }
}


- (void)addAngleBracket:(id)sender
{
    NSRange range = self.selectedRange;
    
    NSString *firstHalfString = [self.text substringToIndex:range.location];
    NSString *insertingString = @">";
    NSString *secondHalfString = [self.text substringFromIndex:range.location+range.length];
    
    self.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
    range.location += insertingString.length;
    range.length = 0;
    self.selectedRange = range;
}


- (void)addExclamationMark:(id)sender
{
    NSRange range = self.selectedRange;
    
    NSString *firstHalfString = [self.text substringToIndex:range.location];
    NSString *insertingString = @"!";
    NSString *secondHalfString = [self.text substringFromIndex:range.location+range.length];
    
    self.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString, insertingString, secondHalfString];
    
    range.location += insertingString.length;
    range.length = 0;
    self.selectedRange = range;
}


- (void)selectParagraph:(id)sender
{
    NSRange selectedRange = self.selectedRange;
    
    if (![self hasText]) {
        [self select:self];
    }
    else if ([self hasText] && selectedRange.length == 0) {
        [self select:self];
        NSRange selectedRange = [self firstParagraphRangeFromTextRange:self.selectedRange];
        [self setSelectedRange:selectedRange];
    }
    else if ([self hasText] && selectedRange.length > 0) {
        selectedRange.location = selectedRange.location + selectedRange.length;
        selectedRange.length = 0;
        self.selectedRange = selectedRange;
    }
}


#pragma mark - 텍스트 Appending

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


#pragma mark - 단락 (Paragraph) 가져오기

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


#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"ICTextView dealloced: %@", self);
}


@end
