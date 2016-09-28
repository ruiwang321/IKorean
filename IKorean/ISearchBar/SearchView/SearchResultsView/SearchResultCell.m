//
//  SearchResultCell.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "SearchResultCell.h"

@implementation SearchResultCellModel

@end

#define CellHeight  140
@interface SearchResultCell()
{
    UIImageView * m_imageView;
    UILabel     * m_titleLabel;
}
@property (nonatomic,strong,readwrite)SearchResultCellModel * model;
@end

@implementation SearchResultCell

+(CGFloat)cellHiehgt
{
    return CellHeight;
}

+(CGRect)imageFrame
{
    CGFloat imageMinX=10;
    CGFloat imageMinY=10;
    CGFloat imageWidth=83;
    CGFloat imageHeight=CellHeight-2*imageMinY;
    return CGRectMake(imageMinX, imageMinY, imageWidth, imageHeight);
}

+(CGPoint)titleLabelOrigin
{
    return CGPointMake(CGRectGetMaxX([[self class] imageFrame])+10, 0);
}

+(CGFloat)titleLabelPaddingToRight
{
    return 10;
}


-(void)updateCellWithCellModel:(SearchResultCellModel *)model
{
    if (model)
    {
        self.model=model;
        if (m_imageView==nil)
        {
            CGRect imageViewFrame=[[self class] imageFrame];
            
            //影视图片
            m_imageView=[[UIImageView alloc] initWithFrame:imageViewFrame];
            [self addSubview:m_imageView];
            
            //标题
            CGPoint titleLabelOrigin=[[self class] titleLabelOrigin];
            CGRect titleLabelFrame=CGRectMake(titleLabelOrigin.x,
                                              titleLabelOrigin.y,
                                              self.cellWidth-titleLabelOrigin.x-[[self class] titleLabelPaddingToRight],
                                              self.cellHeight);
            
            m_titleLabel=[[UILabel alloc] initWithFrame:titleLabelFrame];
            [m_titleLabel setNumberOfLines:0];
            [self addSubview:m_titleLabel];
        }
        [m_imageView sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@"default_v_icon"]];
        [m_titleLabel setAttributedText:model.titleAttributedString];
    }
}

@end
