//
//  ICEPlayerView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerView.h"
#import "Reachability.h"
#import "ICEPlayerTopView.h"
#import "ICEPlayerVolumeView.h"
#import "ICEPlayerBrightnessView.h"
#import "ICEPlayerProgressView.h"
#import "ICEPlayerBottomView.h"
#import "ICEPlayerReadToPlayView.h"
#import "ICEPlayerErrorStateView.h"
#import "ICEPlayerSelectEpisodesView.h"
#import "ICELoadingView.h"

//顶部工具栏竖直和水平时的高度
#define PlayerTopViewVHeight                    38
#define PlayerTopViewHHeight                    60

//底部工具栏竖直和水平时的高度
#define PlayerBottomViewVHeight                 42
#define PlayerBottomViewHHeight                 64

//顶部和底部工具栏每次显示后延迟消失的秒数
#define TopAndBottomDelaySecondsToHide          5

//音量和亮度视图最大的高度
#define VolumeAndBrightnessViewMaxHeight        125

//滑动屏幕调节进度，从屏幕左边到右边最多快进MaxChangeSecondsOneTime秒
#define MaxChangeSecondsOneTime                 300

//检查视频缓冲的重复周期
#define WaitBufferRepateTimeInterval            0.1

//视频因缓冲不够暂停时，最多等待MaxWaitBufferSeconds秒
#define MaxWaitBufferSeconds                    30


#define HiddenKeyPath                           @"hidden"
////////////////////////////////PanGestureModel///////////////////////////
typedef NS_ENUM(NSInteger, PanScreenPurposeOptions) {
    PanScreenForNothing,
    PanScreenForAdjustProgress,
    PanScreenForAdjustVolume,
    PanScreenForAdjustBrightness
};

@interface PanGestureModel : NSObject
@property (nonatomic,assign) CGFloat panOffsetValue;
@property (nonatomic,assign) PanScreenPurposeOptions panScreenPurpose;
@end

@implementation PanGestureModel
@end

///////////////////////ICEPlayerURLErrorTimesStatisticsHelper///////////////
@interface ICEPlayerURLErrorTimesStatisticsHelper : NSObject

@property (nonatomic,copy)   NSString * videoURL;
@property (nonatomic,assign) NSInteger maxErrorTimes;
@property (nonatomic,assign) NSInteger currentErrorTimes;

-(id)initWithMaxErrorTimes:(NSInteger)maxErrorTimes;

-(void)setErrorURLString:(NSString *)errorURLString;

-(BOOL)isMaxErrorTimesWithURLString:(NSString *)urlString;

@end

@implementation ICEPlayerURLErrorTimesStatisticsHelper

-(id)initWithMaxErrorTimes:(NSInteger)maxErrorTimes
{
    if (self=[super init])
    {
        _maxErrorTimes=maxErrorTimes;
        _currentErrorTimes=0;
    }
    return self;
}

-(void)setErrorURLString:(NSString *)errorURLString
{
    if (errorURLString)
    {
        if ([_videoURL isEqualToString:errorURLString])
        {
            _currentErrorTimes++;
        }
        else
        {
            self.videoURL=errorURLString;
            _currentErrorTimes=0;
        }
    }
}

-(BOOL)isMaxErrorTimesWithURLString:(NSString *)urlString
{
    if (urlString&&[_videoURL isEqualToString:urlString])
    {
        return _currentErrorTimes>=_maxErrorTimes;
    }
    return NO;
}

@end
////////////////////////////ICEPlayerEpisodeModelHelper///////////////
@interface ICEPlayerEpisodeModelLogicHelper:NSObject

-(NSArray *)deepCopyArrayWithOrigArray:(NSArray *)origArray;

-(NSInteger)indexWithPlayModel:(ICEPlayerEpisodeModel *)playModel models:(NSArray *)episodeModelsArray;

-(ICEPlayerEpisodeModel *)playModelForFirstHavePlaybackRecordingWithModels:(NSArray *)episodeModelsArray;

-(BOOL)isFirstModel:(ICEPlayerEpisodeModel *)firstModel equalToSecondModel:(ICEPlayerEpisodeModel *)secondModel;

-(ICEPlayerEpisodeModel *)findPlayModelWithVideoID:(NSString *)videoID FromModels:(NSArray *)episodeModelsArray;

@end

@implementation ICEPlayerEpisodeModelLogicHelper

-(NSArray *)deepCopyArrayWithOrigArray:(NSArray *)origArray
{
    NSMutableArray * deepCopyArray=[NSMutableArray arrayWithCapacity:[origArray count]];
    for (ICEPlayerEpisodeModel * model in origArray)
    {
        [deepCopyArray addObject:[model copy]];
    }
    return deepCopyArray;
}

-(NSInteger)indexWithPlayModel:(ICEPlayerEpisodeModel *)playModel models:(NSArray *)episodeModelsArray
{
    NSInteger playModelIndex=NSNotFound;
    if (playModel&&episodeModelsArray)
    {
        NSInteger  episodeCount=[episodeModelsArray count];
        NSString * playModelVideoID=playModel.videoID;
        for (NSInteger Index=0; Index<episodeCount; Index++)
        {
            ICEPlayerEpisodeModel * model=episodeModelsArray[Index];
            if ([model.videoID isEqualToString:playModelVideoID])
            {
                playModelIndex=Index;
                break;
            }
        }
    }
    return playModelIndex;
}

-(ICEPlayerEpisodeModel *)playModelForFirstHavePlaybackRecordingWithModels:(NSArray *)episodeModelsArray
{
    ICEPlayerEpisodeModel * playModel=[episodeModelsArray firstObject];
    for (ICEPlayerEpisodeModel * model in episodeModelsArray)
    {
        if (model.lastPlaySeconds)
        {
            playModel=model;
            break;
        }
    }
    return playModel;
}

-(BOOL)isFirstModel:(ICEPlayerEpisodeModel *)firstModel equalToSecondModel:(ICEPlayerEpisodeModel *)secondModel
{
    if (firstModel&&
        secondModel&&
        [firstModel videoID]&&
        [[secondModel videoID] isEqualToString:[firstModel videoID]])
    {
        return YES;
    }
    return NO;
}

-(ICEPlayerEpisodeModel *)findPlayModelWithVideoID:(NSString *)videoID FromModels:(NSArray *)episodeModelsArray
{
    ICEPlayerEpisodeModel * playModel=nil;
    for (ICEPlayerEpisodeModel * model in episodeModelsArray)
    {
        if ([[model videoID]isEqualToString:videoID])
        {
            playModel=model;
            break;
        }
    }
    return playModel;
}
@end
////////////////////////////ICEPlayerView/////////////////////////////
@interface ICEPlayerView ()
<
UIGestureRecognizerDelegate
>

