//
//  TVDetailViewController.m
//  ICinema
//
//  Created by wangyunlong on 16/6/16.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "TVDetailViewController.h"
#import "TVDetailTopUnitView.h"
#import "TVDetailUnitView.h"
#import "TVDetailRecommendUnitView.h"
#import "TVDetailIntroductionUnitCell.h"
#import "AdInstlManager.h"
#import "AdInstlManagerDelegate.h"

@interface TVDetailViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
AdInstlManagerDelegate,
UIAlertViewDelegate
>

@property (nonatomic,assign) NSInteger tvID;
@property (nonatomic,weak) AFHTTPSessionManager * getTVContentDataManager;
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) TVDetailTopUnitModel * topUnitModel;
@property (nonatomic,copy) ExpandCellBlock expandCellBlock;
@property (nonatomic,strong) TVDetailIntroductionUnitCellModel * cellModel;
@property (nonatomic,strong) AdInstlManager * adInstlManager;
@end

@implementation TVDetailViewController
-(void)dealloc
{
    self.adInstlManager.delegate=nil;
    self.adInstlManager=nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(id)initWithID:(NSInteger)tvID
{
    if (self=[super init])
    {
        _tvID=tvID;
        self.getTVContentDataManager=[AFHTTPSessionManager shareInstance];
        self.adInstlManager=[AdInstlManager managerWithAdInstlKey:ADViewKey
                                                     WithDelegate:self];
        __weak typeof(self) wself=self;
        self.expandCellBlock=^{
            [wself reloadIntroductionCell];
        };
    }
    return self;
}

- (void)returnLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goRecommendVideoWithMovieItemModel:(MovieItemModel *)model
{
    TVDetailViewController * vc=[[TVDetailViewController alloc] initWithID:model.vid];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addOrUpdateChildViewWithResponseData:(id)responseData
{
    if (responseData&&1==[responseData[@"code"]integerValue])
    {
        if (_tableView==nil)
        {
            NSDictionary * data=responseData[@"data"];
            __weak typeof(self) wself=self;
            NSArray * videos=data[@"videos"];
            //基础信息单元数据
            self.topUnitModel=[[TVDetailTopUnitModel alloc] init];
            _topUnitModel.movieID=_tvID;
            _topUnitModel.title=data[@"title"];
            _topUnitModel.grade=[data[@"score"]floatValue];
            _topUnitModel.imgUrl=data[@"img"];
            _topUnitModel.types=data[@"cate"];
            _topUnitModel.source=data[@"source"];
            _topUnitModel.isCanPlay=(videos&&[videos count])?YES:NO;
            
            [self setTitle:_topUnitModel.title];
            
            //基础信息单元
            CGRect frameOfTopUnitView=CGRectMake(0, 0, self.screenWidth, 0);
            TVDetailTopUnitView * topUnitView=[[TVDetailTopUnitView alloc] initWithFrame:frameOfTopUnitView
                                                                                   model:_topUnitModel];
            frameOfTopUnitView=topUnitView.frame;

            //详情单元
            CGRect frameOfDetailUnitView=CGRectMake(0,CGRectGetMaxY(frameOfTopUnitView)+5, self.screenWidth, 0);
            TVDetailUnitView * detailUnitView=[[TVDetailUnitView alloc] initWithFrame:frameOfDetailUnitView
                                                                             director:data[@"director"]
                                                                                actor:data[@"actor"]
                                                                                 area:data[@"area"]
                                                                             showtime:data[@"showtime"]];
            frameOfDetailUnitView=detailUnitView.frame;
            
            CGRect frameOfHeaderView=CGRectMake(0, 0, self.screenWidth, CGRectGetMaxY(frameOfDetailUnitView));
            UIView * headerView=[[UIView alloc] initWithFrame:frameOfHeaderView];
            [headerView setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
            [headerView addSubview:topUnitView];
            [headerView addSubview:detailUnitView];
            
            //介绍单元数据
            self.cellModel=[[TVDetailIntroductionUnitCellModel alloc] initWithIntroduction:data[@"summary"]
                                                                                 cellWidth:self.screenWidth];

            //推荐单元
            TVDetailRecommendUnitView * recommendUnitView=[[TVDetailRecommendUnitView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, 0)
                                                                                           recommendVideos:responseData[@"recommend"]
                                                                                  selectSomeMovieItemBlock:^(MovieItemModel *movieItemModel) {
                                                                                      [wself goRecommendVideoWithMovieItemModel:movieItemModel];
                                                                                  }];
            
            CGRect tableViewFrame=CGRectMake(0, self.navigationBarHeight, self.screenWidth, self.screenHeight-self.navigationBarHeight);
            self.tableView=[[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
            [_tableView setDelegate:self];
            [_tableView setDataSource:self];
            [_tableView setTableHeaderView:headerView];
            [_tableView setTableFooterView:recommendUnitView];
            [_tableView setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:_tableView];
        }
        [_tableView setHidden:NO];
        [self hideNetErrorAlert];
    }
    else
    {
        [_tableView setHidden:YES];
        [self showNetErrorAlert];
    }
}

- (void)sendGetTVContentDataRequest
{
    [self startLoading];
    __weak typeof(self) wself=self;
    [MYNetworking GET:urlOfTVContent
                       parameters:@{@"vid":@(_tvID)}
                         progress:nil
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                              [wself stopLoading];
                              [wself addOrUpdateChildViewWithResponseData:responseObject];
                          }
                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                              [wself stopLoading];
                              [wself addOrUpdateChildViewWithResponseData:nil];
                          }];
    
}

- (void)sendRequestAgain
{
    [self hideNetErrorAlert];
    [self sendGetTVContentDataRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLeftButtonWithImageName:@"return_lastView@2x" action:@selector(returnLastView)];
    [self sendGetTVContentDataRequest];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)reloadIntroductionCell
{
    _cellModel.isExpand=!_cellModel.isExpand;
    NSIndexPath    *indexPath =  [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView  beginUpdates];
    [_tableView  reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView  endUpdates];
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TVDetailIntroductionUnitCell";
    TVDetailIntroductionUnitCell *  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[TVDetailIntroductionUnitCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:CellIdentifier
                                                        cellWidth:self.screenWidth
                                                       cellHeight:_cellModel.cellHeight];
        cell.expandCellBlock=_expandCellBlock;
                
    }
    [cell updateCellWithModel:_cellModel];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellModel.cellHeight;
}

#pragma arguments AdInstlManagerDelegate
-(void)adInstlManager:(AdInstlManager*)manager
          didGetEvent:(InstlEventType)eType
                error:(NSError*)error
{
    if (InstlEventType_DidLoadAd==eType)
    {
        [self.adInstlManager showAdInstlView:self];
    }
}

- (BOOL)adInstlTestMode
{
    return NO;
}

- (BOOL)adInstlLogMode
{
    return NO;
}
@end
