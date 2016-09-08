//
//  ICEPlayerView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerView.h"
#import "ICEPlayerTopView.h"
#import "ICEPlayerVolumeView.h"
#import "ICEPlayerBrightnessView.h"
#import "ICEPlayerProgressView.h"
#import "ICEPlayerBottomView.h"
#import "AVPlayer+CurrentPlayerItemData.h"

#define PlayerTopViewVHeight        42
#define PlayerTopViewHHeight        60

#define PlayerBottomViewVHeight     45
#define PlayerBottomViewHHeight     56

#define MaxChangeSecondsOneTime     600

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


@interface ICEPlayerView ()
<
UIGestureRecognizerDelegate
>
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL isFullScreen;
@property (nonatomic,assign) BOOL isLockScreen;
@property (nonatomic,assign) CGRect playerViewVFrame;
@property (nonatomic,assign) CGRect playerViewHFrame;
@property (nonatomic,assign) CGFloat maxPanDistanceForAdjustVolumeOrBrightness;
@property (nonatomic,assign) NSTimeInterval maxChangeSecondOneTimeForPanScreenAdjustProgress;
@property (nonatomic,strong) PanGestureModel * panGestureModel;
@property (nonatomic,strong) NSMutableArray * episodeModelsArray;
@property (nonatomic,strong) ICEPlayerEpisodeModel * currentPlayModel;
@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;
@property (nonatomic,strong) id playerTimeObserver;
@property (nonatomic,strong) ICEButton * returnButton;
@property (nonatomic,strong) ICEPlayerTopView * playerTopView;
@property (nonatomic,strong) ICEPlayerVolumeView * playerVolumeView;
@property (nonatomic,strong) ICEPlayerBrightnessView * playerBrightnessView;
@property (nonatomic,strong) ICEPlayerProgressView * playerProgressView;
@property (nonatomic,strong) ICEPlayerBottomView * playerBottomView;
@end

@implementation ICEPlayerView

