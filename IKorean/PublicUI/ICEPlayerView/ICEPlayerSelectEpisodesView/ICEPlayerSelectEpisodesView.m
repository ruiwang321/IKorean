//
//  ICEPlayerSelectEpisodesView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/12.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerSelectEpisodesView.h"
#import "ICEPlayerEpisodesTableView.h"
#import "ICEPlayerEpisodesCollectionView.h"

@interface ICEPlayerSelectEpisodesView ()
@property (nonatomic,assign) CGFloat selectEpisodesViewShowMinX;
@property (nonatomic,assign) CGFloat selectEpisodesViewHideMinX;
@property (nonatomic,strong) ICEPlayerEpisodesTableView * episodesTableView;
@property (nonatomic,strong) ICEPlayerEpisodesCollectionView * episodesCollectionView;
@property (nonatomic,assign) ICEPlayerSelectEpisodesViewStyle currentStyle;
@end

@implementation ICEPlayerSelectEpisodesView

-(id)initWithFrame:(CGRect)frame showMinX:(CGFloat)showMinX hideMinX:(CGFloat)hideMinX
{
    if (self=[super initWithFrame:frame])
    {
        _selectEpisodesViewShowMinX=showMinX;
        _selectEpisodesViewHideMinX=hideMinX;
        [self setBackgroundColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewPublicColor];
    }
    return self;
}

-(void)addOrUpdateEpisodesTableViewWithModels:(NSArray *)models
{
    if (_episodesTableView==nil)
    {
        self.episodesTableView=[[ICEPlayerEpisodesTableView alloc] initWithFrame:self.bounds];
        [_episodesTableView setSelectEpisodeBlock:_selectBlock];
        [self addSubview:_episodesTableView];
    }
    [_episodesTableView updateWithModels:models];
}

-(void)removeEpisodesTableView
{
    if (_episodesTableView)
    {
        [_episodesTableView removeFromSuperview];
        self.episodesTableView=nil;
    }
}

-(void)addOrUpdateEpisodesCollectionViewWithModels:(NSArray *)models
{
    if (_episodesCollectionView==nil)
    {
        self.episodesCollectionView=[[ICEPlayerEpisodesCollectionView alloc] initWithFrame:self.bounds];
        [_episodesCollectionView setSelectEpisodeBlock:_selectBlock];
        [self addSubview:_episodesCollectionView];
    }
    [_episodesCollectionView updateWithModels:models];
}

-(void)removeEpisodesCollectionView
{
    if (_episodesCollectionView)
    {
        [_episodesCollectionView removeFromSuperview];
        self.episodesCollectionView=nil;
    }
}

-(void)updateSelectEpisodesViewWithModels:(NSArray *)models style:(ICEPlayerSelectEpisodesViewStyle)style
{
    _currentStyle=style;
    if (ICEPlayerSelectEpisodesViewTableViewStyle==_currentStyle)
    {
        [self removeEpisodesCollectionView];
        [self addOrUpdateEpisodesTableViewWithModels:models];
    }
    else
    {
        [self removeEpisodesTableView];
        [self addOrUpdateEpisodesCollectionViewWithModels:models];
    }
}

-(void)playEpisode
{
    if (ICEPlayerSelectEpisodesViewTableViewStyle==_currentStyle)
    {
        [_episodesTableView playEpisode];
    }
    else
    {
        [_episodesCollectionView playEpisode];
    }
}

-(void)setHidden:(BOOL)hidden
{
    if (hidden)
    {
        CGRect frame=self.frame;
        frame.origin.x=_selectEpisodesViewHideMinX;
        [UIView animateWithDuration:0.2 animations:^{
            self.frame=frame;
        }completion:^(BOOL finished){
            [super setHidden:YES];
        }];
    }
    else
    {
        [super setHidden:NO];
        CGRect frame=self.frame;
        frame.origin.x=_selectEpisodesViewShowMinX;
        [UIView animateWithDuration:0.2 animations:^{
            self.frame=frame;
        }completion:^(BOOL finished){

        }];
    }
}
@end
