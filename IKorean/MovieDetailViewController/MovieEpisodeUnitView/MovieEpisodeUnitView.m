//
//  MovieEpisodeUnitView.m
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieEpisodeUnitView.h"
#import "RecommendItem.h"

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
@property (nonatomic,strong) UICollectionView * recommendCollectionView;
@property (nonatomic,strong) NSMutableArray * episodeModelArray;
@property (nonatomic,strong) NSMutableArray * recommendModelArray;
@property (nonatomic,copy) void (^selectEpisodeBlock)(NSString * videoID);
@property (nonatomic,copy) MovieItemAction selectMovieItemBlock;
@property (nonatomic,copy) SourceSelectedBlock sourceSelectedBlock;
@property (nonatomic,assign) MovieEpisodeModel * selectEpisodeModel;
@property (nonatomic,copy) NSString *selectedSource;
@property (nonatomic,copy) void (^lookMoreEpisodeBlock)(NSArray * episodeModelArray,MovieLookMoreEpisodeViewStyle style);
@property (nonatomic,assign) MovieLookMoreEpisodeViewStyle style;
@end

@implementation MovieEpisodeUnitView

-(id)initWithFrame:(CGRect)frame
             style:(MovieLookMoreEpisodeViewStyle)style
            videos:(NSDictionary *)videos
    selectedSource:(NSString *)selectedSouurce
        recommends:(NSArray *)recommends
selectEpisodeBlock:(void (^)(NSString * videoID))selectEpisodeBlock
selectMovieItemBlock:(MovieItemAction)selectMovieItemBlock
sourceSelectedBlock:(SourceSelectedBlock)sourceSelectedBlock
lookMoreEpisodeBlock:(void (^)(NSArray * episodeModelArray,MovieLookMoreEpisodeViewStyle style))lookMoreEpisodeBlock
{
    if (self=[super initWithFrame:frame])
    {
        _selectEpisodeBlock=selectEpisodeBlock;
        _selectMovieItemBlock=selectMovieItemBlock;
        _sourceSelectedBlock=sourceSelectedBlock;
        _episodeUnitViewWidth=CGRectGetWidth(frame);
        _episodeUnitViewHeight=CGRectGetWidth(frame);
        _lookMoreEpisodeBlock = lookMoreEpisodeBlock;
        _selectedSource = selectedSouurce;
        
        self.episodeModelArray=[[NSMutableArray alloc] init];
        self.recommendModelArray=[[NSMutableArray alloc] init];
        for (NSDictionary * videoDic in videos[selectedSouurce])
        {
            MovieEpisodeModel * model=[[MovieEpisodeModel alloc] init];
            [model setValuesForKeysWithDictionary:videoDic];
            [_episodeModelArray addObject:model];
        }
        
        for (NSDictionary * arrDic in recommends) {
            MovieItemModel *model = [[MovieItemModel alloc] init];
            [model setValuesForKeysWithDictionary:arrDic];
            [_recommendModelArray addObject:model];
        }
        
        ICEAppHelper * appHelper=[ICEAppHelper shareInstance];
        UIColor * appPublicColor=[appHelper appPublicColor];
        
        UIScrollView * scrollView=[[UIScrollView alloc] initWithFrame:self.bounds];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:scrollView];
        
        // 视频源
        UILabel *sourceTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 60, 12)];
        sourceTextLabel.text = @"视频来源:";
        sourceTextLabel.font = [UIFont fontWithName:HYQiHei_55Pound size:12];
        sourceTextLabel.textColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1];
        [scrollView addSubview:sourceTextLabel];
        
        // 视频源选择按钮
        for (NSInteger i = 0; i < videos.count; i++) {
            UIButton *sourceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            sourceBtn.frame = CGRectMake(CGRectGetMaxX(sourceTextLabel.frame)+50*i, 8, 40, 12);
            sourceBtn.titleLabel.font = [UIFont fontWithName:HYQiHei_55Pound size:10];
            [sourceBtn setTitle:videos.allKeys[i] forState:UIControlStateNormal];
            sourceBtn.layer.cornerRadius = 3;
            
            sourceBtn.backgroundColor = [videos.allKeys[i] isEqualToString:selectedSouurce]?APPColor:[UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1];
            [sourceBtn setTitleColor:[videos.allKeys[i] isEqualToString:selectedSouurce]?[UIColor whiteColor]:[UIColor grayColor] forState:UIControlStateNormal];
            [sourceBtn addTarget:self action:@selector(sourceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:sourceBtn];
        }
        
        //颜色条
        CGFloat colorViewHeight=17;
        CGFloat colorViewMinY=CGRectGetMaxY(sourceTextLabel.frame)+10;
        CGRect  colorViewFrame=CGRectMake(0, colorViewMinY, 3, colorViewHeight);
        UIView * colorView=[[UIView alloc] initWithFrame:colorViewFrame];
        [colorView setBackgroundColor:appPublicColor];
        [scrollView addSubview:colorView];
        
        //剧集
        CGRect episodeTextLabelFrame=CGRectMake(CGRectGetMaxX(colorViewFrame)+8, CGRectGetMaxY(sourceTextLabel.frame), 40, 40);
        UILabel * episodeTextLabel=[[UILabel alloc] initWithFrame:episodeTextLabelFrame];
        [episodeTextLabel setText:@"剧集"];
        [episodeTextLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:16]];
        [episodeTextLabel setTextAlignment:NSTextAlignmentLeft];
        [episodeTextLabel setTextColor:[UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1]];
        [scrollView addSubview:episodeTextLabel];
        
        if ([_episodeModelArray count]>itemCountInRow)
        {
            //查看更多
            CGFloat lookMoreButtonWidth=75;
            CGRect  lookMoreButtonFrame=CGRectMake(_episodeUnitViewWidth-lookMoreButtonWidth, CGRectGetMaxY(sourceTextLabel.frame), lookMoreButtonWidth, 40);
            ICEButton * lookMoreButton=[ICEButton buttonWithType:UIButtonTypeCustom];
            [lookMoreButton setTitle:@"查看更多" forState:UIControlStateNormal];
            [lookMoreButton.titleLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:12]];
            [lookMoreButton setTitleColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1] forState:UIControlStateNormal];
            [lookMoreButton addTarget:self action:@selector(showAllEpisodes) forControlEvents:UIControlEventTouchUpInside];
            [lookMoreButton setFrame:lookMoreButtonFrame];
            [scrollView addSubview:lookMoreButton];
        }
        
        //collectionView上部灰色线
        UIView * collectionViewTopLine=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(episodeTextLabel.frame), _episodeUnitViewWidth, 1)];
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
        
        CGRect  episodeCollectionViewFrame=CGRectMake(0, CGRectGetMaxY(collectionViewTopLine.frame), _episodeUnitViewWidth, _itemHeight);
        self.episodeCollectionView = [[UICollectionView alloc] initWithFrame:episodeCollectionViewFrame collectionViewLayout:layout];
        [_episodeCollectionView registerClass:[MovieEpisodeCollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
        [_episodeCollectionView setBackgroundColor:[UIColor whiteColor]];
        [_episodeCollectionView setShowsVerticalScrollIndicator:NO];
        [_episodeCollectionView setShowsHorizontalScrollIndicator:NO];
        [_episodeCollectionView setDataSource:self];
        [_episodeCollectionView setDelegate:self];
        [scrollView addSubview:_episodeCollectionView];
        
        //collectionView下部灰色线
        UIView * collectionViewBottomLine=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(episodeCollectionViewFrame), _episodeUnitViewWidth, 1)];
        [collectionViewBottomLine setBackgroundColor:[collectionViewTopLine backgroundColor]];
        [scrollView addSubview:collectionViewBottomLine];
        
        //推荐颜色条
        CGRect colorView1Frame=colorViewFrame;
        colorView1Frame.origin.y=CGRectGetMaxY(collectionViewBottomLine.frame)+11;
        UIView * colorView1=[[UIView alloc] initWithFrame:colorView1Frame];
        [colorView1 setBackgroundColor:appPublicColor];
        [scrollView addSubview:colorView1];
        
        //推荐
        CGRect recommendTextLabelFrame=[episodeTextLabel frame];
        recommendTextLabelFrame.origin.y=CGRectGetMaxY(collectionViewBottomLine.frame);
        UILabel * recommendTextLabel=[[UILabel alloc] initWithFrame:recommendTextLabelFrame];
        [recommendTextLabel setText:@"相关"];
        [recommendTextLabel setFont:[episodeTextLabel font]];
        [recommendTextLabel setTextAlignment:NSTextAlignmentLeft];
        [recommendTextLabel setTextColor:[episodeTextLabel textColor]];
        [scrollView addSubview:recommendTextLabel];
        
        // 相关视频collectionView
        UICollectionViewFlowLayout *recommendFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        recommendFlowLayout.minimumLineSpacing = 5;
        recommendFlowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        recommendFlowLayout.itemSize = CGSizeMake(115, 175);
        recommendFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _recommendCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(recommendTextLabelFrame), SCREEN_WIDTH, 185) collectionViewLayout:recommendFlowLayout];
        [_recommendCollectionView registerClass:[RecommendItem class] forCellWithReuseIdentifier:@"recommendItem"];
        _recommendCollectionView.backgroundColor = [UIColor whiteColor];
        _recommendCollectionView.showsVerticalScrollIndicator = NO;
        _recommendCollectionView.showsHorizontalScrollIndicator = NO;
        _recommendCollectionView.delegate = self;
        _recommendCollectionView.dataSource = self;
        [scrollView addSubview:_recommendCollectionView];
        
        scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(_recommendCollectionView.frame) + 20);
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

