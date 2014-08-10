//
//  LeftTableViewCell.m
//  SwiftNoteiPad
//
//  Created by jun on 2014. 7. 28..
//  Copyright (c) 2014년 lovejunsoft. All rights reserved.
//

#define kNOTETABLEVIEW_CELL_BACKGROUND_COLOR    [UIColor colorWithRed:0.914 green:0.902 blue:0.843 alpha:1]


#import "LeftTableViewCell.h"


@implementation LeftTableViewCell


- (instancetype)initWithCoder:(NSCoder *)coder
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    self = [super initWithCoder:coder];
    if (self)
    {
        
    }
    return self;
}


- (void)awakeFromNib
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    // Initialization code
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier //never invoked
{
    //if (debug==1) {NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));}
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
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
