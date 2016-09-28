//
//  EpisodeSortViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "EpisodeSortViewController.h"
#import "MovieItemTableViewCell.h"
#import "MovieItem.h"
#import "EpisodeSortOptionsView.h"
#import "SearchView.h"

static NSInteger const Page_size = 30;
static CGFloat const optionDisplayHeight = 46;
@interface EpisodeSortViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    MovieItemCellLayoutHelper * m_cellLayoutHelper;
    NSInteger page;
    BOOL isShow;
    CGFloat lastContentOffsetY;
    NSMutableDictionary *filterTitleAndIdDic;
}

@property (nonatomic,copy) MovieItemAction selectSomeMovieItemBlock;
@property (nonatomic,strong) NSMutableArray * movieItemModelsArray;
@property (nonatomic,strong) ICEPullTableView  * mainTableView;
@property (nonatomic,strong) EpisodeSortOptionsView * EpisodeSortOptionsView;
@property (nonatomic,strong) UILabel * optionDisplayView;
@property (nonatomic,assign) CGFloat EpisodeSortOptionsViewMinYForHide;
@property (nonatomic,assign) CGFloat EpisodeSortOptionsViewMinYForShow;

@end

@implementation EpisodeSortViewController

-(id)init
{
    if (self=[super init])
    {
        isShow = YES;
        page = 1;
        filterTitleAndIdDic = [NSMutableDictionary dictionary];
        _imageItemModel = [[FilterUnitItemModel alloc] init];
        m_cellLayoutHelper=[MovieItemCellLayoutHelper shareInstance];
        self.movieItemModelsArray=[[NSMutableArray alloc] init];
//        __weak typeof(self) wself=self;
//        self.selectSomeMovieItemBlock=^(MovieItemModel * movieItemModel){
//            NSLog(@"vid:%ld",movieItemModel.vid);
//            [wself goTVDetailViewWithID:movieItemModel.movieID title:movieItemModel.title];
//        };
    }
    return self;
}

- (void)returnLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSearchView {
    __weak typeof(self) wself = self;
    SearchView * searchView=[[SearchView alloc] initWithFrame:self.view.bounds
                                             selectMovieBlock:^(NSInteger movieID, NSString * title) {
                                                 //                                                 [wself goTVDetailViewWithID:movieID title:title];
                                                 [wself.tabBarController.view endEditing:YES];
                                             }];
    [self.navigationController.view addSubview:searchView];
    NSLog(@"显示搜索视图");
}

- (void)goTVDetailViewWithID:(NSInteger)movieID title:(NSString *)title
{
//    TVDetailViewController * tv=[[TVDetailViewController alloc]initWithID:movieID title:title];
//    [self.navigationController pushViewController:tv animated:YES];
}


- (void)addNewDataWithNewDatas:(NSArray *)arrayOfNewDatas
{
    NSInteger itemCountInCell=m_cellLayoutHelper.itemCountInCell;
    
    for (NSDictionary * dic in arrayOfNewDatas)
    {
        MovieItemModel * model=[[MovieItemModel alloc] init];
        [model setValuesForKeysWithDictionary:dic];
        
        NSMutableArray * lastRowData=[_movieItemModelsArray lastObject];
        if (lastRowData==nil||
            [lastRowData count]>=itemCountInCell)
        {
            lastRowData=[[NSMutableArray alloc] initWithCapacity:itemCountInCell];
            [lastRowData addObject:model];
            [_movieItemModelsArray addObject:lastRowData];
        }
        else
        {
            [lastRowData addObject:model];
        }
    }
}

