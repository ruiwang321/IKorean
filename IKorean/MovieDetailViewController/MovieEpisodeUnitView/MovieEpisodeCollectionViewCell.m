//
//  MovieEpisodeCollectionViewCell.m
//  ICinema
//
//  Created by wangyunlong on 16/9/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieEpisodeCollectionViewCell.h"
#define DividingLineWidth      1
@interface MovieEpisodeCollectionViewCell ()
@property (nonatomic,strong) ICELabel * titleLabel;
@property (nonatomic,assign) CGFloat labelContentWidth;
@end
@implementation MovieEpisodeCollectionViewCell
-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        CGFloat cellWidth=CGRectGetWidth(frame);
        CGFloat cellHeight=CGRectGetHeight(frame);
        
        CGRect   dividingLineFrame=CGRectMake(cellWidth-DividingLineWidth, 0, DividingLineWidth, cellHeight);
        UIView * dividingLine=[[UIView alloc] initWithFrame:dividingLineFrame];
        [dividingLine setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
        [self addSubview:dividingLine];
        
        CGFloat padding=10;
        CGFloat titleLabelWidth=CGRectGetMinX(dividingLineFrame);
        _labelContentWidth=titleLabelWidth-2*padding;
        self.titleLabel=[[ICELabel alloc] initWithFrame:CGRectMake(0, 0, titleLabelWidth, cellHeight)
                                             textInsets:UIEdgeInsetsMake(0, padding, 0, padding)];
        [_titleLabel setText:@""];
        if (cellWidth==cellHeight)
        {
            [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:cellHeight/4]];
            [_titleLabel setTextAlignment:(cellWidth>cellHeight?NSTextAlignmentJustified:NSTextAlignmentCenter)];
        }
        else
        {
            [_titleLabel setNumberOfLines:2];
            [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:cellHeight/5]];
        }
        [self addSubview:_titleLabel];
        
    }
    return self;
}

-(void)updateCellWithModel:(MovieEpisodeModel *)model
{
    if (model)
    {
        if ([model isPlay])
        {
            [_titleLabel setTextColor:[[ICEAppHelper shareInstance] appPublicColor]];
        }
        else
        {
            [_titleLabel setTextColor:[UIColor darkGrayColor]];
        }
        [_titleLabel setText:[model title]];
        
        if ([_titleLabel numberOfLines]>1)
        {
            CGSize textSize=[_titleLabel sizeThatFits:CGSizeZero];
            if (textSize.width>_labelContentWidth)
            {
                [_titleLabel setTextAlignment:NSTextAlignmentLeft];
            }
            else
            {
                [_titleLabel setTextAlignment:NSTextAlignmentCenter];
            }
        }
    }
}

@end
