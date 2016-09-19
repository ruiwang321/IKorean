//
//  SearchCell.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "SearchCell.h"
@implementation SearchCellModel

@end

#define labelMinX 10
@interface SearchCell()
{
    UILabel * m_titleLabel;
}
@property (nonatomic,strong,readwrite) SearchCellModel * model;
@end

@implementation SearchCell

+(CGFloat)titleLabelMinX
{
    return labelMinX;
}

-(void)updateCellWithCellModel:(SearchCellModel *)model
{
    if (model)
    {
        if (m_titleLabel==nil) {
            m_titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(labelMinX, 0, m_cellWidth-2*labelMinX, m_cellHeight)];
            [m_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
            [m_titleLabel setNumberOfLines:0];
            [self addSubview:m_titleLabel];
        }
        [m_titleLabel setAttributedText:model.title];
        self.model=model;
    }
}

@end
