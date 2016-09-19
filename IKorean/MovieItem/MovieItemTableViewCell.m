//
//  MovieItemTableViewCell.m
//  ICinema
//
//  Created by wangyunlong on 16/8/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieItemTableViewCell.h"
@interface MovieItemTableViewCell()
{
    NSMutableArray * m_arrayOfMovieItems;
}
@end

@implementation MovieItemTableViewCell

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

-(void)updateCellWithDicOfData:(NSArray *)arrayOfCellDatas
{
    
    if (m_arrayOfMovieItems==nil)
    {
        MovieItemCellLayoutHelper * helper=[MovieItemCellLayoutHelper shareInstance];
        NSInteger itemCountInCell=helper.itemCountInCell;
        m_arrayOfMovieItems=[[NSMutableArray alloc] initWithCapacity:itemCountInCell];
        CGRect frameOfItem=helper.movieItemOriginFrame;
        CGFloat paddingOfItem=helper.movieItemPaddingH;
        CGFloat widthOfItem=CGRectGetWidth(frameOfItem);
        for (NSInteger Index=0; Index<itemCountInCell; Index++)
        {
            CGRect frame=frameOfItem;
            frame.origin.x=paddingOfItem+Index*(paddingOfItem+widthOfItem);
            MovieItem * moviewItem=[[MovieItem alloc] initWithFrame:frame];
            moviewItem.movieItemAction=_selectBlock;
            [self addSubview:moviewItem];
            [m_arrayOfMovieItems addObject:moviewItem];
        }
    }
    NSInteger countOfNewData=[arrayOfCellDatas count];
    NSInteger countOfMovieItem=[m_arrayOfMovieItems count];
    NSInteger count=MIN(countOfNewData, countOfMovieItem);
    NSInteger Index=0;
    for (; Index<count; Index++)
    {
        MovieItem * item=m_arrayOfMovieItems[Index];
        [item setItemModel:arrayOfCellDatas[Index]];
        [item setHidden:NO];
    }
    for (; Index<countOfMovieItem; Index++) {
        MovieItem * item=m_arrayOfMovieItems[Index];
        [item setHidden:YES];
    }
}

@end