@property (nonatomic,assign) BOOL isFirstLoadPlayer;
@property (nonatomic,assign) BOOL isLockScreen;
@property (nonatomic,assign) BOOL isPlayerViewAppear;
@property (nonatomic,assign) BOOL isFullScreenNow;
@property (nonatomic,assign) BOOL isCurrentVideoFirstLoad;
@property (nonatomic,assign) BOOL isNeedRemindUserNoWIFI;
@property (nonatomic,strong) NSTimer * bufferTimer;
@property (nonatomic,assign) NSTimeInterval waitBufferSeconds;
@property (nonatomic,assign) CGRect playerViewVFrame;
@property (nonatomic,assign) CGRect playerViewHFrame;
@property (nonatomic,assign) CGFloat volumeAndBrightnessViewHeight;
@property (nonatomic,assign) CGFloat maxPanDistanceForAdjustVolumeOrBrightness;
@property (nonatomic,assign) NSTimeInterval maxChangeSecondsOneTimeForPanScreenAdjustProgress;
@property (nonatomic,assign) ICEPlayerViewSelectEpisodesViewStyle  selectEpisodesViewStyle;
@property (nonatomic,strong) Reachability * reachability;
@property (nonatomic,copy)   void (^switchPlayerViewOrientationBlock)();
@property (nonatomic,strong) PanGestureModel * panGestureModel;
@property (nonatomic,strong) NSMutableArray * episodeModelsArray;
@property (nonatomic,strong) ICEPlayerEpisodeModel * currentPlayModel;
@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;
@property (nonatomic,strong) id playerTimeObserver;
@property (nonatomic,strong) ICELoadingView * loadingView;
@property (nonatomic,strong) ICEButton * returnButton;
@property (nonatomic,strong) ICEPlayerTopView * topView;
@property (nonatomic,strong) ICEPlayerVolumeView * volumeView;
@property (nonatomic,strong) ICEPlayerBrightnessView * brightnessView;
@property (nonatomic,strong) ICEPlayerProgressView * progressView;
@property (nonatomic,strong) ICEPlayerBottomView * bottomView;
@property (nonatomic,strong) ICEPlayerReadToPlayView * readToPlayView;
@property (nonatomic,strong) ICEPlayerErrorStateView * errorStateView;
@property (nonatomic,strong) ICEPlayerSelectEpisodesView * selectEpisodesView;
@property (nonatomic,assign) JsPlayer * getVideoURLHelper;
@property (nonatomic,strong) ICEPlayerURLErrorTimesStatisticsHelper * urlErrorTimesStatisticsHelper;
@property (nonatomic,strong) ICEPlayerEpisodeModelLogicHelper * playerEpisodeModelLogicHelper;
@end

@implementation ICEPlayerView

-(void)playerViewAppear
{
    if (!_isFirstLoadPlayer&&!_isPlayerViewAppear)
    {
        _isPlayerViewAppear=YES;
        [self playVideoAccordingToThePlayerStatus];
    }
}

-(void)playerViewDisappearWithIsDestroy:(BOOL)isDestroy
{
    _isPlayerViewAppear=NO;
    if (isDestroy)
    {
        [self executeWillRemoveCurrentPlayEpisodeModelsBlock];
        [self playerEndWithReason:VideoEndBecauseOfPlayerViewIsDestroyed];
        [_readToPlayView destroyLoading];
        [_topView destroyRolling];
        [self endWaitBufferWithIsDestroy:YES];
        [self destroyPlayerWithIsDestroyLayer:YES];
        [_readToPlayView removeObserver:self forKeyPath:HiddenKeyPath];
        [_errorStateView removeObserver:self forKeyPath:HiddenKeyPath];
        [self removeFromSuperview];
    }
    else
    {
        [self playerPauseWithReason:VideoPauseBecauseOfPlayerViewDisappearButNotDestroy];
    }
}

- (void)dealloc
{
    self.panGestureModel=nil;
    self.episodeModelsArray=nil;
    self.currentPlayModel=nil;
    self.reachability=nil;
    self.getVideoURLHelper=nil;
    self.urlErrorTimesStatisticsHelper=nil;
    self.playerEpisodeModelLogicHelper=nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(id)initWithPlayerViewVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame
{
    if (self=[super initWithFrame:vFrame])
    {
        [self setBackgroundColor:[UIColor blackColor]];
        [self setUserInteractionEnabled:YES];
        [self.layer setMasksToBounds:YES];
        
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        
        //设备旋转通知
        [notificationCenter addObserver:self
                               selector:@selector(deviceOrientationDidChange)
                                   name:UIApplicationDidChangeStatusBarOrientationNotification
                                 object:nil];
        //视频播放结束
        [notificationCenter addObserver:self
                               selector:@selector(playToEnd)
                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                 object:nil];
        //视频被中断
        [notificationCenter addObserver:self
                               selector:@selector(playbackStalled)
                                   name:AVPlayerItemPlaybackStalledNotification
                                 object:nil];
        //检测网络状态
        [notificationCenter addObserver:self
                               selector:@selector(doSomethingAccordingToTheNetworkState)
                                   name:kReachabilityChangedNotification
                                 object:nil];

        //滑动屏幕手势
        UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                               action:@selector(handlePan:)];
        [panGestureRecognizer setDelegate:self];
        [panGestureRecognizer setMinimumNumberOfTouches:1];
        [panGestureRecognizer setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panGestureRecognizer];
        
        //双击手势
        UITapGestureRecognizer * doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                                     action:@selector(handleDoubleTap:)];
        [doubleTapGestureRecognizer setDelegate:self];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        
        //单击手势
        UITapGestureRecognizer * singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                                     action:@selector(handleSingleTap:)];
        [singleTapGestureRecognizer setDelegate:self];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [self addGestureRecognizer:singleTapGestureRecognizer];
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        [self setExclusiveTouch:YES];
        
        _isNeedRemindUserNoWIFI=YES;
        _isFirstLoadPlayer=YES;
        _isPlayerViewAppear=YES;
        _isCurrentVideoFirstLoad=NO;
        _isLockScreen=NO;
        _isFullScreenNow=NO;
        _waitBufferSeconds=0;

        _playerViewVFrame=vFrame;
        _playerViewHFrame=hFrame;
        _maxPanDistanceForAdjustVolumeOrBrightness=CGRectGetHeight(vFrame)-PlayerTopViewVHeight-PlayerBottomViewVHeight;
        _volumeAndBrightnessViewHeight=MIN(_maxPanDistanceForAdjustVolumeOrBrightness-10, VolumeAndBrightnessViewMaxHeight);
        _maxChangeSecondsOneTimeForPanScreenAdjustProgress=MaxChangeSecondsOneTime;
        
        self.episodeModelsArray=[[NSMutableArray alloc] init];
        
        self.reachability=[Reachability reachabilityForInternetConnection];
        
        self.panGestureModel=[[PanGestureModel alloc] init];
        _panGestureModel.panOffsetValue=0;
        _panGestureModel.panScreenPurpose=PanScreenForNothing;
        
        self.urlErrorTimesStatisticsHelper=[[ICEPlayerURLErrorTimesStatisticsHelper alloc] initWithMaxErrorTimes:1];
        
        self.playerEpisodeModelLogicHelper=[[ICEPlayerEpisodeModelLogicHelper alloc] init];
        
        __weak typeof(self) wself=self;
        self.switchPlayerViewOrientationBlock=^
        {
            [wself switchPlayerViewOrientation];
        };
    
        self.getVideoURLHelper=[JsPlayer sharedInstance];
        [_getVideoURLHelper setGetVideoURLFinishBlock:^(NSString * videoURLString, NSString * link)
        {
            if (link&&[wself.currentPlayModel.videoID isEqualToString:link])
            {
                [wself.currentPlayModel setUrl:videoURLString];
                [wself loadVideoWithURLString:videoURLString];
            }
        }];
         
        [self addLoadingView];
        [self addTopView];
        [self addVolumeView];
        [self addBrightnessView];
        [self addProgressView];
        [self addBottomView];
        [self addSelectEpisodesView];
        [self addReadToPlayView];
        [self addErrorStateView];
        [self addReturnButton];
    }
    return self;
}

