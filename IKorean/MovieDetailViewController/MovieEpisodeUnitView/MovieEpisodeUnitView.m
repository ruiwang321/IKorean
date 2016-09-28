//
//  MovieEpisodeUnitView.m
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieEpisodeUnitView.h"

#define itemCountInRow          6
#define itemSpacing             1
#define lineSpacing             1

static NSString * CellReuseIdentifier = @"EpisodeCollectionViewCell";

@interface MovieEpisodeUnitView ()
<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (nonatomic,assign) CGFloat episodeUnitViewWidth;
@property (nonatomic,assign) CGFloat episodeUnitViewHeight;
@property (nonatomic,assign) CGFloat itemWidth;
@property (nonatomic,assign) CGFloat itemHeight;
@property (nonatomic,strong) UICollectionView * episodeCollectionView;
@property (nonatomic,strong) NSMutableArray * episodeModelArray;
@property (nonatomic,copy) void (^selectEpisodeBlock)(NSString * videoID);
@property (nonatomic,copy) MovieItemAction selectMovieItemBlock;
@property (nonatomic,assign) MovieEpisodeModel * selectEpisodeModel;
@end

@implementation MovieEpisodeUnitView

-(id)initWithFrame:(CGRect)frame
             style:(MovieEpisodeUnitViewLookMoreViewStyle)style
            videos:(NSArray *)videos
        recommends:(NSArray *)recommends
