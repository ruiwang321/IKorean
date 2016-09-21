//
//  HomeViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/8.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "HomeViewController.h"
#import "ISearchBar.h"
#import "HomeMainTableViewCell.h"
#import "SettingViewController.h"
#import "HistoryViewController.h"
#import "EpisodeSortViewController.h"
#import "PlanTableViewController.h"
#import "SearchView.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>{
    JPushModel *m_model;
}
@property (nonatomic, strong) ICEPullTableView * mainTableView;
@property (nonatomic, strong) ICESlideshowScrollView * slideshowScrollView;
@property (nonatomic, strong) ISearchBar * searchBar;
@property (nonatomic, strong) NSMutableArray *listViewModelsArray;
@property (nonatomic, assign) BOOL isHaveRefreshed;
@property (nonatomic, assign) CGFloat searchBarOffsetYForBlur;
@property (nonatomic, assign) CGFloat searchBarOffsetYForTranslucentStyle;
@property (nonatomic, assign) CGFloat shadowViewHeight;
@end

@implementation HomeViewController

- (id)init
{
    if (self=[super init])
    {
        _isHaveRefreshed=NO;
        self.listViewModelsArray=[[NSMutableArray alloc] init];
//        __weak typeof(self) wself=self;
//        self.selectMovieItemBlock=^(MovieItemModel * itemModel)
//        {
//            [wself goTVDetailViewWithID:itemModel.movieID title:itemModel.title];
//        };
//        self.selectSomeColumnsBlock=^(FilterUnitItemModel * model)
//        {
//            [wself mobEventWithTitle:model.title];
//            [wself goFilterViewControllerWithSelectModel:model];
//        };
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NotificationOfPush object:nil];
}


- (id)initWithJPushModel:(JPushModel *)model
{
    if (self=[super init])
    {
        m_model=model;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(haveNotification:)
                                                     name:NotificationOfPush
                                                   object:nil];
    }
    return self;
}

-(void)receivePush:(JPushModel *)model
{
    //    TVDetailViewController * tv=[[TVDetailViewController alloc]initWithID:model.movieID title:model.movieTitle];
    //    [self.navigationController pushViewController:tv animated:!model.isReceivePushInBackGround];
}

-(void)haveNotification:(NSNotification *)notification
{
    NSDictionary * userInfo=[notification userInfo];
    if (userInfo)
    {
        JPushModel * model=userInfo[@"data"];
        if (model)
        {
            [self receivePush:model];
        }
    }
}

- (void)addChileView
{
    if (_mainTableView==nil)
    {
        __weak typeof(self) wself=self;
        _shadowViewHeight=40;
        CGFloat  slideshowScrollViewOriginalWidth=375;
        CGFloat  slideshowScrollViewOriginalHeight=210;
        CGFloat  slideshowScrollViewHeight=self.screenWidth*slideshowScrollViewOriginalHeight/slideshowScrollViewOriginalWidth;
        _searchBarOffsetYForBlur=slideshowScrollViewHeight-self.navigationBarHeight;
        _searchBarOffsetYForTranslucentStyle=_searchBarOffsetYForBlur-_shadowViewHeight;
        
        //幻灯片
        CGRect slideshowScrollViewFrame=CGRectMake(0, 0, self.screenWidth, slideshowScrollViewHeight);
        self.slideshowScrollView=[[ICESlideshowScrollView alloc] initWithFrame:slideshowScrollViewFrame
                                                          placeholderImageName:@"publicPlaceholder@2x"
                                                               selectPageBlock:^(ICESlideshowPageModel *pageModel) {
//                                                                   [MobClick event:@"1"];
//                                                                   [wself goTVDetailViewWithID:pageModel.rel_id title:pageModel.title];
                                                               }];
        
        // 排期表和剧集分类按钮视图
        UIView *btnContentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(slideshowScrollViewFrame), self.screenWidth, 60)];
        btnContentView.backgroundColor = [UIColor whiteColor];
        
        UIButton *planTableBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnContentView addSubview:planTableBtn];
        [planTableBtn setBackgroundImage:[UIImage imageNamed:@"planTableBtn"] forState:UIControlStateNormal];
        [planTableBtn addTarget:self action:@selector(goPlanTableVC) forControlEvents:UIControlEventTouchUpInside];
        planTableBtn.frame = CGRectMake(10, 10, (self.screenWidth-30)/2.0f, (self.screenWidth-30)/2.0f*82/345);
        
        UIButton *EpisodeSortBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnContentView addSubview:EpisodeSortBtn];
        [EpisodeSortBtn setBackgroundImage:[UIImage imageNamed:@"EpisodeSortBtn"] forState:UIControlStateNormal];
        [EpisodeSortBtn addTarget:self action:@selector(goEpisodeSortVC) forControlEvents:UIControlEventTouchUpInside];
        EpisodeSortBtn.frame = CGRectMake(CGRectGetMaxX(planTableBtn.frame)+10, 10, (self.screenWidth-30)/2.0f, (self.screenWidth-30)/2.0f*82/345);
        
        
        UIView * headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, CGRectGetMaxY(btnContentView.frame))];
        [headerView addSubview:_slideshowScrollView];
        [headerView addSubview:btnContentView];
        
        
        
        MainTabBarController * mainTabBarController=(MainTabBarController *)self.tabBarController;
        CGRect tableViewFrame=CGRectMake(0, 0, self.screenWidth, self.screenHeight-mainTabBarController.myTabBar.bounds.size.height);
        self.mainTableView=[[ICEPullTableView alloc] initWithFrame:tableViewFrame
                                                isNeedLoadMore:NO
                                                 tableViewName:@"HomePageTableView"
                                           refreshTimeInterval:1800];