#pragma mark 外部类回调

- (void)executeWillRemoveCurrentPlayEpisodeModelsBlock
{
    if (_willRemoveCurrentPlayEpisodeModelsBlock&&[_episodeModelsArray count])
    {
        _willRemoveCurrentPlayEpisodeModelsBlock([_playerEpisodeModelLogicHelper deepCopyArrayWithOrigArray:_episodeModelsArray]);
    }
}

- (void)executeVideoIsSelectedToPlayBlock
{
    if (_videoIsSelectedToPlayBlock&&_currentPlayModel)
    {
        _videoIsSelectedToPlayBlock([_currentPlayModel copy]);
    }
}

- (void)executeVideoPlayBlockWithPlayReasons:(ICEPlayerViewVideoPlayReasons)playReason
{
    if (_videoPlayBlock&&_currentPlayModel)
    {
        _videoPlayBlock([_currentPlayModel copy],playReason);
    }
}

- (void)executeVideoPauseBlockWithPauseReasons:(ICEPlayerViewVideoPauseReasons)pauseReason
{
    if (_videoPauseBlock&&_currentPlayModel)
    {
        _videoPauseBlock([_currentPlayModel copy],pauseReason);
    }
}

- (void)executeVideoEndBlockWithEndReasons:(ICEPlayerViewVideoEndReasons)endReason
{
    if (_videoEndBlock&&_currentPlayModel)
    {
        _videoEndBlock([_currentPlayModel copy],endReason);
    }
}

- (void)executeVideoFailedBlockWithFailedReasons:(ICEPlayerViewVideoFailedReasons)failedReason
{
    if (_videoFailedBlock&&_currentPlayModel)
    {
        _videoFailedBlock([_currentPlayModel copy],failedReason);
    }
}

- (void)executeCollectVideoBlock
{
    if (_collectVideoBlock&&_currentPlayModel)
    {
        _collectVideoBlock([_currentPlayModel copy]);
    }
}

- (void)executeLockScreenBlock
{
    if (_lockScreenBlock)
    {
        _lockScreenBlock(_isLockScreen);
    }
}

- (void)executeEnsurePlayVideoNoWIFIBlock
{
    if (_ensurePlayVideoNoWIFIBlock)
    {
        _ensurePlayVideoNoWIFIBlock();
    }
}

- (void)executeReturnBlock
{
    if (_returnBlock)
    {
        _returnBlock();
    }
}

-(void)setIsCollectCurrentVideo:(BOOL)isCollectCurrentVideo
{
    [_topView setIsCollected:isCollectCurrentVideo];
}

-(void)setIsNeedRemindUserNoWIFI:(BOOL)isNeedRemindUserNoWIFI
{
    _isNeedRemindUserNoWIFI=isNeedRemindUserNoWIFI;
}

#pragma mark 屏幕旋转

- (void)transformPlayerViewWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    BOOL isValidOrientation=NO;
    if (UIDeviceOrientationPortrait==deviceOrientation)
    {
        if (_isFullScreenNow)
        {
            isValidOrientation=YES;
            _isFullScreenNow=NO;
            [self setFrame:_playerViewVFrame];
            [_playerLayer setFrame:self.bounds];
            [_selectEpisodesView setHidden:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        }
    }
    else if(UIDeviceOrientationLandscapeLeft==deviceOrientation||
            UIDeviceOrientationLandscapeRight==deviceOrientation)
    {
        if (!_isFullScreenNow)
        {
            isValidOrientation=YES;
            _isFullScreenNow=YES;
            [self setFrame:_playerViewHFrame];
            [_playerLayer setFrame:self.bounds];
            if ([_readToPlayView isHidden]&&[_errorStateView isHidden]&&[_topView isWillHide])
            {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            }
            else
            {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            }
        }
    }
    if (isValidOrientation)
    {
        [_topView setIsFullScreenDisplay:_isFullScreenNow];
        [_bottomView setIsFullScreenDisplay:_isFullScreenNow];
        [_readToPlayView setIsFullScreenDisplay:_isFullScreenNow];
        [_errorStateView setIsFullScreenDisplay:_isFullScreenNow];
        [_returnButton setHidden:_isFullScreenNow];
    }
}

- (void)deviceOrientationDidChange
{
    [self transformPlayerViewWithDeviceOrientation:[[UIDevice currentDevice]orientation]];
}

- (void)setIsLockScreen:(BOOL)isLockScreen
{
    _isLockScreen=isLockScreen;
    [_topView setIsLockScreen:_isLockScreen];
    [self executeLockScreenBlock];
}

