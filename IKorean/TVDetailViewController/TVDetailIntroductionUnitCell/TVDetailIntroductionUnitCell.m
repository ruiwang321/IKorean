//
//  TVDetailIntroductionUnitCell.m
//  ICinema
//
//  Created by yunlongwang on 16/7/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "TVDetailIntroductionUnitCell.h"
@interface TVDetailIntroductionUnitCell()
{
    UILabel * m_labelOfIntroduction;
    ICEButton * m_expandButton;
}
@end

@implementation TVDetailIntroductionUnitCell

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
         cellWidth:(CGFloat)cellWidth
        cellHeight:(CGFloat)cellHeight
{
    if (self=[super initWithStyle:style
                  reuseIdentifier:reuseIdentifier
                        cellWidth:cellWidth
                       cellHeight:cellHeight])
    {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

-(void)updateCellWithModel:(TVDetailIntroductionUnitCellModel *)model
{
    if (m_labelOfIntroduction==nil)
    {
        //灰色条
        UIView * grayView=[[UIView alloc] initWithFrame:model.grayViewFrame];
        [grayView setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
        [self addSubview:grayView];
        
        //蓝色竖条
        UIView * blueView=[[UIView alloc] initWithFrame:model.blueImageFrame];
        [blueView setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
        [self addSubview:blueView];
        
        //标题
        UILabel * labelOfTitle=[[UILabel alloc] initWithFrame:model.titleLabelFrame];
        [labelOfTitle setText:@"简介"];
        [labelOfTitle setFont:[UIFont fontWithName:HYQiHei_65Pound size:14]];
        [labelOfTitle setNumberOfLines:1];
        [labelOfTitle setTextColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1]];
        [labelOfTitle setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:labelOfTitle];
        
        //影视介绍
        m_labelOfIntroduction=[[UILabel alloc] init];
        [m_labelOfIntroduction setNumberOfLines:0];
        [self addSubview:m_labelOfIntroduction];
    }
    
    [m_labelOfIntroduction setFrame:model.introductionLabelFrame];
    [m_labelOfIntroduction setAttributedText:model.introductionString];
    
    if (model.isCanExpand)
    {
        if (m_expandButton==nil) {
            m_expandButton=[ICEButton buttonWithType:UIButtonTypeCustom];
            [m_expandButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [m_expandButton setFrame:model.expandButtonFrame];
            [m_expandButton addTarget:self action:@selector(expandCell) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:m_expandButton];
        }
        [m_expandButton setHidden:NO];
        [m_expandButton setAttributedTitle:model.expandButtonTitle forState:UIControlStateNormal];
    }
    else
    {
        [m_expandButton setHidden:YES];
    }
}

-(void)expandCell
{
    if (_expandCellBlock) {
        _expandCellBlock();
    }
}
@end
