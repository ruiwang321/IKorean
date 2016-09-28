//
//  MovieDetailViewController.m
//  ICinema
//
//  Created by wangyunlong on 16/9/23.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "AdInstlManager.h"
#import "AdInstlManagerDelegate.h"
#import "ICEPlayerView.h"
#import "MovieDetailSwitchView.h"
#import "MovieDetailUnitView.h"
#import "MovieEpisodeUnitView.h"
#import "MovieCorrelationUnitView.h"
@interface MovieDetailViewController ()
<
AdInstlManagerDelegate,
UIScrollViewDelegate
>
@property (nonatomic,assign) NSInteger movieID;
@property (nonatomic,assign) BOOL isLockScreen;
@property (nonatomic,assign) AFHTTPSessionManager * getContentDataManager;
@property (nonatomic,strong) AdInstlManager * adInstlManager;
@property (nonatomic,strong) ICEPlayerView  * playerView;
@property (nonatomic,strong) ICELoadingView * loadingView;
@property (nonatomic,strong) ICEErrorStateAlertView * errorStateAlertView;
@property (nonatomic,strong) UIView * bottomBackGroundView;
@property (nonatomic,strong) MovieDetailSwitchView * switchView;
@property (nonatomic,strong) BannerAdUnitView * bannerAdUnitView;
@property (nonatomic,strong) ICESlideBackGestureConflictScrollView * scrollView;
@property (nonatomic,strong) MovieDetailUnitView  * movieDetailUnitView;
@property (nonatomic,strong) MovieEpisodeUnitView * movieEpisodeUnitView;
@property (nonatomic,strong) MovieCorrelationUnitView * movieCorrelationUnitView;
@property (nonatomic,copy)   NSCharacterSet * nonDecimalCharacterSet;
@property (nonatomic,copy)   NSCharacterSet * numberCharacterSet;
@end

@implementation MovieDetailViewController