- (void)dealloc
{
    [_player removeTimeObserver:_playerTimeObserver];
    [_player removeTimeObserver:self];
    self.playerTimeObserver=nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(id)initWithPlayerViewVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame
{
    if (self=[super initWithFrame:vFrame])
    {
        [self setBackgroundColor:[UIColor blackColor]];
        [self setUserInteractionEnabled:YES];
        [self.layer setMasksToBounds:YES];
        
        _isLoading=NO;
        _isFullScreen=NO;
        _isLockScreen=NO;
        _playerViewVFrame=vFrame;
        _playerViewHFrame=hFrame;
        _maxPanDistanceForAdjustVolumeOrBrightness=CGRectGetHeight(vFrame)-PlayerTopViewVHeight-PlayerBottomViewVHeight;
        _maxChangeSecondOneTimeForPanScreenAdjustProgress=MaxChangeSecondsOneTime;

        self.panGestureModel=[[PanGestureModel alloc] init];
        _panGestureModel.panOffsetValue=0;
        _panGestureModel.panScreenPurpose=PanScreenForNothing;
        
        //设备旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
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
        
        [self addReturnButton];
        [self addPlayerTopView];
        [self addPlayerVolumeView];
        [self addPlayerBrightnessView];
        [self addPlayerProgressView];
        [self addPlayerBottomView];
    }
    return self;
}

- (void)setIsLockScreen:(BOOL)isLockScreen
{
    _isLockScreen=isLockScreen;
    [_playerTopView setIsLockScreen:_isLockScreen];
    [self goLockScreen];
}

- (void)transformPlayerViewWithUIInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationPortrait==interfaceOrientation)
    {
        if (_isFullScreen)
        {
            _isFullScreen=NO;
            [UIView animateWithDuration:0.2f animations:^{
                [self setFrame:_playerViewVFrame];
                [_playerLayer setFrame:self.bounds];
                [_playerTopView setTopViewStyle:ICEPlayerTopViewVerticalStyle];
                [_playerBottomView setBottomViewStyle:ICEPlayerBottomViewVerticalStyle];
                [_returnButton setHidden:NO];
            }completion:^(BOOL finished) {
                
            }];
        }
    }
    else if(UIInterfaceOrientationLandscapeLeft==interfaceOrientation||
            UIInterfaceOrientationLandscapeRight==interfaceOrientation)
    {
        if (!_isFullScreen)
        {
            _isFullScreen=YES;
            [UIView animateWithDuration:0.2f animations:^{
                [self setFrame:_playerViewHFrame];
                [_playerLayer setFrame:self.bounds];
                [_playerTopView setTopViewStyle:ICEPlayerTopViewHorizontalStyle];
                [_playerBottomView setBottomViewStyle:ICEPlayerBottomViewHorizontalStyle];
                [_returnButton setHidden:YES];
            }completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self transformPlayerViewWithUIInterfaceOrientation:interfaceOrientation];
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
        int val = _isFullScreen?UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)switchPlayState
{
    if ([_player currentItemIsValid])
    {
        if (_player.rate)
        {
            [_player pause];
        }
        else
        {
            [_player play];
        }
    }
}

-(void)loadPlayerWithEpisodeModels:(NSArray *)episodeModels
{
    if (episodeModels)
    {
        if (_episodeModelsArray==nil)
        {
            self.episodeModelsArray=[[NSMutableArray alloc] init];
        }
        [_episodeModelsArray setArray:episodeModels];
    }
}

-(void)loadPlayerWithEpisodeModel:(ICEPlayerEpisodeModel *)episodeModel
{
    self.currentPlayModel=episodeModel;
}

-(void)playWithUrl:(NSURL *)url
{
    if (_player==nil)
    {
        __weak typeof(self) wself=self;
        self.player=[[AVPlayer alloc] init];
        self.playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        [_playerLayer setVideoGravity:AVLayerVideoGravityResize];
        [_playerLayer setFrame:self.bounds];
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        self.playerTimeObserver=[_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:NULL usingBlock:^(CMTime time){
            if (CMTIME_IS_VALID(time))
            {
                if (PanScreenForNothing==wself.panGestureModel.panOffsetValue&&
                    ICEPlayerBottomViewSliderAdjustProgressEnd==wself.playerBottomView.sliderEventModel.event&&
                    !wself.isLoading&&
                    [wself.player currentItemIsValid])
                {
                    [wself.playerBottomView updateProgressWithDesiredSeconds:CMTimeGetSeconds(time)];
                }
            }
        }];
        [self.layer insertSublayer:_playerLayer atIndex:0];
    }
    if (url)
    {
        AVPlayerItem * playerItem=_player.currentItem;
        if (playerItem)
        {
            [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
            [playerItem removeObserver:self forKeyPath:@"status"];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        }
        playerItem=[AVPlayerItem playerItemWithURL:url];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [_player replaceCurrentItemWithPlayerItem:playerItem];
    }
}

- (void)seekToDesiredSecond:(NSTimeInterval)desiredSecond
{
    if ([_player currentItemIsValid])
    {
        __weak typeof(self) wself = self;
        _isLoading=YES;
        [_player seekToTime:CMTimeMake(desiredSecond, 1) completionHandler:^(BOOL finished){
            NSLog(@"finished=%d",finished);
            wself.isLoading=NO;
            if (wself.player.rate==0) {
                [wself.player play];
            }
        }];
    }
    else
    {
        [_playerBottomView updateProgressWithDesiredSeconds:0];
    }
}


- (void)moviePlayDidEnd:(NSNotification *)notification
{
    //    __weak typeof(self) weakSelf = self;
    //    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
    //        NSLog(@"aaaa");
    //    }];
}

-(void)executePlayStateBlockWithPlayStateOptions:(ICEPlayerViewPlayStateOptions)playState
{
    if (_playStateBlock)
    {
        _playStateBlock(playState,_currentPlayModel);
    }
}

-(void)goCollectVideo
{
    if (_collectVideoBlock)
    {
        _collectVideoBlock(_currentPlayModel);
    }
}

-(void)goReturn
{
    if (_returnBlock)
    {
        _returnBlock();
    }
}

-(void)goLockScreen
{
    if (_lockScreenBlock)
    {
        _lockScreenBlock(_isLockScreen);
    }
}

-(void)addReturnButton
{
    if (_returnButton==nil)
    {
        UIImage * returnImage=IMAGENAME(@"playerReturn@2x", @"png");
        CGRect returnButtonFrame=CGRectMake(6, 6, returnImage.size.width, returnImage.size.height);
        self.returnButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [_returnButton setImage:returnImage forState:UIControlStateNormal];
        [_returnButton setFrame:returnButtonFrame];
        [_returnButton addTarget:self action:@selector(goReturn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_returnButton];
    }
}

-(void)addPlayerTopView
{
    if (_playerTopView==nil)
    {
        __weak typeof(self) wself=self;
        CGRect topVFrame=CGRectMake(0, 0, CGRectGetWidth(_playerViewVFrame), PlayerTopViewVHeight);
        CGRect topHFrame=CGRectMake(0, 0, CGRectGetWidth(_playerViewHFrame), PlayerTopViewHHeight);
        self.playerTopView=[[ICEPlayerTopView alloc]initWithTopViewVFrame:topVFrame HFrame:topHFrame];
        [_playerTopView setControlEventBlock:^(ICEPlayerTopViewControlEvents event){

            switch (event) {
                case ICEPlayerTopViewSwitchToVSizeEvent:
                    [wself switchPlayerViewOrientation];
                    break;
                case ICEPlayerTopViewLockScreenEvent:
                    wself.isLockScreen=!wself.isLockScreen;
                    break;
                case ICEPlayerTopViewCollectEvent:
                    break;
                case ICEPlayerTopViewSelectEpisodeEvent:
                    break;
                default:
                    break;
            }
        }];
        [self insertSubview:_playerTopView belowSubview:_returnButton];
    }
}

-(void)addPlayerProgressView
{
    if(_playerProgressView==nil)
    {
        self.playerProgressView=[[ICEPlayerProgressView alloc]initWithProgressViewWidth:150];
        [_playerProgressView addToSuperViewAndaddConstraintsWithSuperView:self];
    }
}

-(void)addPlayerVolumeView
{
    if (_playerVolumeView==nil)
    {
        self.playerVolumeView=[[ICEPlayerVolumeView alloc] initWithVolumeViewWidth:24
                                                                  volumeViewHeight:_maxPanDistanceForAdjustVolumeOrBrightness-10];
        [_playerVolumeView addToSuperViewAndaddConstraintsWithSuperView:self];
    }
}

-(void)addPlayerBrightnessView
{
    if (_playerBrightnessView==nil)
    {
        self.playerBrightnessView=[[ICEPlayerBrightnessView alloc]initWithBrightnessViewWidth:24
                                                                         brightnessViewHeight:_maxPanDistanceForAdjustVolumeOrBrightness-10];
        [_playerBrightnessView addToSuperViewAndaddConstraintsWithSuperView:self];
    }
}

-(void)addPlayerBottomView
{
    if (_playerBottomView==nil)
    {
        __weak typeof(self) wself=self;
        CGRect bottomVFrame=CGRectMake(0, CGRectGetHeight(_playerViewVFrame)-PlayerBottomViewVHeight, CGRectGetWidth(_playerViewVFrame), PlayerBottomViewVHeight);
        CGRect bottomHFrame=CGRectMake(0, CGRectGetHeight(_playerViewHFrame)-PlayerBottomViewHHeight, CGRectGetWidth(_playerViewHFrame), PlayerBottomViewHHeight);
        self.playerBottomView=[[ICEPlayerBottomView alloc] initWithBottomViewVFrame:bottomVFrame HFrame:bottomHFrame];
        [_playerBottomView setSliderEventBlock:^(NSTimeInterval desiredSeconds,ICEPlayerBottomViewSliderEvents sliderEvent)
         {
             ICEPlayerProgressViewActionOptions actionOptions;
             switch (sliderEvent)
             {
                 case ICEPlayerBottomViewSliderAdjustProgressBegan:
                     actionOptions=PlayerProgressViewUpdateBegan;
                     break;
                 case ICEPlayerBottomViewSliderAdjustProgressForward:
                     actionOptions=PlayerProgressViewGoForward;
                     break;
                 case ICEPlayerBottomViewSliderAdjustProgressReverse:
                     actionOptions=PlayerProgressViewGoReverse;
                     break;
                 case ICEPlayerBottomViewSliderAdjustProgressEnd:
                     actionOptions=PlayerProgressViewUpdateEnd;
                     [wself seekToDesiredSecond:desiredSeconds];
                     break;
                 default:
                     break;
             }
             [wself.playerProgressView updateProgressWithDesiredSeconds:desiredSeconds actionOptions:actionOptions];
         }];
        [_playerBottomView setControlEventBlock:^(ICEPlayerBottomViewControlEvents controlEvent)
         {
             switch (controlEvent)
             {
                 case ICEPlayerBottomViewControlPlayOrPause:
                     [wself switchPlayState];
                     break;
                 case ICEPlayerBottomViewControlSwitchSize:
                     [wself switchPlayerViewOrientation];
                     break;
                 case ICEPlayerBottomViewControlLookNextEpisode:
                     break;
                 default:
                     break;
             }
         }];
        [self addSubview:_playerBottomView];
    }
}

#pragma mark  - NSKeyValueObservingCallBack
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSString *,id> *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"rate"])
    {
        [_playerBottomView setIsPlay:_player.rate?YES:NO];
    }
    else if ([keyPath isEqualToString:@"status"])
    {
        if([_player currentItemIsValid])
        {
            //[_player play];
            NSTimeInterval totalSeconds=[_player currentItemTotalSeconds];
            NSTimeInterval currentSeconds=[_player currentItemCurrentSeconds];
            _maxChangeSecondOneTimeForPanScreenAdjustProgress=MIN(MaxChangeSecondsOneTime,totalSeconds);
            [_playerProgressView reloadWithCurrentSeconds:currentSeconds totalSeconds:totalSeconds];
            [_playerBottomView reloadWithCurrentSeconds:currentSeconds totalSeconds:totalSeconds];
            NSLog(@"加载视频成功");
        }
        else
        {
            NSLog(@"加载视频失败");
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        [_playerBottomView updateBufferWithLoadSeconds:[_player currentItemLoadSeconds]];
    }
}

-(void)showChildView
{
    [_playerTopView setHidden:NO];
    [_playerBottomView setHidden:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideChildView) object:nil];
    [self performSelector:@selector(hideChildView) withObject:nil afterDelay:5];
}

