//
//  HotSearchView.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "HotSearchView.h"
#import "SearchCell.h"
#import "HotSearchItem.h"


static CGFloat const searchHistoryItemHeight = 30;
static CGFloat const hotSearchItemHeight = 35;
@interface HotSearchView()
<
UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
{
    ICEButton              * m_reloadRequestButton;
    UITableView            * m_tableView;
    NSMutableArray         * m_arrayOfHotSearchKeyModel;
    NSDictionary           * m_titleAttributes;
    CGSize                   m_titleBoundsSize;
    NSStringDrawingOptions   m_titleOption;
    UICollectionView       * _hotView;
    UICollectionView       * _searchHistoryView;
    NSArray                * _searchHistoryDataArray;
    CGFloat                  _searchHistoryViewHeight;
    BOOL                     _searchHistoryViewIsNeedLoadMore;
    BOOL                     _searchHistoryLoadMoreBtnEnable;
}

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,assign) CGFloat hotSearchViewWidth;
@property (nonatomic,assign) CGFloat hotSearchViewHeight;
@property (nonatomic,assign) CGFloat titleBarHeight;
@property (nonatomic,copy)void (^selectBlock )(NSInteger ,NSString * );
@property (nonatomic,copy)void (^startScrollBlock)();

@end

@implementation HotSearchView

-(id)initWithFrame:(CGRect)frame
selectHotSearchCellBlock:(void (^)(NSInteger ,NSString * ))selectBlock
  startScrollBlock:(void (^)())startScrollBlock
{
    if (self=[super initWithFrame:frame])
    {
        self.selectBlock=selectBlock;
        self.startScrollBlock=startScrollBlock;
        _searchHistoryViewIsNeedLoadMore = NO; // 默认不加载更多
        m_arrayOfHotSearchKeyModel=[[NSMutableArray alloc] init];
        _hotSearchViewWidth=CGRectGetWidth(frame);
        _hotSearchViewHeight=CGRectGetHeight(frame);
        _titleBarHeight=26;
        
//        CGRect titleBarFrame=CGRectMake(0, 0, _hotSearchViewWidth, _titleBarHeight);
//        UIView * titleBar=[[UIView alloc] initWithFrame:titleBarFrame];
//        [titleBar setBackgroundColor:[UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1]];
//        [self addSubview:titleBar];
//        
//        CGRect colorViewFrame=CGRectMake(0, 0, 2.5, _titleBarHeight);
//        UIView * colorView=[[UIView alloc] initWithFrame:colorViewFrame];
//        [colorView setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
//        [titleBar addSubview:colorView];
//        
//        CGRect titleLabelFrame=CGRectMake(CGRectGetMaxX(colorViewFrame)+8, 0, 130, _titleBarHeight);
//        UILabel * titleLabel=[[UILabel alloc] initWithFrame:titleLabelFrame];
//        [titleLabel setText:@"热门搜索"];
//        [titleLabel setFont:[UIFont fontWithName:HYQiHei_65Pound size:15]];
//        [titleLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1]];
//        [titleBar addSubview:titleLabel];
//        
//        CGRect reloadRequestButtonFrame=CGRectMake(0, _titleBarHeight, _hotSearchViewWidth,40);
//        m_reloadRequestButton=[ICEButton buttonWithType:UIButtonTypeCustom];
//        [m_reloadRequestButton setFrame:reloadRequestButtonFrame];
//        [m_reloadRequestButton.titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:15]];
//        [m_reloadRequestButton setTitleColor:[ICEAppHelper shareInstance].appPublicColor forState:UIControlStateNormal];
//        [m_reloadRequestButton setTitle:@"数据获取失败，请点击重试" forState:UIControlStateNormal];
//        [m_reloadRequestButton addTarget:self action:@selector(sendGetHotSearchDataRequest) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:m_reloadRequestButton];
//        [m_reloadRequestButton setHidden:YES];
//
        [self createMainTableView];
        [self sendGetHotSearchDataRequest];
        [self updateSearchHistoryDataNeedLoadMore:NO];
    }
    return self;
}

- (void)createMainTableView {
    _mainTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_mainTableView];
}

