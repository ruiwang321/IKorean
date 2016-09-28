//
//  MovieEpisodeTableViewCell.m
//  ICinema
//
//  Created by yunlongwang on 16/9/28.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieEpisodeTableViewCell.h"

@interface MovieEpisodeTableViewCell ()

@property (nonatomic,strong) ICELabel * titleLabel;

@end

@implementation MovieEpisodeTableViewCell

-(void)updateCellWithModel:(MovieEpisodeModel *)model
{
    if (model)
    {
        if (_titleLabel==nil)
        {
            self.titleLabel=[[ICELabel alloc] initWithFrame:self.bounds textInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [_titleLabel setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:_titleLabel];
            
            UIView * grayLine=[[UIView alloc] initWithFrame:CGRectMake(0, self.cellHeight-1, self.cellWidth, 1)];
            [grayLine setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
            [self addSubview:grayLine];
        }
        if ([model isPlay])
        {
            [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:17]];
            [_titleLabel setTextColor:[[ICEAppHelper shareInstance] appPublicColor]];
        }
        else
        {
            [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:15]];
            [_titleLabel setTextColor:[UIColor darkGrayColor]];
        }
        [_titleLabel setText:[model title]];
    }
}

@end