-(void)hideChildView
{
    [_playerTopView setHidden:YES];
    [_playerBottomView setHidden:YES];
}

#pragma mark - UIGestureRecognizerDelegateMethods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[self class]])
    {
        return YES;
    }
    return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired==1)
    {
        BOOL isHidden=_playerTopView.isHidden;
        if (isHidden)
        {
            [self showChildView];
        }
        else
        {
            [self hideChildView];
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired==2)
    {
        [self switchPlayState];
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
        if ([_player currentItemIsValid])
        {
            _panGestureModel.panOffsetValue=touchBeganX;
            _panGestureModel.panScreenPurpose=PanScreenForAdjustProgress;
            NSTimeInterval  updatedSeconds;
            [_playerProgressView updateProgressWithChangeSeconds:[_player currentItemCurrentSeconds]
                                                   actionOptions:PlayerProgressViewUpdateBegan
                                                  updatedSeconds:&updatedSeconds];
            [_playerBottomView updateProgressWithDesiredSeconds:updatedSeconds];
        }
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
        NSTimeInterval changeSeconds=distance/CGRectGetWidth(self.bounds)*_maxChangeSecondOneTimeForPanScreenAdjustProgress;
        NSTimeInterval updatedSeconds;
        [_playerProgressView updateProgressWithChangeSeconds:changeSeconds
                                               actionOptions:actionOptions
                                              updatedSeconds:&updatedSeconds];
        [_playerBottomView updateProgressWithDesiredSeconds:updatedSeconds];
        _panGestureModel.panOffsetValue=touchMoveX;
    }
    else
    {
        CGFloat touchMoveY=touchMovePoint.y;
        CGFloat distance=fabs(touchMoveY-lastPanOffsetValue);
        CGFloat changeValue=distance/_maxPanDistanceForAdjustVolumeOrBrightness;
        if(PanScreenForAdjustVolume==panScreenPurpose)
        {
            CGFloat currentValue=_playerVolumeView.volume;
            if (movePointY<0)
            {
                currentValue+=changeValue;
            }
            else
            {
                currentValue-=changeValue;
            }
            _playerVolumeView.volume=currentValue;
        }
        else if(PanScreenForAdjustBrightness==panScreenPurpose)
        {
            CGFloat currentValue=_playerBrightnessView.brightness;
            if (movePointY<0)
            {
                currentValue+=changeValue;
            }
            else
            {
                currentValue-=changeValue;
            }
            _playerBrightnessView.brightness=currentValue;
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
        [_playerProgressView updateProgressWithChangeSeconds:0
                                               actionOptions:PlayerProgressViewUpdateEnd
                                              updatedSeconds:&updatedSeconds];
        [_playerBottomView updateProgressWithDesiredSeconds:updatedSeconds];
        [self seekToDesiredSecond:updatedSeconds];
    }
    else if(PanScreenForAdjustVolume==panScreenPurpose)
    {
        [_playerVolumeView setHidden:YES];
    }
    else if(PanScreenForAdjustBrightness==panScreenPurpose)
    {
        [_playerBrightnessView setHidden:YES];
    }
    _panGestureModel.panOffsetValue=0;
    _panGestureModel.panScreenPurpose=PanScreenForNothing;
}

@end
