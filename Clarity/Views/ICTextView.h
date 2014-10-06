
#import <UIKit/UIKit.h>


@interface ICTextView : UITextView


- (void)assignTextViewAttribute;

- (void)scrollToVisibleCaretAnimated;

- (void)hideKeyboard:(id)sender;
- (void)previousCharacter:(id)sender;
- (void)nextCharacter:(id)sender;
- (void)previousWord:(id)sender;
- (void)nextWord:(id)sender;
- (void)selectParagraph:(id)sender;
- (void)selectWord:(id)sender;
- (void)addHash:(id)sender;
- (void)addAsterisk:(id)sender;
- (void)addTab:(id)sender;
- (void)addAngleBracket:(id)sender;
- (void)addExclamationMark:(id)sender;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification*)notification;


@end