//        [_mainTableView registerClass:[HomeMainTableViewCell class] forCellReuseIdentifier:@"mainCell"];

        _mainTableView.tableViewOperationStartBlock=^(ICEPullTableViewOperationTypeOptions operationType){
            [wself sendGetHomePageRequest];
            [wself.mainTableView tableOperationCompleteWithOperationType:ICEPullTableViewRefresh
                                                  andOperationResult:ICEPullTableViewOperationSuccess];
        };
        _mainTableView.scrollViewOperationStartBlock=^(ScrollViewOperationTypeOptions operationType,CGFloat offsetY){
            if (ScrollViewDidScroll==operationType) {
                [wself updateSearchBarWithOffsetY:offsetY];
            }
        };
        
        [_mainTableView setDelegate:self];
        [_mainTableView setDataSource:self];
        [_mainTableView setTableHeaderView:headerView];
        [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:_mainTableView];
        
        //项目需要加了一个红色半屏的背景页
        UIView * tableViewBackGroundView=[[UIView alloc] initWithFrame:_mainTableView.bounds];
        UIView * colorView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, CGRectGetHeight(tableViewFrame)/2)];
        [colorView setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
        [tableViewBackGroundView addSubview:colorView];
        [_mainTableView setBackgroundView:tableViewBackGroundView];
        
        if (ISPASSAUDIT || 1)
        {
            //搜索栏
            self.searchBar=[[ISearchBar alloc] initWithFrame:self.myNavigationBar.frame isNeedSpecialEfficacy:YES];
            __weak typeof(self) wself = self;
            _searchBar.selectSearchBlock=^{
                [wself showSearchView];
            };
            _searchBar.selectHistoryBlock=^{
                [wself goHistoryView];
            };
            _searchBar.selectSettingBlock=^{
                [wself goSettingView];
            };
            [self.view addSubview:_searchBar];
        }
    }
}

- (void)sendGetHomePageRequest
{
    __weak typeof(self) wself=self;
    if (_isHaveRefreshed)
    {
        [_mainTableView refreshNewDataStart];
        [MYNetworking GET:urlOfGetHomePage
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [wself updateChildViewWithResponseData:responseObject];
                              }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  [wself updateChildViewWithResponseData:nil];
                              }];
    }
    else
    {
        [self startLoading];
        [self hideNetErrorAlert];
        [MYNetworking GET:urlOfGetHomePage
                           parameters:nil
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [wself updateChildViewWithResponseData:responseObject];
                                  [wself stopLoading];
                              }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  [wself updateChildViewWithResponseData:nil];
                                  [wself stopLoading];
                                  [wself showNetErrorAlert];
                              }];
    }
}

-(void)sendRequestAgain
{
    [self sendGetHomePageRequest];
}

