//
//  NoteTableViewCell.h
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 30..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *starImageView;
@property (nonatomic, weak) IBOutlet UILabel *noteTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *noteSubtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *dayLabel;

@end
