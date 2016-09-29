//
//  MovieLookMoreEpisodeView.m
//  ICinema
//
//  Created by wangyunlong on 16/9/29.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieLookMoreEpisodeView.h"
#import "MovieEpisodeModel.h"
#import "ICETableViewCell.h"
#define CellHeight 45
#define itemCountInRow  6
static NSString * EpisodeCellReuseIdentifier = @"LookMoreEpisodeCellReuseIdentifier";
static NSString * EpisodeCellIdentifier=@"LookMoreEpisodeCellIdentifier";

@interface LookMoreEpisodeTableViewCell : ICETableViewCell

@property (nonatomic,strong) ICELabel * titleLabel;

-(void)updateCellWithModel:(MovieEpisodeModel *)model;

@end

@implementation LookMoreEpisodeTableViewCell

-(void)updateCellWithModel:(MovieEpisodeModel *)model
{
    if (model)
    {
        if (_titleLabel==nil)
        {
            self.titleLabel=[[ICELabel alloc] initWithFrame:self.bounds textInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
            [_titleLabel setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:_titleLabel];
            
            UIView * grayLine=[[UIView alloc] initWithFrame:CGRectMake(0, self.cellHeight-1, self.cellWidth, 1)];
            [grayLine setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
            [self addSubview:grayLine];
        }
        if ([model isPlay])
        {
            [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:17]];
            [_titleLabel setTextColor:[[ICEAppHelper shareInstance] appPublicColor]];
        }
        else
        {
            [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:15]];
            [_titleLabel setTextColor:[UIColor darkGrayColor]];
        }
        [_titleLabel setText:[model title]];
    }
}

@end

@interface LookMoreEpisodeCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UILabel * titleLabel;

-(void)updateCellWithModel:(MovieEpisodeModel *)model;

@end

@implementation LookMoreEpisodeCollectionViewCell

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
        
        CGFloat itemHeight=CGRectGetHeight(frame);
        self.titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame)-1, itemHeight-1)];
        [_titleLabel setText:@""];
        [_titleLabel setBackgroundColor:[UIColor whiteColor]];
        [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:itemHeight/4]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

-(void)updateCellWithModel:(MovieEpisodeModel *)model
{
    if (model)
    {
        if ([model isPlay])
        {
            [_titleLabel setTextColor:[[ICEAppHelper shareInstance] appPublicColor]];
        }
        else
        {
            [_titleLabel setTextColor:[UIColor darkGrayColor]];
        }
        [_titleLabel setText:[model title]];
    }
}

@end

@interface MovieLookMoreEpisodeView ()
<
UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (nonatomic,strong)UITableView * episodeTableView;
@property (nonatomic,strong)UICollectionView * episodeCollectionView;
@property (nonatomic,strong)NSArray * episodeModelArray;
@property (nonatomic,assign)MovieLookMoreEpisodeViewStyle episodeViewStyle;
@property (nonatomic,assign)CGFloat lookMoreEpisodeViewWidth;
@property (nonatomic,assign)CGFloat lookMoreEpisodeViewHeight;
@property (nonatomic,copy) void (^selectEpisodeBlock)(NSString * videoID);
@end


@implementation MovieLookMoreEpisodeView
-(void)dealloc
{
    self.episodeModelArray=nil;
}

-(id)initWithFrame:(CGRect)frame
             style:(MovieLookMoreEpisodeViewStyle)style
     episodeModels:(NSArray *)episodeModels