- (void)switchPlayerViewOrientation
{
    self.isLockScreen=NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = _isFullScreenNow?UIDeviceOrientationPortrait:UIDeviceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark 播放器各个部分
-(void)addLoadingView
{
    self.loadingView=[[ICELoadingView alloc]init];
    [_loadingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_loadingView];
    NSDictionary * views=NSDictionaryOfVariableBindings(_loadingView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_loadingView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_loadingView]|" options:0 metrics:nil views:views]];
}

-(void)addReturnButton
{
    UIImage * returnImage=IMAGENAME(@"playerReturn@2x", @"png");
    CGFloat returnImageWidth=returnImage.size.width;
    CGFloat returnImageHeight=returnImage.size.height;
    CGRect  returnButtonFrame=CGRectMake(6, (PlayerTopViewVHeight-returnImageHeight)/2, returnImageWidth, returnImageHeight);
    self.returnButton=[ICEButton buttonWithType:UIButtonTypeCustom];
    [_returnButton setImage:returnImage forState:UIControlStateNormal];
    [_returnButton setFrame:returnButtonFrame];
    [_returnButton addTarget:self action:@selector(executeReturnBlock) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_returnButton];
}

-(void)addProgressView
{
    self.progressView=[[ICEPlayerProgressView alloc]initWithProgressViewWidth:150];
    [_progressView addToSuperViewAndaddConstraintsWithSuperView:self];
    [_progressView setHidden:YES];
}

-(void)addVolumeView
{
    self.volumeView=[[ICEPlayerVolumeView alloc] initWithVolumeViewWidth:24
                                                        volumeViewHeight:_volumeAndBrightnessViewHeight];
    [_volumeView addToSuperViewAndaddConstraintsWithSuperView:self];
    [_volumeView setHidden:YES];
}

-(void)addBrightnessView
{
    self.brightnessView=[[ICEPlayerBrightnessView alloc]initWithBrightnessViewWidth:24
                                                               brightnessViewHeight:_volumeAndBrightnessViewHeight];
    [_brightnessView addToSuperViewAndaddConstraintsWithSuperView:self];
    [_brightnessView setHidden:YES];
}

-(void)addTopView
{
    __weak typeof(self) wself=self;
    CGRect topVFrame=CGRectMake(0, 0, CGRectGetWidth(_playerViewVFrame), PlayerTopViewVHeight);
    CGRect topHFrame=CGRectMake(0, 0, CGRectGetWidth(_playerViewHFrame), PlayerTopViewHHeight);
    self.topView=[[ICEPlayerTopView alloc]initWithVFrame:topVFrame HFrame:topHFrame];
    [_topView setSwitchPlayerViewOrientationBlock:_switchPlayerViewOrientationBlock];
    [_topView setControlEventBlock:^(ICEPlayerTopViewControlEvents event)
    {
        if (ICEPlayerTopViewLockScreenEvent==event)
        {
            wself.isLockScreen=!wself.isLockScreen;
        }
        else if(ICEPlayerTopViewCollectEvent==event)
        {
            [wself executeCollectVideoBlock];
        }
        else if(ICEPlayerTopViewSelectEpisodeEvent==event)
        {
            [wself.selectEpisodesView setHidden:NO];
            [wself hideTopAndBottomView];
        }
    }];
    [self addSubview:_topView];
    [_topView setHidden:YES animated:NO];
}

-(void)addBottomView
{
    __weak typeof(self) wself=self;
    CGRect bottomVFrame=CGRectMake(0, CGRectGetHeight(_playerViewVFrame)-PlayerBottomViewVHeight, CGRectGetWidth(_playerViewVFrame), PlayerBottomViewVHeight);
    CGRect bottomHFrame=CGRectMake(0, CGRectGetHeight(_playerViewHFrame)-PlayerBottomViewHHeight, CGRectGetWidth(_playerViewHFrame), PlayerBottomViewHHeight);
    self.bottomView=[[ICEPlayerBottomView alloc] initWithVFrame:bottomVFrame HFrame:bottomHFrame];
    [_bottomView setSwitchPlayerViewOrientationBlock:_switchPlayerViewOrientationBlock];
    [_bottomView setSliderEventBlock:^(NSTimeInterval desiredSeconds,ICEPlayerBottomViewSliderEvents sliderEvent)
    {
        ICEPlayerProgressViewActionOptions actionOptions=(ICEPlayerProgressViewActionOptions)sliderEvent;
        if (ICEPlayerBottomViewSliderAdjustProgressBegan==sliderEvent)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:wself selector:@selector(hideTopAndBottomView) object:nil];
        }
        else if(ICEPlayerBottomViewSliderAdjustProgressEnd==sliderEvent)
        {
            [wself performSelector:@selector(hideTopAndBottomView) withObject:nil afterDelay:TopAndBottomDelaySecondsToHide];
            [wself seekToDesiredSeconds:desiredSeconds];
        }
        [wself.progressView updateProgressWithDesiredSeconds:desiredSeconds actionOptions:actionOptions];
    }];
    [_bottomView setControlEventBlock:^(ICEPlayerBottomViewControlEvents controlEvent)
    {
         if (ICEPlayerBottomViewControlPlayOrPause==controlEvent)
         {
             [wself switchPlayStateByUser];
         }
         else if(ICEPlayerBottomViewControlLookNextEpisode==controlEvent)
         {
             [wself playNextEpisode];
         }
    }];
    [self addSubview:_bottomView];
    [_bottomView setHidden:YES animated:NO];
}

-(void)addSelectEpisodesView
{
    __weak typeof(self) wself=self;
    CGFloat playerViewOrigHWidth=750;
    CGFloat selectEpisodesViewOrigWidth=319;
    CGFloat playerViewHWidth=CGRectGetWidth(_playerViewHFrame);
    CGFloat selectEpisodesViewWidth=selectEpisodesViewOrigWidth/playerViewOrigHWidth*playerViewHWidth;
    CGFloat selectEpisodesViewMinX=playerViewHWidth-selectEpisodesViewWidth;
    CGRect  selectEpisodesViewFrame=CGRectMake(selectEpisodesViewMinX, 0, selectEpisodesViewWidth, CGRectGetHeight(_playerViewHFrame));
    self.selectEpisodesView=[[ICEPlayerSelectEpisodesView alloc] initWithFrame:selectEpisodesViewFrame
                                                                      showMinX:selectEpisodesViewMinX
                                                                      hideMinX:playerViewHWidth];
    [_selectEpisodesView setSelectBlock:^(ICEPlayerEpisodeModel * model){
        [wself playWithEpisodeModel:model];
        [wself.selectEpisodesView setHidden:YES];
    }];
    [self addSubview:_selectEpisodesView];
    [_selectEpisodesView setHidden:YES];
}