- (void)updateSearchHistoryDataNeedLoadMore:(BOOL)needLoadMore {
    _searchHistoryViewIsNeedLoadMore = needLoadMore;
    _searchHistoryLoadMoreBtnEnable = NO;
    //将搜索历史记录从数据库中倒序取出
    NSArray *dataArray = [[[[TVDataHelper shareInstance] getAllSearchHistory] reverseObjectEnumerator] allObjects];
    if (dataArray == nil || dataArray.count == 0) {
        _searchHistoryDataArray = @[];
        _searchHistoryViewHeight = 0;
        
    }else if (dataArray.count > 4 && !needLoadMore) {
        _searchHistoryDataArray = [NSArray arrayWithObjects:dataArray[0], dataArray[1], dataArray[2], @"更多", nil];
        _searchHistoryLoadMoreBtnEnable = YES;
    }else {
        _searchHistoryDataArray = dataArray;
        
    }
    [_searchHistoryView reloadData];
    [_mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)sendGetHotSearchDataRequest
{
    __weak typeof(self) wself=self;
    [MYNetworking GET:urlOfHotSearch
                        parameters:nil
                          progress:nil
                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                               [wself addOrUpdateTableViewWithResponseData:responseObject];
                           }
                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                               [wself addOrUpdateTableViewWithResponseData:nil];
                           }];
}

-(void)addOrUpdateTableViewWithResponseData:(id)responseData
{
    
    if (responseData&&(1==[responseData[@"code"] integerValue]))
    {
        [m_arrayOfHotSearchKeyModel removeAllObjects];
        
        NSArray * hotSearchDatas=responseData[@"data"];
        
        for (NSString * titleStr in hotSearchDatas)
        {
            HotSearchItemModel *model = [[HotSearchItemModel alloc] init];
            
            if ([titleStr containsString:@"|"]) {
                model.keyType = [[titleStr componentsSeparatedByString:@"|"] lastObject];
                model.hotKey = [[titleStr componentsSeparatedByString:@"|"] firstObject];
            }else {
                model.keyType = nil;
                model.hotKey = titleStr;
            }
            model.num = [NSString stringWithFormat:@"%ld",[hotSearchDatas indexOfObject:titleStr]+1];
            [m_arrayOfHotSearchKeyModel addObject:model];
        }
        [_hotView reloadData];
        
//        [m_reloadRequestButton setHidden:YES];
//        [m_tableView setHidden:NO];
//        [m_tableView reloadData];
    }
    else
    {
//        [m_reloadRequestButton setHidden:NO];
//        [m_tableView setHidden:YES];
    }
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_startScrollBlock) {
        _startScrollBlock();
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        // 如果没有历史记录 返回cell
        if (_searchHistoryDataArray.count == 0) {
            return cell;
        }
        // 搜索记录
        UIView *badgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 2, 14)];
        badgeView.backgroundColor = APPColor;
        [cell addSubview:badgeView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 100, 14)];
        titleLabel.textColor = [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:1];
        titleLabel.text = @"搜索记录";
        titleLabel.font = [UIFont fontWithName:HYQiHei_55Pound size:14];
        [cell addSubview:titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, SCREEN_WIDTH, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:244/255.0f green:244/255.0f blue:244/255.0f alpha:1];
        [cell addSubview:lineView];
        
        UIButton *delAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        delAllBtn.frame = CGRectMake(SCREEN_WIDTH-55-8, 15, 55, 20);
        [delAllBtn setTitle:@"清空记录" forState:UIControlStateNormal];
        [delAllBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [delAllBtn addTarget:self action:@selector(delateAllSearchHistory) forControlEvents:UIControlEventTouchUpInside];
        delAllBtn.titleLabel.font = [UIFont fontWithName:HYQiHei_50Pound size:12];
        [cell addSubview:delAllBtn];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH/2, searchHistoryItemHeight);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _searchHistoryView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), SCREEN_WIDTH, searchHistoryItemHeight*((_searchHistoryDataArray.count+1)/2)) collectionViewLayout:flowLayout];
        [_searchHistoryView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SearchHistoryItem"];
        _searchHistoryView.dataSource = self;
        _searchHistoryView.delegate = self;
        _searchHistoryView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:_searchHistoryView];
        
        if (_searchHistoryViewIsNeedLoadMore) {
            // 收起按钮
            UIButton *packUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            packUpBtn.frame = CGRectMake(0, CGRectGetMaxY(_searchHistoryView.frame), SCREEN_WIDTH, 30);
            [packUpBtn setTitle:@"收起" forState:UIControlStateNormal];
            packUpBtn.titleLabel.font = [UIFont fontWithName:HYQiHei_55Pound size:14];
            [packUpBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [packUpBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
            [packUpBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -80)];
            [packUpBtn setImage:[UIImage imageNamed:@"packUpBtn"] forState:UIControlStateNormal];
            [packUpBtn addTarget:self action:@selector(packUpSearchHistoryView) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:packUpBtn];
        }
        
        
    }else {
        // 热门搜索
        UIView *badgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 2, 14)];
        badgeView.backgroundColor = APPColor;
        [cell addSubview:badgeView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 100, 14)];
        titleLabel.textColor = [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:1];
        titleLabel.text = @"热门搜索";
        titleLabel.font = [UIFont fontWithName:HYQiHei_55Pound size:14];
        [cell addSubview:titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, SCREEN_WIDTH, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:244/255.0f green:244/255.0f blue:244/255.0f alpha:1];
        [cell addSubview:lineView];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH/2, hotSearchItemHeight);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _hotView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), SCREEN_WIDTH, hotSearchItemHeight*5) collectionViewLayout:flowLayout];
        [_hotView registerNib:[UINib nibWithNibName:@"HotSearchItem" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"HotSearchItem"];
        _hotView.backgroundColor = [UIColor whiteColor];
        _hotView.dataSource = self;
        _hotView.delegate = self;
        [cell addSubview:_hotView];
    }
    
    
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight;
    if (indexPath.row == 0) {
        if (_searchHistoryDataArray.count == 0 || _searchHistoryDataArray == nil) {
            rowHeight = 0;
        }else {
            rowHeight = _searchHistoryViewIsNeedLoadMore? CGRectGetMaxY(_searchHistoryView.frame)+30: CGRectGetMaxY(_searchHistoryView.frame);
        }
    }else {
        rowHeight = CGRectGetMaxY(_hotView.frame);
    }
    return rowHeight;
}

