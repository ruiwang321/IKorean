//
//  ICEPlayerEpisodesCollectionView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/13.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerEpisodesCollectionView.h"
#import "ICEPlayerEpisodeCollectionViewCell.h"
#define itemCountInRow          5
#define itemSpacing             1
#define lineSpacing             1
static NSString * CellReuseIdentifier = @"ICEPlayerEpisodeCollectionViewCell";
@interface ICEPlayerEpisodesCollectionView ()
<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,strong) NSArray * episodeModels;
@property (nonatomic,assign) CGFloat episodesCollectionViewWidth;
@end

@implementation ICEPlayerEpisodesCollectionView
-(void)dealloc
{
    self.episodeModels=nil;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        _episodesCollectionViewWidth=CGRectGetWidth(frame);
    }
    return self;
}

-(void)updateWithModels:(NSArray *)models
{
    self.episodeModels=models;
    if (_collectionView==nil)
    {
        CGFloat itemWidth=(_episodesCollectionViewWidth-(itemCountInRow-1)*itemSpacing)/itemCountInRow;
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setMinimumInteritemSpacing:itemSpacing];
        [layout setMinimumLineSpacing:lineSpacing];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout setItemSize:CGSizeMake(itemWidth, itemWidth)];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [self addSubview:_collectionView];
        
        [_collectionView registerClass:[ICEPlayerEpisodeCollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    }
}

-(void)playEpisode
{
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSourceDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_episodeModels count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ICEPlayerEpisodeCollectionViewCell *cell = (ICEPlayerEpisodeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier
                                                                                                                               forIndexPath:indexPath];
    [cell updateCellWithModel:_episodeModels[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate method
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger Index=[indexPath row];
    if (Index<[_episodeModels count])
    {
        ICEPlayerEpisodeModel * model=_episodeModels[Index];
        if (_selectEpisodeBlock&&model)
        {
            _selectEpisodeBlock(model);
        }
    }
}
@end