-(void)addReadToPlayView
{
    CGRect readToPlayViewVFrame=_playerViewVFrame;
    readToPlayViewVFrame.origin=CGPointZero;
    CGRect readToPlayViewHFrame=_playerViewHFrame;
    readToPlayViewHFrame.origin=CGPointZero;
    self.readToPlayView=[[ICEPlayerReadToPlayView alloc] initWithVFrame:readToPlayViewVFrame
                                                                 HFrame:readToPlayViewHFrame];
    
    [_readToPlayView setSwitchPlayerViewOrientationBlock:_switchPlayerViewOrientationBlock];
    
    [self addSubview:_readToPlayView];
    [_readToPlayView setHidden:YES];
    [_readToPlayView addObserver:self forKeyPath:HiddenKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

-(void)addErrorStateView
{
    __weak typeof(self) wself=self;
    self.errorStateView=[[ICEPlayerErrorStateView alloc] init];
    [_errorStateView addToSuperViewAndaddConstraintsWithSuperView:self];
    [_errorStateView setHidden:YES];
    [_errorStateView setSwitchPlayerViewOrientationBlock:_switchPlayerViewOrientationBlock];
    [_errorStateView setNoWIFIPlayVideoBlock:^{
        [wself setIsNeedRemindUserNoWIFI:NO];
        [wself playVideoAccordingToThePlayerStatus];
        [wself executeEnsurePlayVideoNoWIFIBlock];
    }];
    [_errorStateView setRetryBlock:^{
        [wself retryLoadVideoAccordingToVideoLoadStage];
    }];
    [_errorStateView addObserver:self forKeyPath:HiddenKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

-(void)showTopAndBottomView
{
    [_topView setHidden:NO animated:YES];
    [_bottomView setHidden:NO animated:YES];
    if (_isFullScreenNow)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopAndBottomView) object:nil];
    [self performSelector:@selector(hideTopAndBottomView) withObject:nil afterDelay:TopAndBottomDelaySecondsToHide];
}

-(void)hideTopAndBottomView
{
    [_topView setHidden:YES animated:YES];
    [_bottomView setHidden:YES animated:YES];
    if (_isFullScreenNow)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

-(BOOL)isAdjustProgressNow
{
    BOOL isAdjust=YES;
    if (PanScreenForNothing==[_panGestureModel panScreenPurpose]&&
        (![_bottomView isAdjustProgress]))
    {
        isAdjust=NO;
    }
    return isAdjust;
}

#pragma mark 播放部分逻辑
- (void)playToEnd
{
    [self playerEndWithReason:VideoEndBecauseOfNormalPlayToEnd];
    [self playNextEpisode];
}

- (void)playbackStalled
{
    if (![_player isCanPlayNow])
    {
        [self beganWaitBufferWithIsNormalPlay:YES];
    }
}

-(void)playerPlayWithReason:(ICEPlayerViewVideoPlayReasons) playReason
{
    if (_isPlayerViewAppear)
    {
        if (![_player isPlayNow])
        {
            [self executeVideoPlayBlockWithPlayReasons:playReason];
        }
        
        [_player play];
        [_currentPlayModel setIsPlay:YES];
        [_loadingView stopLoading];
        NSTimeInterval currentSeconds=[_player currentItemCurrentSeconds];
        if (currentSeconds!=INVALIDSECONDS&&![self isAdjustProgressNow])
        {
            [_bottomView setProgressSeconds:currentSeconds]; 
        }
    }
    else
    {
        [self playerPauseWithReason:VideoPauseBecauseOfUnKnown];
    }
}

-(void)playerPauseWithReason:(ICEPlayerViewVideoPauseReasons)pauseReason
{
    if (VideoPauseBecauseOfAdjustProgressLeadToBufferEmpty==pauseReason)
    {
        if (![_player isCanPlayNow])
        {
            if ([_player isPlayNow])
            {
                [self executeVideoPauseBlockWithPauseReasons:pauseReason];
            }
            [_player pause];
        }
    }
    else
    {
        if (VideoPauseBecauseOfUnKnown!=pauseReason&&[_player isPlayNow])
        {
           [self executeVideoPauseBlockWithPauseReasons:pauseReason];
        }
        [_player pause];
    }
}

-(void)playerEndWithReason:(ICEPlayerViewVideoEndReasons)endReasons
{
    if ([_currentPlayModel isPlay])
    {
        if (VideoEndBecauseOfNormalPlayToEnd==endReasons)
        {
            [_bottomView setProgressSeconds:[_player currentItemTotalSeconds]];
        }
        [_currentPlayModel setIsPlay:NO];
        [self executeVideoEndBlockWithEndReasons:endReasons];
    }
}

-(void)playerFailedWithErrorStateType:(ICEPlayerErrorStateType)errorStateType
{
    [_errorStateView showErrorStateViewWithType:errorStateType];
    if (ICEPlayerNoNetWork==errorStateType||
        ICEPlayerNoWIFI==errorStateType)
    {
        [self playerPauseWithReason:VideoPauseBecauseOfNetworkChanges];
    }
    else
    {
        [self playerPauseWithReason:VideoPauseBecauseOfUnKnown];
        ICEPlayerViewVideoFailedReasons failedReason=VideoFailedBecauseOfVideoURLInValid;
        if (ICEPlayerVideoLoadFailed==errorStateType)
        {
            [_urlErrorTimesStatisticsHelper setErrorURLString:_currentPlayModel.url];
            failedReason=VideoFailedBecauseOfVideoLoadFailed;
        }
        else if(ICEPlayerNetWorkBusy==errorStateType)
        {
            failedReason=VideoFailedBecauseOfNetWorkBusy;
        }
        [self executeVideoFailedBlockWithFailedReasons:failedReason];
    }
}

-(void)destroyPlayerWithIsDestroyLayer:(BOOL)isDestroyLayer
{
    if (_player)
    {
        [self playerPauseWithReason:VideoPauseBecauseOfUnKnown];
        [_player setCurrentItemWithPlayerItem:nil observer:self];
        [_player removeObserver:self forKeyPath:PlayerRateKeyPath];
        [_player removeTimeObserver:_playerTimeObserver];
        self.playerTimeObserver=nil;
        self.player=nil;
    }
    if (isDestroyLayer&&_playerLayer)
    {
        [_playerLayer setPlayer:nil];
        [_playerLayer removeFromSuperlayer];
        self.playerLayer=nil;
    }
}

-(void)createPlayerWithURLString:(NSString *)urlString
{
    if (_player==nil)
    {
        __weak typeof(self) wself=self;
        self.player=[[AVPlayer alloc]init];
        [_player setCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlString?urlString:@""]] observer:self];
        [_player addObserver:self forKeyPath:PlayerRateKeyPath options:NSKeyValueObservingOptionNew context:nil];
        self.playerTimeObserver=[_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
            NSTimeInterval currentSeconds=CMTimeGetSeconds(time);
            if (currentSeconds>0
                &&[wself.currentPlayModel isPlay]
                &&[wself.player isPlayNow])
            {
                [wself.currentPlayModel setLastPlaySeconds:currentSeconds];
                if (![wself isAdjustProgressNow]&&abs((int)(currentSeconds-[wself.bottomView getProgressSeconds]))<=2)
                {
                    [wself.bottomView setProgressSeconds:currentSeconds];
                }
            }
        }];
    }
    if (_playerLayer==nil)
    {
        self.playerLayer=[[AVPlayerLayer alloc] init];
        [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        [_playerLayer setFrame:self.bounds];
        [self.layer insertSublayer:_playerLayer atIndex:0];
    }
    [_playerLayer setPlayer:_player];
}

-(void)loadVideoWithURLString:(NSString *)urlString
{
    [self destroyPlayerWithIsDestroyLayer:NO];
    [self createPlayerWithURLString:urlString];
    [_readToPlayView startLoadingWithTitle:_currentPlayModel.videoName];
}

-(void)getVideoURLWithNewModel:(ICEPlayerEpisodeModel *)model
{

    [self playerEndWithReason:VideoEndBecauseOfVideoSwitch];
    [self playerPauseWithReason:VideoPauseBecauseOfUnKnown];
    [self endWaitBufferWithIsDestroy:NO];
    [self setCurrentPlayModel:model];
    if (_currentPlayModel)
    {
        [self executeVideoIsSelectedToPlayBlock];
        [_currentPlayModel setIsPlay:YES];
        [_readToPlayView startLoadingWithTitle:_currentPlayModel.videoName];
        [_getVideoURLHelper setUrl:model.videoID];
        [_getVideoURLHelper setVid:model.spareID];
        [_getVideoURLHelper getVideoUrl];
    }
}

-(void)loadPlayerWithEpisodeModels:(NSArray *)episodeModels
            isNeedRemindUserNoWIFI:(BOOL)isNeedRemindUserNoWIFI
           selectEpisodesViewStyle:(ICEPlayerViewSelectEpisodesViewStyle)selectEpisodesViewStyle
{
    if (_isFirstLoadPlayer)
    {
        _isFirstLoadPlayer=NO;
        [_reachability startNotifier];
    }
    _isNeedRemindUserNoWIFI=isNeedRemindUserNoWIFI;
    _selectEpisodesViewStyle=selectEpisodesViewStyle;
    NSInteger episodeCount=0;
    if (episodeModels&&(episodeCount=[episodeModels count],episodeCount))
    {
        [self executeWillRemoveCurrentPlayEpisodeModelsBlock];
        [_episodeModelsArray setArray:[_playerEpisodeModelLogicHelper deepCopyArrayWithOrigArray:episodeModels]];
        [_topView setIsCanSelectEpisode:episodeCount>1?YES:NO];
        [_selectEpisodesView updateSelectEpisodesViewWithModels:_episodeModelsArray
                                                          style:(ICEPlayerSelectEpisodesViewStyle)_selectEpisodesViewStyle];
        [self getVideoURLWithNewModel:[_playerEpisodeModelLogicHelper playModelForFirstHavePlaybackRecordingWithModels:_episodeModelsArray]];
    }
}

-(void)playWithEpisodeModel:(ICEPlayerEpisodeModel *)model
{
    if (![_playerEpisodeModelLogicHelper isFirstModel:_currentPlayModel equalToSecondModel:model])
    {
        NSInteger Index=[_playerEpisodeModelLogicHelper indexWithPlayModel:model models:_episodeModelsArray];
        if (NSNotFound!=Index)
        {
            [self getVideoURLWithNewModel:_episodeModelsArray[Index]];
        }
        else
        {
            [self loadPlayerWithEpisodeModels:@[model]
                       isNeedRemindUserNoWIFI:_isNeedRemindUserNoWIFI
                      selectEpisodesViewStyle:_selectEpisodesViewStyle];
        }
    }
}

-(void)playVideoWithVideoID:(NSString *)videoID
{
    ICEPlayerEpisodeModel * model=[_playerEpisodeModelLogicHelper findPlayModelWithVideoID:videoID FromModels:_episodeModelsArray];
    if (model&&![_playerEpisodeModelLogicHelper isFirstModel:_currentPlayModel equalToSecondModel:model])
    {
        [self getVideoURLWithNewModel:model];
    }
}

-(void)playNextEpisode
{
    NSInteger Index=[_playerEpisodeModelLogicHelper indexWithPlayModel:_currentPlayModel models:_episodeModelsArray];
    if (NSNotFound!=Index)
    {
        NSInteger episodeCount=[_episodeModelsArray count];
        NSInteger nextEpisodeIndex=Index+1;
        if (nextEpisodeIndex<episodeCount)
        {
            [self getVideoURLWithNewModel:_episodeModelsArray[nextEpisodeIndex]];
        }
    }
}

- (void)switchPlayStateByUser
{
    if ([_player isPlayNow])
    {
        [self playerPauseWithReason:VideoPauseBecauseOfUserSelect];
    }
    else if([_player isCanPlayNow])
    {
        [self playerPlayWithReason:VideoPlayBecauseOfUserSelect];
    }
}

- (void)seekToDesiredSeconds:(NSTimeInterval)desiredSeconds
{
    //当seek的time大于totalSeconds时，loadtime会返回EMPTY或INVALID。导致用户滑动到最后isCanPlay一直判断不能播放
    //当seek的time大于total时可以在此处直接播放下一集，或者每次都是让播放器seek到total-2处
    //seek的带回掉block的方法都不准，block返回后也可能不能播放。所以就都不用了，自己判断
    CGFloat maxSeekSeconds=[_player currentItemTotalSeconds]-2;
    if (desiredSeconds>maxSeekSeconds)
    {
        desiredSeconds=maxSeekSeconds;
    }
    [_player seekToTime:CMTimeMake(desiredSeconds, 1)];
    if (![_player isCanPlayNow])
    {
        [self beganWaitBufferWithIsNormalPlay:NO];
    }
}

- (void)beganWaitBufferWithIsNormalPlay:(BOOL)isNormalPlay
{
    [self playerPauseWithReason:isNormalPlay?VideoPauseBecauseOfNormalPlayLeadToBufferEmpty:VideoPauseBecauseOfAdjustProgressLeadToBufferEmpty];
    _waitBufferSeconds=0;
    [_loadingView startLoading];
    if (_bufferTimer==nil)
    {
        self.bufferTimer=[NSTimer  timerWithTimeInterval:WaitBufferRepateTimeInterval
                                                  target:self
                                                selector:@selector(checkBuffer)
                                                userInfo:nil
                                                 repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_bufferTimer
                                     forMode:NSRunLoopCommonModes];
        [_bufferTimer fire];
    }
    else
    {
        [_bufferTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)endWaitBufferWithIsDestroy:(BOOL)isDestroy
{
    _waitBufferSeconds=0;
    [_readToPlayView stopLoading];
    if (isDestroy)
    {
        [_loadingView destroyLoading];
    }
    else
    {
        [_loadingView stopLoading];
    }
    if (_bufferTimer&&[_bufferTimer isValid])
    {
        if (isDestroy)
        {
            [_bufferTimer invalidate];
            self.bufferTimer=nil;
        }
        else
        {
            [_bufferTimer setFireDate:[NSDate distantFuture]];
        }
    }
}

- (void)checkBuffer
{
    if ([_player isCanPlayNow])
    {
        [self endWaitBufferWithIsDestroy:NO];
        if (_isCurrentVideoFirstLoad)
        {
            [self playerPlayWithReason:VideoPlayBecauseOfFirstLoadSuccessAutoPlay];
            _isCurrentVideoFirstLoad=NO;
        }
        else
        {
            [self playerPlayWithReason:VideoPlayBecauseOfBufferEnoughAutoPlay];
        }
    }
    else if(_waitBufferSeconds+=WaitBufferRepateTimeInterval,_waitBufferSeconds>MaxWaitBufferSeconds)
    {
        [_player currentItemCancelSeek];
        [self endWaitBufferWithIsDestroy:NO];
        [self playerFailedWithErrorStateType:ICEPlayerNetWorkBusy];
    }
}

-(void)retryLoadVideoAccordingToVideoLoadStage
{
    if (_currentPlayModel.url==nil||[_urlErrorTimesStatisticsHelper isMaxErrorTimesWithURLString:_currentPlayModel.url])
    {
        [self getVideoURLWithNewModel:_currentPlayModel];
    }
    else
    {
        [self loadVideoWithURLString:_currentPlayModel.url];
    }
}

-(void)playVideoAccordingToThePlayerStatus
{
    if (_isCurrentVideoFirstLoad)
    {
        [self playerPlayWithReason:VideoPlayBecauseOfFirstLoadSuccessAutoPlay];
        _isCurrentVideoFirstLoad=NO;
    }
    else if ([_player isCanPlayNow])
    {
        [self playerPlayWithReason:VideoPlayBecauseOfPlayerViewReappearOrNetworkResolvedAutoPlay];
    }
    else if([_player currentItemIsValid])
    {
        [self seekToDesiredSeconds:_bottomView.getProgressSeconds];
    }
    else
    {
        [self retryLoadVideoAccordingToVideoLoadStage];
    }
}

- (void)doSomethingAccordingToTheNetworkState
{
    NetworkStatus netStatus = [_reachability currentReachabilityStatus];
    if (NotReachable==netStatus)
    {
        [self playerFailedWithErrorStateType:ICEPlayerNoNetWork];
    }
    else if(ReachableViaWWAN==netStatus)
    {
        if (_isNeedRemindUserNoWIFI)
        {
            [self playerFailedWithErrorStateType:ICEPlayerNoWIFI];
        }
        else
        {
            [_errorStateView hideErrorStateView];
            [self playVideoAccordingToThePlayerStatus];
        }
    }
    else if(ReachableViaWiFi==netStatus)
    {
        [_errorStateView hideErrorStateView];
        [self playVideoAccordingToThePlayerStatus];
    }
}

-(void)videoLoadFailed
{
    [_readToPlayView stopLoading];
    if (NotReachable==[_reachability currentReachabilityStatus])
    {
        [self playerFailedWithErrorStateType:ICEPlayerNoNetWork];
    }
    else if(_currentPlayModel.url==nil||[_urlErrorTimesStatisticsHelper isMaxErrorTimesWithURLString:_currentPlayModel.url])
    {
        [self playerFailedWithErrorStateType:ICEPlayerVideoURLInValid];
    }
    else
    {
        [self playerFailedWithErrorStateType:ICEPlayerVideoLoadFailed];
    }
}

-(void)videoLoadSuccessWithVideoTotalSeconds:(NSTimeInterval)totalSeconds
{
    _maxChangeSecondsOneTimeForPanScreenAdjustProgress=MIN(MaxChangeSecondsOneTime,totalSeconds);
    [_currentPlayModel setTotalSeconds:totalSeconds];
    [_currentPlayModel setTimeStamp:time(NULL)];
    [_topView setTitle:_currentPlayModel.videoName];
    [_progressView reloadWithTotalSeconds:totalSeconds];
    [_bottomView reloadWithTotalSeconds:totalSeconds];
    [_selectEpisodesView playEpisode];
    NSTimeInterval lastPlaySeconds=[_currentPlayModel lastPlaySeconds];
    if (lastPlaySeconds)
    {
        [self seekToDesiredSeconds:lastPlaySeconds];
        [_bottomView setProgressSeconds:lastPlaySeconds];
    }
    else
    {
        [_readToPlayView stopLoading];
        [self doSomethingAccordingToTheNetworkState];
    }
}

#pragma mark NSKeyValueObservingCallBack
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSString *,id> *)change
                      context:(void *)context
{
    if([keyPath isEqualToString:HiddenKeyPath])
    {
        if(![change[NSKeyValueChangeNewKey] boolValue])
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopAndBottomView) object:nil];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            if (object==_readToPlayView)
            {
                [_errorStateView hideErrorStateView];
                [_selectEpisodesView setHidden:YES];
            }
            else if(object==_errorStateView)
            {
                [_readToPlayView stopLoading];
            }
        }
        else if(!_isFirstLoadPlayer&&[_readToPlayView isHidden]&&[_errorStateView isHidden]&&[_selectEpisodesView isHidden])
        {
            [self showTopAndBottomView];
        }
    }
    else if([keyPath isEqualToString:PlayerRateKeyPath])
    {
        [_bottomView setIsPlay:[_player isPlayNow]];
    }
    else if([keyPath isEqualToString:CurrentItemStatusKeyPath])
    {
        //m3u8时currentItem的status每次seek都会改变(可能是因为m3u8要下载视频片段的原因，且m3u8时playbackBufferEmpty和playbackLikelyToKeepUp会被多次调用且不准确，所以自己通过定时器检查item是否可以播放，而mp4就只在一开始加载时触发一次，相对来说playbackBufferEmpty和playbackLikelyToKeepUp也准确些,（实验了好多次发现只有load>当前的进度（＋自己设置的富余秒数）且playbackLikelyToKeepUp=YES时才可以播放）)。
        //为了兼容，所以不管是不是m3u8都只处理第一次加载视频时的回调，而其他的逻辑在每次seek和AVPlayerItemPlaybackStalledNotification的回调中处理。
        //设定超过30秒仍然不能达到播放条件就提示用户网络繁忙(无论m3u8或者mp4，wifi情况下极少出现卡顿或长时间不返回的情况，4g勉强能用，3g网络几乎每次seek都要等待，而且长时间不返回（也有返回的时候），且缓存不再增加
        //翻墙查了下说是“The problem was with the content distribution network. The streaming url was expiring and then would no longer stream to the player”)
        if([_player currentItemIsValid])
        {
            if (![change[NSKeyValueChangeOldKey] boolValue])
            {
                NSTimeInterval totalSeconds=[_player currentItemTotalSeconds];
                if (INVALIDSECONDS==totalSeconds)
                {
                    [self videoLoadFailed];
                }
                else
                {
                    _isCurrentVideoFirstLoad=YES;
                    [self videoLoadSuccessWithVideoTotalSeconds:totalSeconds];
                }
            }
        }
        else
        {
            [self videoLoadFailed];
        }
    }
    else if([keyPath isEqualToString:CurrentItemLoadedTimeRangesKeyPath])
    {
        NSTimeInterval loadSeconds=[_player currentItemLoadSeconds];
        NSTimeInterval totalSeconds=[_player currentItemTotalSeconds];
        if (INVALIDSECONDS!=loadSeconds&&
            INVALIDSECONDS!=totalSeconds)
        {
            [_bottomView updateBufferWithLoadSeconds:loadSeconds];
        }
    }
}