- (void)updateChildViewWithResponseData:(id)responseData
{
    if (responseData)
    {
        if (1 == [responseData[@"code"] integerValue])
        {
            [self addChileView];
            _isHaveRefreshed = YES;

            NSArray * slideshowData = responseData[@"focus"];

            //幻灯片数据
            if (slideshowData&&[slideshowData count])
            {
                NSMutableArray * arrayOfSlideshowModels=[NSMutableArray array];
                for (NSDictionary * dic in slideshowData)
                {
                    ICESlideshowPageModel * pageModel=[[ICESlideshowPageModel alloc]init];
                    [pageModel setValuesForKeysWithDictionary:dic];
                    [arrayOfSlideshowModels addObject:pageModel];
                }
                [_slideshowScrollView setSlideshowScrollViewWithPageModels:arrayOfSlideshowModels];
            }
            NSArray *recommendData = responseData[@"recommend"];
            _listViewModelsArray = [NSMutableArray array];
            if (recommendData && recommendData.count) {
                for (NSDictionary *arrDic in recommendData) {
                    HomeMainTableViewCellModel *model = [[HomeMainTableViewCellModel alloc] init];
                    [model setValuesForKeysWithDictionary:arrDic];
                    [_listViewModelsArray addObject:model];
                }
            }
        }
        [_mainTableView reloadData];
    }
    [_mainTableView tableOperationCompleteWithOperationType:ICEPullTableViewRefresh
                                         andOperationResult:ICEPullTableViewOperationSuccess];
}


- (void)updateSearchBarWithOffsetY:(CGFloat)offsetY
{
    if (_searchBar)
    {
        if(offsetY>=_searchBarOffsetYForBlur)
        {
            [_searchBar updateSearchBarWithSearchBarStyle:ISearchBarBlurStyle alpha:0];
        }
        else if(offsetY>=_searchBarOffsetYForTranslucentStyle)
        {
            CGFloat alpha=(_searchBarOffsetYForBlur-offsetY)/_shadowViewHeight;
            [_searchBar updateSearchBarWithSearchBarStyle:ISearchBarColorTranslucentStyle alpha:alpha];
        }
        else
        {
            [_searchBar updateSearchBarWithSearchBarStyle:ISearchBarShadowStyle alpha:0];
        }
        
        if (offsetY<=-[ICEPullTableView refreshViewHeight])
        {
            [_searchBar isShowSearchBar:NO];
        }
        else if(offsetY>=0)
        {
            [_searchBar isShowSearchBar:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (m_model)
    {
        [self receivePush:m_model];
        m_model=nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) wself = self;
    [MYNetworking GET:urlOfGetHomePage
           parameters:nil
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [wself updateChildViewWithResponseData:responseObject];
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  [wself updateChildViewWithResponseData:nil];

              }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - 响应事件方法
- (void)showSearchView {
    __weak typeof(self) wself = self;
    SearchView * searchView=[[SearchView alloc] initWithFrame:self.view.bounds
                                             selectMovieBlock:^(NSInteger movieID, NSString * title) {
//                                                 [wself goTVDetailViewWithID:movieID title:title];
                                                 [wself.tabBarController.view endEditing:YES];
                                             }];
    [self.navigationController.view addSubview:searchView];
    NSLog(@"搜索qweqwe");
}

- (void)goHistoryView {
    [self.navigationController pushViewController:[[HistoryViewController alloc] init] animated:YES];
    NSLog(@"观看记录qw12131");
}

- (void)goSettingView {
    [self.navigationController pushViewController:[[SettingViewController alloc] init] animated:YES];
    NSLog(@"设置q5342");
}

- (void)goPlanTableVC {
    [self.navigationController pushViewController:[[PlanTableViewController alloc] init] animated:YES];
}

- (void)goEpisodeSortVC {
    EpisodeSortViewController *episodeSortVC = [[EpisodeSortViewController alloc] init];
    episodeSortVC.imageItemModel.title = @"剧集分类";
    [self.navigationController pushViewController:episodeSortVC animated:YES];
}

#pragma mark - tableView代理和协议方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [HomeMainTableViewCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listViewModelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainCell"];
    if (cell == nil) {
        cell = [[HomeMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mainCell"];
        
    }
    
    cell.cellModel = _listViewModelsArray[indexPath.row];
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