-(void)dealloc
{
    self.adInstlManager.delegate=nil;
    self.adInstlManager=nil;
    self.bannerAdUnitView=nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(id)initWithMovieID:(NSInteger)movieID
{
    if (self=[super init])
    {
        _movieID=movieID;
        _isLockScreen=NO;
        self.adInstlManager=[AdInstlManager managerWithAdInstlKey:ADViewKey
                                                     WithDelegate:self];
        self.getContentDataManager=[AFHTTPSessionManager shareInstance];
        self.nonDecimalCharacterSet =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        self.numberCharacterSet = [NSCharacterSet  characterSetWithCharactersInString:@"0123456789"];
        //进入后台
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)addChildView
{
    if (self.playerView==nil)
    {
        //状态栏背景页
        UIView * statusBarBackView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, 20)];
        [statusBarBackView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:statusBarBackView];
        
        CGFloat playerViewOrigVWidth=375;
        CGFloat playerViewOrigVHeight=210;
        CGFloat playerViewVHeight=playerViewOrigVHeight/playerViewOrigVWidth*self.screenWidth;
        CGRect  playerViewVFrame=CGRectMake(0, 20, self.screenWidth, playerViewVHeight);
        CGRect  playerViewHFrame=CGRectMake(0, 0, self.screenHeight, self.screenWidth);
        __weak typeof(self) wself=self;
        self.playerView=[[ICEPlayerView alloc] initWithPlayerViewVFrame:playerViewVFrame HFrame:playerViewHFrame];
        
        [_playerView setWillRemoveCurrentPlayEpisodeModelsBlock:^(NSArray * currentPlayEpisodeModels){
            NSLog(@"卸载数据可以将播放记录保存到数据库=%@",currentPlayEpisodeModels);
        }];
        
        [_playerView setVideoIsSelectedToPlayBlock:^(ICEPlayerEpisodeModel * model){
            NSLog(@"选择某一集准备播放=%@",model.videoName);
            [wself.movieEpisodeUnitView playEpisodeWithVideoID:model.videoID];
        }];
        
        [_playerView setVideoPauseBlock:^(ICEPlayerEpisodeModel * model,ICEPlayerViewVideoPauseReasons pauseReason){
            
            if (VideoPauseBecauseOfUserSelect==pauseReason||VideoPauseBecauseOfNormalPlayLeadToBufferEmpty==pauseReason)
            {
                [wself.adInstlManager loadAdInstlView:wself];
            }
        }];
        
        [_playerView setVideoEndBlock:^(ICEPlayerEpisodeModel * model,ICEPlayerViewVideoEndReasons endReason){
            
        }];
    
        [_playerView setCollectVideoBlock:^(ICEPlayerEpisodeModel * model){
            //判断是否收藏过，播放器中的收藏按钮的显示逻辑是外部类判断的，是否收藏由外部类设置。
        }];
        
        [_playerView setLockScreenBlock:^(BOOL isLockScreen){
            wself.isLockScreen=isLockScreen;
        }];
        
        [_playerView setEnsurePlayVideoNoWIFIBlock:^{
            NSLog(@"用户确认非wifi可看");
        }];
        
        [_playerView setReturnBlock:^{
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        
        [self.view addSubview:_playerView];
        
        //loadingView
        CGFloat loadingViewMinY=CGRectGetMaxY(_playerView.frame);
        CGFloat loadingViewHeight=self.screenHeight-loadingViewMinY;
        CGRect  loadingViewFrame=CGRectMake(0, loadingViewMinY, self.screenWidth, loadingViewHeight);
        self.loadingView=[[ICELoadingView alloc] initWithFrame:loadingViewFrame];
        [self.view insertSubview:_loadingView belowSubview:_playerView];
        
        //数据加载失败提示
        self.errorStateAlertView=[[ICEErrorStateAlertView alloc] initWithFrame:loadingViewFrame
                                                                alertImageName:@"netWorkError@2x"
                                                                       message:@"数据加载失败，请点击屏幕重试"
                                                                    clickBlock:^{
                                                                        [wself sendGetContentDataRequest];
                                                                    }];
        [self.view insertSubview:_errorStateAlertView belowSubview:_playerView];
        [_errorStateAlertView setHidden:YES];
        
        //底部背景页
        self.bottomBackGroundView=[[UIView alloc] initWithFrame:loadingViewFrame];
        [self.view insertSubview:_bottomBackGroundView belowSubview:_playerView];
        [_bottomBackGroundView setHidden:YES];
        
        //切换页面
        CGRect  switchViewFrame=CGRectMake(0, 0, self.screenWidth, 36);
        self.switchView=[[MovieDetailSwitchView alloc] initWithFrame:switchViewFrame selectBlock:^(NSInteger Index) {
            [wself.scrollView setContentOffset:CGPointMake(Index*wself.screenWidth, 0) animated:YES];
        }];
        [_bottomBackGroundView addSubview:_switchView];
        
        //广告
        CGRect  bannerAdUnitViewFrame=CGRectMake(0, CGRectGetMaxY(switchViewFrame), self.screenWidth, 50);
        self.bannerAdUnitView=[[BannerAdUnitView alloc] initWithFrame:bannerAdUnitViewFrame];
        [_bottomBackGroundView addSubview:_bannerAdUnitView];
        
        //滚动
        CGFloat scrollViewMinY=CGRectGetMaxY(bannerAdUnitViewFrame);
        CGRect  scrollViewFrame=CGRectMake(0, scrollViewMinY, self.screenWidth, loadingViewHeight-scrollViewMinY);
        self.scrollView=[[ICESlideBackGestureConflictScrollView alloc] initWithFrame:scrollViewFrame];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setDelegate:self];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_bottomBackGroundView addSubview:_scrollView];
    }
}

