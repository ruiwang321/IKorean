//
//  MovieItemCellLayoutHelper.m
//  ICinema
//
//  Created by wangyunlong on 16/7/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieItemCellLayoutHelper.h"
static MovieItemCellLayoutHelper * movieItemCellLayoutHelper=nil;
@interface MovieItemCellLayoutHelper()

@property (nonatomic,assign,readwrite) CGFloat itemCountInCell;
@property (nonatomic,assign,readwrite) CGFloat movieItemPaddingH;
@property (nonatomic,assign,readwrite) CGRect  movieItemOriginFrame;
@property (nonatomic,assign,readwrite) CGFloat cellWidth;
@property (nonatomic,assign,readwrite) CGFloat cellHeight;

@end

@implementation MovieItemCellLayoutHelper

+(MovieItemCellLayoutHelper *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        movieItemCellLayoutHelper=[[MovieItemCellLayoutHelper alloc]initWithCellWidth:[[UIScreen mainScreen] bounds].size.width];
    });
    return movieItemCellLayoutHelper;
}

-(id)initWithCellWidth:(CGFloat)cellWidth
{
    if (self=[super init])
    {
        _itemCountInCell=3;
        CGFloat originWidthOfMovieItem=112;
        CGFloat originHeightOfMovieItem=180;
        CGFloat originPaddingOfHeadImage=(375-_itemCountInCell*originWidthOfMovieItem)/(_itemCountInCell+1);
        CGFloat originPaddingV=6;
        CGFloat coefficient=originPaddingOfHeadImage/originWidthOfMovieItem;
        
        CGFloat movieItemWidth=cellWidth/((_itemCountInCell+1)*coefficient+_itemCountInCell);
        _movieItemPaddingH=movieItemWidth*coefficient;
        CGFloat movieItemHeight=movieItemWidth*originHeightOfMovieItem/originWidthOfMovieItem;
        CGFloat movieItemPaddingV=(originPaddingV*movieItemHeight/originHeightOfMovieItem);
        _movieItemOriginFrame=CGRectMake(0, movieItemPaddingV, movieItemWidth, movieItemHeight);
        _cellHeight=movieItemHeight+movieItemPaddingV;
        _cellWidth=cellWidth;
    }
    return self;
}

@end