#pragma mark UIGestureRecognizerDelegateMethods
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([_player currentItemIsValid]&&
        [touch.view isKindOfClass:[self class]])
    {
        return YES;
    }
    return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired==1)
    {
        if (![_selectEpisodesView isHidden])
        {
            [_selectEpisodesView setHidden:YES];
        }
        else
        {
            BOOL isHidden=[_topView isWillHide];
            if (isHidden)
            {
                [self showTopAndBottomView];
            }
            else
            {
                [self hideTopAndBottomView];
            }
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired==2)
    {
        [self switchPlayStateByUser];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [self touchesBeganWithPanGesture:gestureRecognizer];
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        [self touchesMovedWithPanGesture:gestureRecognizer];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded||
             gestureRecognizer.state == UIGestureRecognizerStateFailed||
             gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self touchesEndedWithPanGesture:gestureRecognizer];
    }
}

- (void)touchesBeganWithPanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint point =[gestureRecognizer velocityInView:self];
    CGFloat movePointX=fabs(point.x);
    CGFloat movePointY=fabs(point.y);
    CGPoint touchBeganPoint=[gestureRecognizer locationInView:self];
    CGFloat touchBeganX=touchBeganPoint.x;
    CGFloat touchBeganY=touchBeganPoint.y;
    if (movePointX>movePointY)
    {
        _panGestureModel.panOffsetValue=touchBeganX;
        _panGestureModel.panScreenPurpose=PanScreenForAdjustProgress;
        NSTimeInterval  updatedSeconds;
        [_progressView updateProgressWithChangeSeconds:[_bottomView getProgressSeconds]
                                         actionOptions:PlayerProgressViewUpdateBegan
                                        updatedSeconds:&updatedSeconds];
        [_bottomView setProgressSeconds:updatedSeconds];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopAndBottomView) object:nil];
    }
    else
    {
        _panGestureModel.panOffsetValue=touchBeganY;
        _panGestureModel.panScreenPurpose=(touchBeganX<=CGRectGetMidX(self.frame)?PanScreenForAdjustVolume:PanScreenForAdjustBrightness);
    }
}