#pragma mark UICollectionViewDelegate Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger number = 0;
    if (collectionView == _hotView) {
        number = m_arrayOfHotSearchKeyModel.count;
    }else if (collectionView == _searchHistoryView) {
        number = _searchHistoryDataArray.count;
    }
    return number;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *item;
    if (collectionView == _hotView) {
        
        HotSearchItem *hotItem = [collectionView dequeueReusableCellWithReuseIdentifier:@"HotSearchItem" forIndexPath:indexPath];
        hotItem.itemModel = m_arrayOfHotSearchKeyModel[indexPath.row];
        item = hotItem;
    }else if (collectionView == _searchHistoryView) {
        
        item = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchHistoryItem" forIndexPath:indexPath];
        
        UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, searchHistoryItemHeight)];
        keywordLabel.text = _searchHistoryDataArray[indexPath.row];
        [item addSubview:keywordLabel];
        if (indexPath.row == _searchHistoryDataArray.count-1 && _searchHistoryLoadMoreBtnEnable) {
            // 显示更多按钮item
            UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, searchHistoryItemHeight)];
            keywordLabel.text = _searchHistoryDataArray[indexPath.row];
            [item addSubview:keywordLabel];
            keywordLabel.backgroundColor = [UIColor greenColor];
            
        }else {
            // 历史记录item
            UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, searchHistoryItemHeight)];
            keywordLabel.text = _searchHistoryDataArray[indexPath.row];
            [item addSubview:keywordLabel];
        }
    }
    return item;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _hotView) {
        HotSearchItemModel *model = m_arrayOfHotSearchKeyModel[indexPath.row];
        if (_selectBlock) {
            _selectBlock(1,model.hotKey);
        }
    }else if (collectionView == _searchHistoryView) {
        if (indexPath.row == _searchHistoryDataArray.count-1 && _searchHistoryLoadMoreBtnEnable) {

            [self updateSearchHistoryDataNeedLoadMore:YES];
        }else {
            _selectBlock(1,_searchHistoryDataArray[indexPath.row]);
        }

    }
}

#pragma mark - 响应事件

- (void)packUpSearchHistoryView {
    [self updateSearchHistoryDataNeedLoadMore:NO];
}

- (void)delateAllSearchHistory {
    [[TVDataHelper shareInstance] delateAllSearchHistory];
    [self updateSearchHistoryDataNeedLoadMore:NO];
}
@end





