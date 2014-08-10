//
//  NoteTableViewCell.m
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 30..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#define kNOTETABLEVIEW_CELL_BACKGROUND_COLOR    [UIColor colorWithRed:0.914 green:0.902 blue:0.843 alpha:1]


#import "NoteTableViewCell.h"


@implementation NoteTableViewCell


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        
    }
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib
{
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // change background color of selected cell
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:kNOTETABLEVIEW_CELL_BACKGROUND_COLOR];   //[UIColor colorWithRed:0.992 green:0.953 blue:0.89 alpha:1]
    [self setSelectedBackgroundView:bgColorView];
}

@end