- (void)touchesMovedWithPanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint point =[gestureRecognizer velocityInView:self];
    CGFloat movePointX=point.x;
    CGFloat movePointY=point.y;
    CGPoint touchMovePoint=[gestureRecognizer locationInView:self];
    PanScreenPurposeOptions panScreenPurpose = _panGestureModel.panScreenPurpose;
    CGFloat lastPanOffsetValue=_panGestureModel.panOffsetValue;
    if (PanScreenForAdjustProgress==panScreenPurpose)
    {
        ICEPlayerProgressViewActionOptions actionOptions = (movePointX<0?PlayerProgressViewGoReverse:PlayerProgressViewGoForward);
        CGFloat touchMoveX=touchMovePoint.x;
        CGFloat distance=fabs(touchMoveX-lastPanOffsetValue);
        NSTimeInterval changeSeconds=distance/CGRectGetWidth(self.bounds)*_maxChangeSecondsOneTimeForPanScreenAdjustProgress;
        NSTimeInterval updatedSeconds;
        [_progressView updateProgressWithChangeSeconds:changeSeconds
                                         actionOptions:actionOptions
                                        updatedSeconds:&updatedSeconds];
        [_bottomView setProgressSeconds:updatedSeconds];
        _panGestureModel.panOffsetValue=touchMoveX;
    }
    else
    {
        CGFloat touchMoveY=touchMovePoint.y;
        CGFloat distance=fabs(touchMoveY-lastPanOffsetValue);
        CGFloat changeValue=distance/_maxPanDistanceForAdjustVolumeOrBrightness;
        if(PanScreenForAdjustVolume==panScreenPurpose)
        {
            CGFloat currentValue=[_volumeView getVolume];
            if (movePointY<0)
            {
                currentValue+=changeValue;
            }
            else
            {
                currentValue-=changeValue;
            }
            [_volumeView setVolume:currentValue];
        }
        else if(PanScreenForAdjustBrightness==panScreenPurpose)
        {
            CGFloat currentValue=[_brightnessView getBrightness];
            if (movePointY<0)
            {
                currentValue+=changeValue;
            }
            else
            {
                currentValue-=changeValue;
            }
            [_brightnessView setBrightness:currentValue];
        }
        _panGestureModel.panOffsetValue=touchMoveY;
    }
}