- (void)createEpisodeSortOptionsViewWithResponseData:(id)responseData
{
    if (responseData&&(1==[responseData[@"code"]integerValue]))
    {
        
        NSMutableArray * arrayOfFilterOptionsData=[NSMutableArray array];
        NSArray *arrayOfKeys=@[@"sort", @"cate", @"year", @"completed"];
        for (NSString * key in arrayOfKeys)
        {
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
            [arrayOfFilterOptionsData addObject:@{key:responseData[key]}];
            for (NSDictionary *arrDic in responseData[key]) {
                [tempDic addEntriesFromDictionary:@{arrDic[@"id"]:arrDic[@"title"]}];
            }
            [filterTitleAndIdDic addEntriesFromDictionary:@{key:tempDic}];
        }
        
        
        //添加选中item id到参数中
        [arrayOfFilterOptionsData addObject:@{@"selected":@{@"sort"       :_imageItemModel.sort_type,
                                                            @"cate"       :_imageItemModel.cate_id,
                                                            @"year"       :_imageItemModel.year_id,
                                                            @"completed"  :_imageItemModel.is_complete}
                                              }];
        if (_EpisodeSortOptionsView==nil)
        {
            __weak typeof(self) wself=self;
            CGFloat EpisodeSortOptionsViewHeight=([arrayOfFilterOptionsData count]-1)*heightOfFilterOptionsBar; //减一是因为添加了itemID参数 数组中实际有一个不是item
            _EpisodeSortOptionsViewMinYForHide=64;
            _EpisodeSortOptionsViewMinYForShow=self.navigationBarHeight;
            CGRect  EpisodeSortOptionsViewFrame=CGRectMake(0, _EpisodeSortOptionsViewMinYForShow, self.screenWidth, EpisodeSortOptionsViewHeight);
            self.EpisodeSortOptionsView=[[EpisodeSortOptionsView alloc] initWithFrame:EpisodeSortOptionsViewFrame
                                                                                 data:arrayOfFilterOptionsData
                                                          selectSomeFilterOptionBlock:^(NSString *filterType, NSString *optionID) {
                                                            
                                                            if ([filterType isEqualToString:@"sort"])
                                                            {
                                                                wself.imageItemModel.sort_type=optionID;
                                                            }
                                                            else if([filterType isEqualToString:@"cate"])
                                                            {
                                                                wself.imageItemModel.cate_id=optionID;
                                                            }
                                                            else if([filterType isEqualToString:@"completed"])
                                                            {
                                                                wself.imageItemModel.is_complete=optionID;
                                                            }
                                                            else if ([filterType isEqualToString:@"year"])
                                                            {
                                                                wself.imageItemModel.year_id=optionID;
                                                            }
                                                            [wself sendGetFilterDataRequestWithPullTableViewType:ICEPullTableViewRefresh];
                                                            [self updateOptionDisplayView];
                                                          
                                                          }];
            [self.view insertSubview:_EpisodeSortOptionsView belowSubview:self.myNavigationBar];
            
            // 筛选选中项显示
            _optionDisplayView = [[UILabel alloc] initWithFrame:CGRectMake(0, self.navigationBarHeight, self.screenWidth, optionDisplayHeight)];
            _optionDisplayView.backgroundColor = [UIColor whiteColor];
            _optionDisplayView.textColor = APPColor;
            _optionDisplayView.font = [UIFont fontWithName:HYQiHei_50Pound size:14];
            [self.view insertSubview:_optionDisplayView belowSubview:_EpisodeSortOptionsView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuView)];
            
            UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.screenWidth-17-10, (optionDisplayHeight-9)/2.0f, 17, 9)];
            arrowImg.image = IMAGENAME(@"episodeSortOptionDisplayShow@2x", @"png");
            [_optionDisplayView addSubview:arrowImg];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_optionDisplayView.frame)-1, self.screenWidth, 1)];
            line.backgroundColor = [UIColor colorWithRed:222/255.0f green:222/255.0f blue:222/255.0f alpha:1];
            [_optionDisplayView addSubview:line];
            _optionDisplayView.userInteractionEnabled = YES;
            [_optionDisplayView addGestureRecognizer:tap];
            [self updateOptionDisplayView];
        }
    }
    
}

- (void)sendGetFilterOptionsRequest
{
    [self startLoading];
    __weak typeof(self) wself=self;
    [MYNetworking GET:urlOfFilterOptions
                     parameters:nil
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            [wself createEpisodeSortOptionsViewWithResponseData:responseObject];
                            [self sendGetFilterDataRequestWithPullTableViewType:ICEPullTableViewRefresh];
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            [wself showNetErrorAlert];
                        }];
}