selectEpisodeBlock:(void (^)(NSString * videoID))selectEpisodeBlock
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.episodeModelArray=episodeModels;
        self.selectEpisodeBlock=selectEpisodeBlock;
        
        /////////////////////只用collectionViewStyle 所以赋固定值/////////////////////////////
        
        _episodeViewStyle=LookMoreViewCollectionViewStyle;
        
        /////////////////////只用collectionViewStyle 所以赋固定值/////////////////////////////        
        
        _lookMoreEpisodeViewWidth=CGRectGetWidth(frame);
        _lookMoreEpisodeViewHeight=CGRectGetHeight(frame);
        
        CGFloat headerViewHeight=40;
        CGRect  headerViewFrame=CGRectMake(0, 0, _lookMoreEpisodeViewWidth, headerViewHeight);
        UIView * headerView=[[UIView alloc] initWithFrame:headerViewFrame];
        [self addSubview:headerView];
        
        //颜色条
        CGFloat colorViewHeight=17;
        CGFloat colorViewMinY=(headerViewHeight-colorViewHeight)/2;
        CGRect  colorViewFrame=CGRectMake(0, colorViewMinY, 3, colorViewHeight);
        UIView * colorView=[[UIView alloc] initWithFrame:colorViewFrame];
        [colorView setBackgroundColor:[[ICEAppHelper shareInstance] appPublicColor]];
        [headerView addSubview:colorView];
        
        //剧集
        CGRect textLabelFrame=CGRectMake(CGRectGetMaxX(colorViewFrame)+8, 0, 40, headerViewHeight);
        UILabel * textLabel=[[UILabel alloc] initWithFrame:textLabelFrame];
        [textLabel setText:@"选集"];
        [textLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:16]];
        [textLabel setTextAlignment:NSTextAlignmentLeft];
        [textLabel setTextColor:[UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1]];
        [headerView addSubview:textLabel];
        
        //关闭按钮
        UIImage * closeImage=IMAGENAME(@"closeLookMoreEpisodeView@2x", @"png");
        CGFloat closeButtonWidth=closeImage.size.width+20;
        CGRect  closeButtonFrame=CGRectMake(_lookMoreEpisodeViewWidth-closeButtonWidth, 0, closeButtonWidth, headerViewHeight);
        ICEButton * closeButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:closeButtonFrame];
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hideLookMoreEpisodeView) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:closeButton];
        
        //灰色线
        CGRect   grayLineFrame=CGRectMake(0, headerViewHeight, _lookMoreEpisodeViewWidth, 1);
        UIView * grayLine=[[UIView alloc] initWithFrame:grayLineFrame];
        [grayLine setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
        [self addSubview:grayLine];
        
        if (LookMoreViewTableViewStyle==_episodeViewStyle)
        {
            CGFloat episodeTableViewMinY=CGRectGetMaxY(grayLineFrame);
            CGRect  episodeTableViewFrame=CGRectMake(0, episodeTableViewMinY, _lookMoreEpisodeViewWidth, _lookMoreEpisodeViewHeight-episodeTableViewMinY);
            self.episodeTableView=[[UITableView alloc] initWithFrame:episodeTableViewFrame style:UITableViewStylePlain];
            [_episodeTableView setDelegate:self];
            [_episodeTableView setDataSource:self];
            [_episodeTableView setShowsVerticalScrollIndicator:NO];
            [_episodeTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [self addSubview:_episodeTableView];
        }
        else
        {
            CGFloat itemWidth=_lookMoreEpisodeViewWidth/itemCountInRow;
            UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
            [layout setMinimumInteritemSpacing:0];
            [layout setMinimumLineSpacing:0];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            [layout setItemSize:CGSizeMake(itemWidth, itemWidth)];
            
            CGFloat episodeTableViewMinY=CGRectGetMaxY(grayLineFrame);
            CGRect  episodeCollectionViewFrame=CGRectMake(0, episodeTableViewMinY, _lookMoreEpisodeViewWidth, _lookMoreEpisodeViewHeight-episodeTableViewMinY);
            self.episodeCollectionView = [[UICollectionView alloc] initWithFrame:episodeCollectionViewFrame collectionViewLayout:layout];
            [_episodeCollectionView registerClass:[LookMoreEpisodeCollectionViewCell class] forCellWithReuseIdentifier:EpisodeCellReuseIdentifier];
            [_episodeCollectionView setBackgroundColor:self.backgroundColor];
            [_episodeCollectionView setShowsVerticalScrollIndicator:NO];
            [_episodeCollectionView setShowsHorizontalScrollIndicator:NO];
            [_episodeCollectionView setDataSource:self];
            [_episodeCollectionView setDelegate:self];
            [self addSubview:_episodeCollectionView];
        }
    }
    return self;
}

-(void)showLookMoreEpisodeView
{
    CGRect frame=self.frame;
    frame.origin.y=CGRectGetHeight(self.superview.frame)-_lookMoreEpisodeViewHeight;
    [super setHidden:NO];
    [UIView animateWithDuration:0.2 animations:^{
        [self setFrame:frame];
    }completion:^(BOOL finished){
    }];
}

-(void)hideLookMoreEpisodeView
{
    CGRect frame=self.frame;
    frame.origin.y=CGRectGetHeight(self.superview.frame);
    [UIView animateWithDuration:0.2 animations:^{
        [self setFrame:frame];
    }completion:^(BOOL finished){
        [self setHidden:YES];
    }];
}

-(void)reloadLookMoreEpisodeView
{
    if (LookMoreViewTableViewStyle==_episodeViewStyle)
    {
        [_episodeTableView reloadData];
    }
    else
    {
        [_episodeCollectionView reloadData];
    }
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
    LookMoreEpisodeCollectionViewCell *cell = (LookMoreEpisodeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:EpisodeCellReuseIdentifier
                                                                                                                       forIndexPath:indexPath];
    [cell updateCellWithModel:_episodeModelArray[[indexPath row]]];
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
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_episodeModelArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LookMoreEpisodeTableViewCell *  cell = [tableView dequeueReusableCellWithIdentifier:EpisodeCellIdentifier];
    if (cell == nil)
    {
        cell = [[LookMoreEpisodeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:EpisodeCellIdentifier
                                                        cellWidth:_lookMoreEpisodeViewWidth
                                                       cellHeight:CellHeight];
        
    }
    [cell updateCellWithModel:_episodeModelArray[indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger Index=[indexPath row];
    [self executeSelectEpisodeBlockWithIndex:Index];
}
@end
