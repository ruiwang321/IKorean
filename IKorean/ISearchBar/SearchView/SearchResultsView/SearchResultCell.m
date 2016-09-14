//
//  SearchResultCell.m
//  ICinema
//
//  Created by wangyunlong on 16/8/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
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
            
            //默认图片
            UIView * placeholderView=[[ICEAppHelper shareInstance]viewWithPlaceholderImageName:@"publicPlaceholder@2x"
                                                                                     viewWidth:imageViewFrame.size.width
                                                                                    viewHeight:imageViewFrame.size.height
                                                                                  cornerRadius:4];
            [self addSubview:placeholderView];
            [placeholderView setFrame:imageViewFrame];
            
            //影视图片
            m_imageView=[[UIImageView alloc] initWithFrame:placeholderView.bounds];
            [placeholderView addSubview:m_imageView];
            
            //标题
            CGPoint titleLabelOrigin=[[self class] titleLabelOrigin];
            CGRect titleLabelFrame=CGRectMake(titleLabelOrigin.x,
                                              titleLabelOrigin.y,
                                              m_cellWidth-titleLabelOrigin.x-[[self class] titleLabelPaddingToRight],
                                              m_cellHeight);
            
            m_titleLabel=[[UILabel alloc] initWithFrame:titleLabelFrame];
            [m_titleLabel setNumberOfLines:0];
            [self addSubview:m_titleLabel];
        }
        [m_imageView sd_setImageWithURL:[NSURL URLWithString:model.img]];
        [m_titleLabel setAttributedText:model.titleAttributedString];
    }
}

@end