- (void)addOrUpdateTableViewWithResponseData:(id)responseData
                       withPullTableViewType:(ICEPullTableViewOperationTypeOptions)operationType
{
    ICEPullTableViewOperationResultOptions  operationResult = ICEPullTableViewOperationSuccess;
    if (responseData&&[responseData[@"code"] integerValue]==1&&[responseData[@"data"] count]>0)
    {
        if(ICEPullTableViewRefresh==operationType)
        {
            [_movieItemModelsArray removeAllObjects];
        }
        [self addNewDataWithNewDatas:responseData[@"data"]];
    }
    else if(responseData&&[responseData[@"data"] count]==0)
    {
        //暂无更多
        if(ICEPullTableViewRefresh==operationType)
        {
            [_movieItemModelsArray removeAllObjects];
        }
        operationResult=ICEPullTableViewOperationNoMore;
    }
    else
    {
        //失败
        operationResult=ICEPullTableViewOperationFailed;
    }
    
    if (responseData)
    {
        if (_mainTableView==nil)
        {
            CGRect tabelViewFrame=CGRectMake(0, CGRectGetMaxY(_EpisodeSortOptionsView.frame), self.screenWidth, self.screenHeight-CGRectGetMaxY(_EpisodeSortOptionsView.frame));
            __weak typeof(self) wself=self;
            self.mainTableView=[[ICEPullTableView alloc] initWithFrame:tabelViewFrame
                                                    isNeedLoadMore:YES
                                                     tableViewName:nil
                                               refreshTimeInterval:0];
            _mainTableView.tableViewOperationStartBlock=^(ICEPullTableViewOperationTypeOptions operationType){
                [wself sendGetFilterDataRequestWithPullTableViewType:operationType];
            };
            _mainTableView.scrollViewOperationStartBlock = ^(ScrollViewOperationTypeOptions operationType,CGFloat offsetY){
                if (operationType == ScrollViewDidScroll)
                {
                    [wself mainTableViewDidScrollOffSetY:offsetY];
                }
            };
            [_mainTableView setDelegate:self];
            [_mainTableView setDataSource:self];
            [_mainTableView setBackgroundColor:[UIColor clearColor]];
            [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            if (_EpisodeSortOptionsView)
            {
                [self.view insertSubview:_mainTableView belowSubview:_EpisodeSortOptionsView];
            }
            else
            {
                [self.view insertSubview:_mainTableView atIndex:0];
            }
            
//            //横幅广告
//            CGFloat bannerAdViewHeight=50;
//            CGRect  bannerAdUnitViewFrame = CGRectMake(0, self.screenHeight-bannerAdViewHeight, self.screenWidth, bannerAdViewHeight);
//            BannerAdUnitView * bannerAdUnitView=[[BannerAdUnitView alloc] initWithFrame:bannerAdUnitViewFrame];
//            [bannerAdUnitView setBackgroundColor:[UIColor clearColor]];
//            [self.view addSubview:bannerAdUnitView];
            
            
            
        }
        else
            [_mainTableView reloadData];
    }
    [_mainTableView tableOperationCompleteWithOperationType:operationType
                                     andOperationResult:operationResult];
}

- (void)sendGetFilterDataRequestWithPullTableViewType:(ICEPullTableViewOperationTypeOptions)operationType
{
    if (operationType == ICEPullTableViewLoadMore) {
        page++;
    }else if (operationType == ICEPullTableViewRefresh) {
        page = 1;
    }
    NSDictionary * dicOfParameters=@{
                                     @"is_complete" :@(_imageItemModel.is_complete.integerValue),
                                     @"cate_id"     :_imageItemModel.cate_id,
                                     @"year_id"     :_imageItemModel.year_id,
                                     @"sort_type"   :_imageItemModel.sort_type,
                                     @"page_size"   :@(Page_size),
                                     @"page"        :@(page)
                                     };
    __weak typeof(self) wself=self;
    if (_mainTableView==nil)
    {
        [self hideNetErrorAlert];
        [MYNetworking GET:urlOfFilter
                         parameters:dicOfParameters
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                [wself addOrUpdateTableViewWithResponseData:responseObject
                                                      withPullTableViewType:operationType];
                                
                                [wself stopLoading];
                            }
                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                [wself addOrUpdateTableViewWithResponseData:nil
                                                      withPullTableViewType:operationType];
                                [wself stopLoading];
                                [wself showNetErrorAlert];
                            }];
        
    }
    else
    {
        [MYNetworking GET:urlOfFilter
                         parameters:dicOfParameters
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                [wself addOrUpdateTableViewWithResponseData:responseObject
                                                      withPullTableViewType:operationType];
                            }
                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                [wself addOrUpdateTableViewWithResponseData:nil withPullTableViewType:operationType];
                            }];
    }

}
- (void)sendRequestAgain
{
    [self sendGetFilterDataRequestWithPullTableViewType:ICEPullTableViewRefresh];
}

