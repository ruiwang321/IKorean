//
//  ICETableViewCell.m
//  ICinema
//
//  Created by yunlongwang on 16/6/16.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICETableViewCell.h"
@interface ICETableViewCell()
@property(nonatomic,assign,readwrite) CGFloat cellWidth;
@property(nonatomic,assign,readwrite) CGFloat cellHeight;
@end

@implementation ICETableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
         cellWidth:(CGFloat)cellWidth
        cellHeight:(CGFloat)cellHeight
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _cellWidth=cellWidth;
        _cellHeight=cellHeight;
        [self setBackgroundColor:[UIColor whiteColor]];
        [[self contentView] setOpaque:YES];
        [[self backgroundView] setOpaque:YES];
        [[self contentView]setExclusiveTouch:YES];
        [self setFrame:CGRectMake(0, 0, _cellWidth, _cellHeight)];
        [self setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellPressImage.png"]]];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