- (void)touchesEndedWithPanGesture:gestureRecognizer
{
    PanScreenPurposeOptions panScreenPurpose = _panGestureModel.panScreenPurpose;
    if (PanScreenForAdjustProgress==panScreenPurpose)
    {
        NSTimeInterval  updatedSeconds;
        [_progressView updateProgressWithChangeSeconds:0
                                         actionOptions:PlayerProgressViewUpdateEnd
                                        updatedSeconds:&updatedSeconds];
        [_bottomView setProgressSeconds:updatedSeconds];
        [self seekToDesiredSeconds:updatedSeconds];
        [self performSelector:@selector(hideTopAndBottomView) withObject:nil afterDelay:TopAndBottomDelaySecondsToHide];
        [_readToPlayView haveLearnedAdjust:ICEDirectiveForAdjustProgress];
    }
    else if(PanScreenForAdjustVolume==panScreenPurpose)
    {
        [_volumeView setHidden:YES];
        [_readToPlayView haveLearnedAdjust:ICEDirectiveForAdjustVolume];
    }
    else if(PanScreenForAdjustBrightness==panScreenPurpose)
    {
        [_brightnessView setHidden:YES];
        [_readToPlayView haveLearnedAdjust:ICEDirectiveForAdjustBrightness];
    }
    _panGestureModel.panOffsetValue=0;
    _panGestureModel.panScreenPurpose=PanScreenForNothing;
}

@end