- (void)updateOptionDisplayView {
    NSString *sort = filterTitleAndIdDic[@"sort"][@(_imageItemModel.sort_type.integerValue)];
    NSString *year = _imageItemModel.year_id.integerValue==0?@"":filterTitleAndIdDic[@"year"][@(_imageItemModel.year_id.integerValue)];
    NSString *completed = _imageItemModel.is_complete.integerValue==99?@"":filterTitleAndIdDic[@"completed"][@(_imageItemModel.is_complete.integerValue)];
    NSString *cate = _imageItemModel.cate_id.integerValue==0?@"":filterTitleAndIdDic[@"cate"][@(_imageItemModel.cate_id.integerValue)];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSString *str in @[sort, cate, year, completed]) {
        if (![str isEqualToString:@""]) {
            [tempArr addObject:str];
        }
    }
    _optionDisplayView.text = [NSString stringWithFormat:@"  %@",[tempArr componentsJoinedByString:@" · "]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:self.imageItemModel.title];
    [self setLeftButtonWithImageName:@"back@2x" action:@selector(returnLastView)];
    [self setRightButtonWithImageName:@"searchNavBar@2x" action:@selector(showSearchView)];
    [self sendGetFilterOptionsRequest];
//    [self sendGetFilterDataRequestWithPullTableViewType:ICEPullTableViewRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_movieItemModelsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FilterTableViewCell";
    MovieItemTableViewCell *  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[MovieItemTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:CellIdentifier
                                                  cellWidth:m_cellLayoutHelper.cellWidth
                                                 cellHeight:m_cellLayoutHelper.cellHeight];
        cell.selectBlock=_selectSomeMovieItemBlock;
    }
    [cell updateCellWithDicOfData:_movieItemModelsArray[indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return m_cellLayoutHelper.cellHeight;
}

#pragma mark - 滑动隐藏optionView
- (void)mainTableViewDidScrollOffSetY:(CGFloat)offsetY {
//    NSLog(@"%lf--%d",offsetY,isShow);
    if (offsetY<=0 && !isShow) {
        
        [self showMenuView];
    }
    
    if (offsetY>lastContentOffsetY && isShow && offsetY >= 150) {
        
        [self hideMenuView];
    }
    
    
    lastContentOffsetY = offsetY > 0 ? offsetY : 0;
}


- (void)hideMenuView {
    isShow = NO;
    [UIView animateWithDuration:0.5f animations:^{
        _EpisodeSortOptionsView.transform = CGAffineTransformMakeTranslation(0, -100);
        CGRect mainTBFrame = _mainTableView.frame;
        _mainTableView.frame = CGRectMake(0, mainTBFrame.origin.y-100, mainTBFrame.size.width, mainTBFrame.size.height+100);
        _EpisodeSortOptionsView.alpha = 0;
    }completion:^(BOOL finished) {
//        isShow = NO;
    }];
}

- (void)showMenuView {
    isShow = YES;
    _EpisodeSortOptionsView.alpha = 1;
    [UIView animateWithDuration:0.5f animations:^{
        _EpisodeSortOptionsView.transform = CGAffineTransformMakeTranslation(0, 0);
        CGRect mainTBFrame = _mainTableView.frame;
        _mainTableView.frame = CGRectMake(0, mainTBFrame.origin.y+100, mainTBFrame.size.width, mainTBFrame.size.height-100);
    }completion:^(BOOL finished) {
//        isShow = YES;
    }];
}
#pragma mark -
@end