- (MovieDetailUnitViewModel *)movieDetailUnitViewModelWithResponseData:(NSDictionary *)data
{
    ICEAppHelper * appHelper=[ICEAppHelper shareInstance];
    NSString * videoName=data[@"title"];
    NSString * videoGrade=[NSString stringWithFormat:@"%@",data[@"grade"]];
    NSString * videoShowTime=data[@"showtime"];
    NSString * videoDirector=data[@"director"];
    NSString * videoActor=data[@"actor"];
    NSString * videoArea=data[@"area"];
    NSString * videoIntro=data[@"intro"];
    videoIntro=[videoIntro stringByReplacingOccurrencesOfString:@" " withString:@""];
    videoIntro=[videoIntro stringByReplacingOccurrencesOfString:@"　" withString:@""];
    videoIntro=[videoIntro stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    videoIntro=[videoIntro stringByReplacingOccurrencesOfString:@"\t" withString:@"\n"];
    NSArray * array=[videoIntro componentsSeparatedByString:@"\n"];
    NSMutableString * videoInfo=[NSMutableString stringWithString:@""];
    for (NSString * string in array)
    {
        if ([string length])
        {
            if ([videoInfo length]) {
                [videoInfo appendString:@"\n"];
            }
            [videoInfo appendString:string];
        }
    }
    MovieDetailUnitViewModel * movieDetailUnitViewModel=[[MovieDetailUnitViewModel alloc] init];
    [movieDetailUnitViewModel setVideoName:[appHelper isStringIsEmpty:videoName]?@"未知":videoName];
    [movieDetailUnitViewModel setVideoGrade:[appHelper isStringIsEmpty:videoGrade]?@"未知":videoGrade];
    [movieDetailUnitViewModel setVideoShowTime:[appHelper isStringIsEmpty:videoShowTime]?@"未知":videoShowTime];
    [movieDetailUnitViewModel setVideoDirector:[appHelper isStringIsEmpty:videoDirector]?@"未知":videoDirector];
    [movieDetailUnitViewModel setVideoActor:[appHelper isStringIsEmpty:videoActor]?@"未知":videoActor];
    [movieDetailUnitViewModel setVideoArea:[appHelper isStringIsEmpty:videoArea]?@"未知":videoArea];
    [movieDetailUnitViewModel setVideoIntroduction:[appHelper isStringIsEmpty:videoInfo]?@"未知":videoInfo];
    return movieDetailUnitViewModel;
}

- (NSArray *)getPlayerEpisodeModelsWithVideos:(NSArray *)videoArray
{
    NSMutableArray * episodeModelArray=[NSMutableArray array];
    return episodeModelArray;
}

- (void)addOrUpdateBottomViewWithData:(id)responseData
{
    if (responseData&&100==[responseData[@"status"]integerValue])
    {
        NSDictionary * data=responseData[@"data"];
        MovieDetailUnitViewModel * movieDetailUnitViewModel=[self movieDetailUnitViewModelWithResponseData:data];
        if (_movieDetailUnitView==nil)
        {
            self.movieDetailUnitView=[[MovieDetailUnitView alloc] initWithFrame:_scrollView.bounds];
            [_scrollView addSubview:_movieDetailUnitView];
        }
        [_movieDetailUnitView updateMovieDetailUnitViewWithModel:movieDetailUnitViewModel];
        
        if (_movieEpisodeUnitView) {
            [_movieEpisodeUnitView removeFromSuperview];
            self.movieEpisodeUnitView=nil;
        }
        
        if (_movieCorrelationUnitView) {
            [_movieCorrelationUnitView removeFromSuperview];
            self.movieCorrelationUnitView=nil;
        }
        
        CGFloat   lastUnitViewMaxX=CGRectGetMaxX(_movieDetailUnitView.frame);
        NSInteger category=[data[@"category"] integerValue];
        NSArray  * videos=data[@"videos"];
        NSArray  * recommends=data[@"recommend"];
        NSString * movieTitle=data[@"title"];
        
        MovieEpisodeUnitViewLookMoreViewStyle lookMoreViewStyle=LookMoreViewTableViewStyle;
        BOOL isNeedAddMovieEpisodeUnitView=YES;
        BOOL isNeedAddMovieCorrelationUnitView=NO;
        NSMutableArray * titles=[NSMutableArray arrayWithObjects:@"详情",nil];
        NSMutableArray * episodeModelArray=[NSMutableArray array];
        if (2==category||4==category)
        {
            BOOL isFindTitleNonNumber=NO;
            NSRange foundRange;
            for (NSDictionary * dic in videos)
            {
                if (foundRange=[dic[@"title"] rangeOfCharacterFromSet:_numberCharacterSet],NSNotFound==foundRange.location)
                {
                    isFindTitleNonNumber=YES;
                    break;
                }
            }
            if (!isFindTitleNonNumber)
            {
                NSMutableArray * videoArray=[NSMutableArray array];
                for (NSDictionary * dic in videos)
                {
                    NSMutableDictionary * videoDic=[NSMutableDictionary dictionaryWithDictionary:dic];
                    NSString * title=dic[@"title"];
                    NSString * newTitle=[NSString stringWithFormat:@"%d",[[title stringByTrimmingCharactersInSet:_nonDecimalCharacterSet] intValue]];
                    [videoDic setValue:newTitle forKey:@"title"];
                    [videoArray addObject:videoDic];
                }
                videos=videoArray;
                lookMoreViewStyle=LookMoreViewCollectionViewStyle;
            }
        }
        else if(5==category)
        {
            isNeedAddMovieEpisodeUnitView=NO;
            isNeedAddMovieCorrelationUnitView=YES;
        }
        __weak typeof(self) wself=self;
        if (isNeedAddMovieEpisodeUnitView&&[videos count])
        {
            [titles addObject:@"剧集"];
            CGRect movieEpisodeUnitViewFrame=[_movieDetailUnitView frame];
            movieEpisodeUnitViewFrame.origin.x=lastUnitViewMaxX;
            self.movieEpisodeUnitView=[[MovieEpisodeUnitView alloc] initWithFrame:movieEpisodeUnitViewFrame
                                                                            style:lookMoreViewStyle
                                                                           videos:videos
                                                                       recommends:recommends
                                                               selectEpisodeBlock:^(NSString * videoID) {
                                                                   [[wself playerView]playVideoWithVideoID:videoID];
                                                               }
                                                             selectMovieItemBlock:^(MovieItemModel *movieItemModel) {
                                                                 [wself setMovieID:[movieItemModel movieID]];
                                                                 [wself sendGetContentDataRequest];
                                                               }];
            
            [_scrollView addSubview:_movieEpisodeUnitView];
            lastUnitViewMaxX=CGRectGetMaxX(movieEpisodeUnitViewFrame);
        }
        
        if (isNeedAddMovieCorrelationUnitView&&[recommends count])
        {
            [titles addObject:@"相关"];
            CGRect movieCorrelationUnitViewFrame=[_movieDetailUnitView frame];
            movieCorrelationUnitViewFrame.origin.x=lastUnitViewMaxX;
            self.movieCorrelationUnitView=[[MovieCorrelationUnitView alloc] initWithFrame:movieCorrelationUnitViewFrame
                                                                               recommends:recommends
                                                                              selectBlock:^(MovieItemModel *movieItemModel) {
                                                                                  [wself setMovieID:[movieItemModel movieID]];
                                                                                  [wself sendGetContentDataRequest];
                                                                              }];
            [_scrollView addSubview:_movieCorrelationUnitView];
            lastUnitViewMaxX=CGRectGetMaxX(movieCorrelationUnitViewFrame);
        }
        
        for (NSDictionary * dic in videos)
        {
            ICEPlayerEpisodeModel * model=[[ICEPlayerEpisodeModel alloc] init];
            [model setVideoID:[NSString stringWithFormat:@"%@",dic[@"id"]]];
            [model setLastPlaySeconds:0];
            NSString * videoTitle=dic[@"title"];
            if (LookMoreViewCollectionViewStyle==lookMoreViewStyle)
            {
                [model setEpisodeNumber:videoTitle];
                [model setVideoName:[NSString stringWithFormat:@"%@ 第%@集",movieTitle,videoTitle]];
            }
            else
            {
                [model setVideoName:[NSString stringWithFormat:@"%@ %@",movieTitle,videoTitle]];
            }
            [episodeModelArray addObject:model];
        }
        [_switchView setTitles:titles];
        [_switchView setIndex:0 animated:NO];
        [_scrollView setContentOffset:CGPointZero];
        [_scrollView setContentSize:CGSizeMake(lastUnitViewMaxX, CGRectGetHeight(_scrollView.frame))];
        if ([episodeModelArray count])
        {
            [_playerView loadPlayerWithEpisodeModels:episodeModelArray
                              isNeedRemindUserNoWIFI:YES
                             selectEpisodesViewStyle:(ICEPlayerViewSelectEpisodesViewStyle)lookMoreViewStyle];
        }
    }
    else
    {
        [_errorStateAlertView setHidden:NO];
    }
}

- (void)switchScrollView
{
    NSInteger Index=_scrollView.contentOffset.x/CGRectGetWidth(_scrollView.frame);
    [_switchView setIndex:Index animated:YES];
}

- (void)sendGetContentDataRequest
{
    [_loadingView startLoading];
    [_errorStateAlertView setHidden:YES];
    [_bottomBackGroundView setHidden:YES];
    __weak typeof(self) wself=self;
    [_getContentDataManager GET:urlOfMovieContent
                     parameters:@{@"id":@(_movieID)}
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            [wself.loadingView stopLoading];
                            [wself addOrUpdateBottomViewWithData:responseObject];
                            [wself.bottomBackGroundView setHidden:NO];
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            [wself.loadingView stopLoading];
                            [wself.errorStateAlertView setHidden:NO];
                        }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.myNavigationBar setHidden:YES];
    [self addChildView];
    [self sendGetContentDataRequest];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_playerView setIsNeedRemindUserNoWIFI:YES];
    [_playerView playerViewAppear];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.navigationController.viewControllers==nil||NSNotFound==[self.navigationController.viewControllers indexOfObject:self])
    {
        [_playerView playerViewDisappearWithIsDestroy:YES];
        [_loadingView destroyLoading];
    }
    else
    {
        [_playerView playerViewDisappearWithIsDestroy:NO];
    }
}

- (void)appEnterBackground
{
    [_playerView playerViewDisappearWithIsDestroy:NO];
}

- (void)appEnterForeground
{
    [_playerView setIsNeedRemindUserNoWIFI:YES];
    [_playerView playerViewAppear];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (BOOL)shouldAutorotate
{
    return !_isLockScreen;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self switchScrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self switchScrollView];
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