selectEpisodeBlock:(void (^)(NSString * videoID))selectEpisodeBlock
selectMovieItemBlock:(MovieItemAction)selectMovieItemBlock
{
    if (self=[super initWithFrame:frame])
    {
        _selectEpisodeBlock=selectEpisodeBlock;
        _selectMovieItemBlock=selectMovieItemBlock;
        _episodeUnitViewWidth=CGRectGetWidth(frame);
        _episodeUnitViewHeight=CGRectGetWidth(frame);
        
        self.episodeModelArray=[[NSMutableArray alloc] init];

        for (NSDictionary * videoDic in videos)
        {
            MovieEpisodeModel * model=[[MovieEpisodeModel alloc] init];
            [model setValuesForKeysWithDictionary:videoDic];
            [_episodeModelArray addObject:model];
        }
        
        ICEAppHelper * appHelper=[ICEAppHelper shareInstance];
        UIColor * appPublicColor=[appHelper appPublicColor];
        
        UIScrollView * scrollView=[[UIScrollView alloc] initWithFrame:self.bounds];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:scrollView];
        
        CGFloat headerViewHeight=40;
        CGRect  headerViewFrame=CGRectMake(0, 0, _episodeUnitViewWidth, headerViewHeight);
        UIView * headerView=[[UIView alloc] initWithFrame:headerViewFrame];
        [headerView setBackgroundColor:[UIColor whiteColor]];
        [scrollView addSubview:headerView];
        
        //颜色条
        CGFloat colorViewHeight=17;
        CGFloat colorViewMinY=(headerViewHeight-colorViewHeight)/2;
        CGRect  colorViewFrame=CGRectMake(0, colorViewMinY, 3, colorViewHeight);
        UIView * colorView=[[UIView alloc] initWithFrame:colorViewFrame];
        [colorView setBackgroundColor:appPublicColor];
        [headerView addSubview:colorView];
        
        //剧集
        CGRect episodeTextLabelFrame=CGRectMake(CGRectGetMaxX(colorViewFrame)+8, 0, 40, headerViewHeight);
        UILabel * episodeTextLabel=[[UILabel alloc] initWithFrame:episodeTextLabelFrame];
        [episodeTextLabel setText:@"剧集"];
        [episodeTextLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:16]];
        [episodeTextLabel setTextAlignment:NSTextAlignmentLeft];
        [episodeTextLabel setTextColor:[UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1]];
        [headerView addSubview:episodeTextLabel];
        
        if ([_episodeModelArray count]>itemCountInRow)
        {
            //查看更多
            CGFloat lookMoreButtonWidth=75;
            CGRect  lookMoreButtonFrame=CGRectMake(_episodeUnitViewWidth-lookMoreButtonWidth, 0, lookMoreButtonWidth, headerViewHeight);
            ICEButton * lookMoreButton=[ICEButton buttonWithType:UIButtonTypeCustom];
            [lookMoreButton setTitle:@"查看更多" forState:UIControlStateNormal];
            [lookMoreButton.titleLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:12]];
            [lookMoreButton setTitleColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1] forState:UIControlStateNormal];
            [lookMoreButton setFrame:lookMoreButtonFrame];
            [headerView addSubview:lookMoreButton];
        }
        
        //collectionView上部灰色线
        CGRect  collectionViewTopLineFrame=CGRectMake(0, CGRectGetMaxY(headerViewFrame), _episodeUnitViewWidth, 1);
        UIView * collectionViewTopLine=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerViewFrame), _episodeUnitViewWidth, 1)];
        [collectionViewTopLine setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
        [scrollView addSubview:collectionViewTopLine];
        
        if (LookMoreViewTableViewStyle==style)
        {
            CGFloat itemWidthOrigWidth=230;
            CGFloat itemHeightOrigHeight=130;
            CGFloat episodeUnitViewOrigWidth=750;
            _itemWidth=itemWidthOrigWidth/episodeUnitViewOrigWidth*_episodeUnitViewWidth;
            _itemHeight=itemHeightOrigHeight/itemWidthOrigWidth*_itemWidth;
        }
        else if (LookMoreViewCollectionViewStyle==style)
        {
            _itemWidth=_episodeUnitViewWidth/itemCountInRow;
            _itemHeight=_itemWidth;
        }
    
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setMinimumInteritemSpacing:0];
        [layout setMinimumLineSpacing:0];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [layout setItemSize:CGSizeMake(_itemWidth, _itemHeight)];
        
        CGRect  episodeCollectionViewFrame=CGRectMake(0, CGRectGetMaxY(collectionViewTopLineFrame), _episodeUnitViewWidth, _itemHeight);
        self.episodeCollectionView = [[UICollectionView alloc] initWithFrame:episodeCollectionViewFrame collectionViewLayout:layout];
        [_episodeCollectionView registerClass:[MovieEpisodeCollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
        [_episodeCollectionView setBackgroundColor:[UIColor whiteColor]];
        [_episodeCollectionView setShowsVerticalScrollIndicator:NO];
        [_episodeCollectionView setShowsHorizontalScrollIndicator:NO];
        [_episodeCollectionView setDataSource:self];
        [_episodeCollectionView setDelegate:self];
        [self addSubview:_episodeCollectionView];
        
        //collectionView下部灰色线
        UIView * collectionViewBottomLine=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(episodeCollectionViewFrame), _episodeUnitViewWidth, 1)];
        [collectionViewBottomLine setBackgroundColor:[collectionViewTopLine backgroundColor]];
        [scrollView addSubview:collectionViewBottomLine];
    }
    return self;
}

-(void)playEpisodeWithVideoID:(NSString *)videoID
{
    for (MovieEpisodeModel * model in _episodeModelArray)
    {
        if ([model.videoID isEqualToString:videoID])
        {
            [_selectEpisodeModel setIsPlay:NO];
            self.selectEpisodeModel=model;
            [_selectEpisodeModel setIsPlay:YES];
            break;
        }
    }
    [_episodeCollectionView reloadData];
}

- (void)executeSelectEpisodeBlockWithIndex:(NSInteger)Index
{
    if (Index<[_episodeModelArray count])
    {
        MovieEpisodeModel * model=_episodeModelArray[Index];
        if (_selectEpisodeBlock&&model)
        {
            _selectEpisodeBlock(model.videoID);
        }
    }
}

#pragma mark - UICollectionViewDataSourceDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_episodeModelArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MovieEpisodeCollectionViewCell *cell = (MovieEpisodeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier
                                                                                                                       forIndexPath:indexPath];
    NSInteger row=[indexPath row];
    [cell updateCellWithModel:_episodeModelArray[row]];
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
    [self executeSelectEpisodeBlockWithIndex:Index];
}
@end