- (void)showAllEpisodes
{
    if (_lookMoreEpisodeBlock)
    {
        _lookMoreEpisodeBlock(_episodeModelArray,_style);
    }
}

- (void)sourceBtnAction:(UIButton *)sourceBtn {
    if (![sourceBtn.titleLabel.text isEqualToString:_selectedSource]) {
        if (_sourceSelectedBlock) {
            _sourceSelectedBlock(sourceBtn.titleLabel.text);
        }

    }
}

#pragma mark - UICollectionViewDataSourceDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger itemsNumber;
    if (collectionView == _episodeCollectionView) {
        itemsNumber = [_episodeModelArray count];
    }else {
        itemsNumber = [_recommendModelArray count];
    }
    return itemsNumber;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *collectionCell;
    
    if (collectionView == _episodeCollectionView) {
        MovieEpisodeCollectionViewCell *cell = (MovieEpisodeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier
                                                                                                                           forIndexPath:indexPath];
        NSInteger row=[indexPath row];
        [cell updateCellWithModel:_episodeModelArray[row]];
        
        collectionCell = cell;
    }else {
        
        RecommendItem *cell = (RecommendItem *)[collectionView dequeueReusableCellWithReuseIdentifier:@"recommendItem" forIndexPath:indexPath];
        cell.model = _recommendModelArray[indexPath.row];
        collectionCell = cell;
    }
    
    return collectionCell;
}

#pragma mark - UICollectionViewDelegate method
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _episodeCollectionView) {
        NSInteger Index=[indexPath row];
        [self executeSelectEpisodeBlockWithIndex:Index];
    }else {
        if (_selectMovieItemBlock) {
            _selectMovieItemBlock(_recommendModelArray[indexPath.row]);
        }
    }
}
@end
