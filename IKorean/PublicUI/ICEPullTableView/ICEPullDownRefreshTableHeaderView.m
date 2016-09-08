//
//  ICEPullDownRefreshTableHeaderView.m
//  GameCircle
//
//  Created by wangyunlong on 15/8/4.
//  Copyright (c) 2015年 wangyunlong. All rights reserved.
//

#import "ICEPullDownRefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#define ICE_Prefix_                    @"ICE_Prefix_"

#define ICE_TimeInterval_Minute        60
#define ICE_TimeInterval_Hour          3600
#define ICE_TimeInterval_Day           86400
#define ICE_TimeInterval_10_Day        864000

@interface ICEPullDownRefreshTableHeaderView ()

@property (nonatomic,assign,readwrite) BOOL isLoading;
@property (nonatomic,assign) CGFloat refreshViewWidth;
@property (nonatomic,assign) CGFloat refreshViewHeight;
@property (nonatomic,assign) NSTimeInterval refreshTimeInterval;
@property (nonatomic,assign) RefreshViewStatus refreshViewStatus;
@property (nonatomic,copy)   NSString * tableViewName;
@property (nonatomic,strong) NSDateFormatter * dateFormatter;
@property (nonatomic,strong) UILabel * statueLabel;
@property (nonatomic,strong) UILabel * lastRefreshDateLabel;
@property (nonatomic,strong) UIImageView * loadingImageView;
@property (nonatomic,strong) NSTimer * loadingTimer;
@property (nonatomic,strong) UIImageView * arrowImageView;
@property (nonatomic,assign) CGFloat loadingViewAngle;

@end

@implementation ICEPullDownRefreshTableHeaderView
-(void)dealloc
{
    [self destroyLoading];
}

-(id)initWithFrame:(CGRect)frame
     tableViewName:(NSString *)tableViewName
refreshTimeInterval:(NSTimeInterval)refreshTimeInterval
{
    if (self=[super initWithFrame:frame])
    {
        _isLoading=NO;
        _refreshViewWidth=CGRectGetWidth(frame);
        _refreshViewHeight=CGRectGetHeight(frame);
        _refreshViewStatus=RefreshViewStatus_DragDownToUpdate;
        _refreshTimeInterval=refreshTimeInterval;
        _loadingViewAngle=0.0f;
        if (![[ICEAppHelper shareInstance]isStringIsEmpty:tableViewName])
        {
            self.tableViewName=[NSString stringWithFormat:@"%@%@",ICE_Prefix_,tableViewName];
            
            //日期格式
            self.dateFormatter = [[NSDateFormatter alloc] init] ;
            [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
            
            //状态label
            CGFloat statusLabelWidth=110;
            CGFloat statusLabelHeight=16;
            CGRect  statusLabelFrame=CGRectMake((_refreshViewWidth-statusLabelWidth)/2, 8, statusLabelWidth, statusLabelHeight);
            self.statueLabel=[[UILabel alloc] initWithFrame:statusLabelFrame];
            [_statueLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:14]];
            [_statueLabel setText:@"下拉更新"];
            [_statueLabel setTextAlignment:NSTextAlignmentCenter];
            [_statueLabel setTextColor:[UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1.0f]];
            [self addSubview:_statueLabel];
            
            //日期label
            CGFloat lastRefreshDateLabelWidth=140;
            CGFloat lastRefreshDateLabelHeight=14;
            CGRect  lastRefreshDateLabelFrame=CGRectMake((_refreshViewWidth-lastRefreshDateLabelWidth)/2,
                                                         CGRectGetMaxY(statusLabelFrame)+6,
                                                         lastRefreshDateLabelWidth,
                                                         lastRefreshDateLabelHeight);
            
            self.lastRefreshDateLabel=[[UILabel alloc] initWithFrame:lastRefreshDateLabelFrame];
            [_lastRefreshDateLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:12]];
            [_lastRefreshDateLabel setText:[self getLastRefreshDate]];
            [_lastRefreshDateLabel setTextAlignment:NSTextAlignmentCenter];
            [_lastRefreshDateLabel setTextColor:[UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0f]];
            [self addSubview:_lastRefreshDateLabel];
            
            //箭头
            UIImage * arrowImage=IMAGENAME(@"ico_pull@2x", @"png");
            CGFloat arrowImageWidth=arrowImage.size.width;
            CGFloat arrowImageHeight=arrowImage.size.height;
            CGRect  arrowImageFrame=CGRectMake(CGRectGetMinX(lastRefreshDateLabelFrame)-8-arrowImageWidth,
                                               (_refreshViewHeight-arrowImageHeight)/2,
                                               arrowImageWidth,
                                               arrowImageHeight);
            
            self.arrowImageView=[[UIImageView alloc] initWithFrame:arrowImageFrame];
            [_arrowImageView setImage:arrowImage];
            [self addSubview:_arrowImageView];
            
            //loadingView
            UIImage * loadingImage=IMAGENAME(@"cut_loading_gery@2x", @"png");;
            CGFloat loadingImageWidth=loadingImage.size.width;
            CGFloat loadingImageHeight=loadingImage.size.height;
            CGRect  loadingImageFrame=CGRectMake(CGRectGetMinX(lastRefreshDateLabelFrame)-5-loadingImageWidth,
                                                 (_refreshViewHeight-loadingImageHeight)/2,
                                                 loadingImageWidth,
                                                 loadingImageHeight);
            
            self.loadingImageView=[[UIImageView alloc] initWithFrame:loadingImageFrame];
            [_loadingImageView setImage:loadingImage];
            [self addSubview:_loadingImageView];
            [_loadingImageView setHidden:YES];
        }
        else
        {
            //状态label
            CGFloat statusLabelWidth=110;
            CGFloat statusLabelHeight=16;
            CGRect  statusLabelFrame=CGRectMake((_refreshViewWidth-statusLabelWidth)/2,
                                                (_refreshViewHeight-statusLabelHeight)/2,
                                                statusLabelWidth,
                                                statusLabelHeight);
            self.statueLabel=[[UILabel alloc] initWithFrame:statusLabelFrame];
            [_statueLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:14]];
            [_statueLabel setText:@"下拉更新"];
            [_statueLabel setTextAlignment:NSTextAlignmentCenter];
            [_statueLabel setTextColor:[UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1.0f]];
            [self addSubview:_statueLabel];
            
            //箭头
            UIImage * arrowImage=IMAGENAME(@"ico_pull@2x", @"png");
            CGFloat arrowImageWidth=arrowImage.size.width;
            CGFloat arrowImageHeight=arrowImage.size.height;
            CGRect  arrowImageFrame=CGRectMake(CGRectGetMinX(statusLabelFrame)-8-arrowImageWidth,
                                               (_refreshViewHeight-arrowImageHeight)/2,
                                               arrowImageWidth,
                                               arrowImageHeight);
            
            self.arrowImageView=[[UIImageView alloc] initWithFrame:arrowImageFrame];
            [_arrowImageView setImage:arrowImage];
            [self addSubview:_arrowImageView];
            
            //loadingView
            UIImage * loadingImage=IMAGENAME(@"cut_loading_gery@2x", @"png");;
            CGFloat loadingImageWidth=loadingImage.size.width;
            CGFloat loadingImageHeight=loadingImage.size.height;
            CGRect  loadingImageFrame=CGRectMake(CGRectGetMinX(statusLabelFrame)-5-loadingImageWidth,
                                                 (_refreshViewHeight-loadingImageHeight)/2,
                                                 loadingImageWidth,
                                                 loadingImageHeight);
            
            self.loadingImageView=[[UIImageView alloc] initWithFrame:loadingImageFrame];
            [_loadingImageView setImage:loadingImage];
            [self addSubview:_loadingImageView];
            [_loadingImageView setHidden:YES];
        }
    }
    return self;
}

- (BOOL)isShouldRefresh
{
    BOOL isRefresh = NO;
    if (_tableViewName)
    {
        NSDate * lastRefreshDate=[[NSUserDefaults standardUserDefaults] objectForKey:_tableViewName];
        if (lastRefreshDate)
        {
            NSTimeInterval timeInterval=[[NSDate date] timeIntervalSinceDate:lastRefreshDate];
            if (timeInterval>=_refreshTimeInterval)
            {
                isRefresh=YES;
            }
        }
    }
    return isRefresh;
}

- (NSString *)getLastRefreshDate
{
    NSString * lastRefreshDateString=nil;
    if (_tableViewName)
    {
        NSDate * lastRefreshDate=[[NSUserDefaults standardUserDefaults] objectForKey:_tableViewName];
        if (lastRefreshDate)
        {
            NSDate * nowDate=[NSDate date];
            NSTimeInterval timeInterval=[nowDate timeIntervalSinceDate:lastRefreshDate];
            if (timeInterval<ICE_TimeInterval_Minute)
            {
                lastRefreshDateString=@"最近更新时间:刚刚";
            }
            else if(timeInterval>=ICE_TimeInterval_Minute&&timeInterval<ICE_TimeInterval_Hour)
            {
                lastRefreshDateString=[NSString stringWithFormat:@"最近更新时间:%d分钟前",(int)(timeInterval/ICE_TimeInterval_Minute)];
            }
            else if(timeInterval>=ICE_TimeInterval_Hour&&timeInterval<ICE_TimeInterval_Day)
            {
                lastRefreshDateString=[NSString stringWithFormat:@"最近更新时间:%d小时前",(int)(timeInterval/ICE_TimeInterval_Hour)];
            }
            else if(timeInterval>=ICE_TimeInterval_Day&&timeInterval<ICE_TimeInterval_10_Day)
            {
                lastRefreshDateString=[NSString stringWithFormat:@"最近更新时间:%d天前",(int)(timeInterval/ICE_TimeInterval_Day)];
            }
            else if(timeInterval>=ICE_TimeInterval_10_Day)
            {
                NSString * refreshDate=[_dateFormatter stringFromDate:nowDate];
                if (refreshDate)
                {
                    lastRefreshDateString=[NSString stringWithFormat:@"最近更新时间:%@",refreshDate];
                }
            }
        }
    }
    if (lastRefreshDateString==nil)
    {
       lastRefreshDateString=@"最近更新时间:从未更新";
    }
    return lastRefreshDateString;
}

- (void)saveLastRefreshDate
{
    if (_tableViewName)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:_tableViewName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)updateLastRefreshDateLabel
{
    if (_lastRefreshDateLabel)
    {
        [_lastRefreshDateLabel setText:[self getLastRefreshDate]];
    }
    
}

-(void)setRefreshViewStatusWithScrollView:(UIScrollView *)scrollView
{
    if (scrollView==nil)
    {
        [_arrowImageView setHidden:YES];
        [_statueLabel setText:@"努力更新中..."];
        _refreshViewStatus=RefreshViewStatus_Loading;
    }
    else
    {
        CGFloat contentOffsetY=-scrollView.contentOffset.y;
        if (contentOffsetY>_refreshViewHeight)
        {
            if (RefreshViewStatus_ReleaseHandWillUpdate!=_refreshViewStatus)
            {
                [_arrowImageView setHidden:NO];
                [_statueLabel setText:@"释放立即更新"];
                _refreshViewStatus=RefreshViewStatus_ReleaseHandWillUpdate;
                __weak typeof(self) wself=self;
                [UIView animateWithDuration:0.2f
                                 animations:^{
                                     wself.arrowImageView.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                                     [wself updateConstraintsIfNeeded];
                                 }
                                 completion:^(BOOL finished){
                                 }];
            }
        }
        else if(RefreshViewStatus_DragDownToUpdate!=_refreshViewStatus)
        {
            [_arrowImageView setHidden:NO];
            [_statueLabel setText:@"下拉更新"];
            _refreshViewStatus=RefreshViewStatus_DragDownToUpdate;
            __weak typeof(self) wself=self;
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 wself.arrowImageView.layer.transform = CATransform3DIdentity;
                                 [wself updateConstraintsIfNeeded];
                             }
                             completion:^(BOOL finished){
                             }];
        }
    }
}

-(void)startRefreshWithScrollView:(UIScrollView *)scrollView
{
    CGPoint contentOffset=[scrollView contentOffset];
    if (contentOffset.y>0)
    {
        [scrollView setContentOffset:CGPointMake(contentOffset.x,0)];
    }
    __weak typeof(self) wself=self;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [scrollView setContentOffset:CGPointMake(contentOffset.x, -wself.refreshViewHeight)];
                         UIEdgeInsets currentInsets = scrollView.contentInset;
                         currentInsets.top = wself.refreshViewHeight;
                         scrollView.contentInset = currentInsets;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)stopRefreshWithScrollView:(UIScrollView *)scrollView
{
    __weak typeof(self) wself=self;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         UIEdgeInsets currentInsets = scrollView.contentInset;
                         currentInsets.top = 0;
                         scrollView.contentInset = currentInsets;
                     }completion:^(BOOL finished){
                         [wself stopLoading];
                         [wself setRefreshViewStatusWithScrollView:scrollView];
                     }];
}

-(void)isStartRefresh:(BOOL)isStart ifStopRefreshThenIsDestroy:(BOOL)isDestroy scrollView:(UIScrollView *)scrollView
{
    if (isStart)
    {
        [self startLoading];
        [self updateLastRefreshDateLabel];
        [self startRefreshWithScrollView:scrollView];
        [self setRefreshViewStatusWithScrollView:nil];
    }
    else if (isDestroy)
    {
        
        [self destroyLoading];
    }
    else
    {
        [self saveLastRefreshDate];
        [self updateLastRefreshDateLabel];
        if (_isLoading) {
            [self performSelector:@selector(stopRefreshWithScrollView:) withObject:scrollView afterDelay:0.5];
        }
        
    }
}

-(void)startLoading
{
    //NSLog(@"开始");
    _isLoading=YES;
    _loadingImageView.layer.transform = CATransform3DIdentity;
    [_loadingImageView setHidden:NO];
    [self startTimer];
}

-(void)stopLoading
{
    //NSLog(@"停止");
    [self stopTimerIsDestroy:NO];
    _loadingViewAngle=0.0f;
    _loadingImageView.layer.transform = CATransform3DIdentity;
    [_loadingImageView setHidden:YES];
    _isLoading=NO;
}

-(void)destroyLoading
{
    //NSLog(@"销毁");
    [self stopTimerIsDestroy:YES];
    [_loadingImageView setHidden:YES];
}

-(void)startTimer
{
    if (_loadingTimer==nil)
    {
        self.loadingTimer=[NSTimer  timerWithTimeInterval:0.02
                                                   target:self
                                                 selector:@selector(updateLoadingViewAngle)
                                                 userInfo:nil
                                                  repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_loadingTimer
                                     forMode:NSRunLoopCommonModes];
        [_loadingTimer fire];
    }
    else
    {
        [_loadingTimer setFireDate:[NSDate distantPast]];
    }
}

-(void)stopTimerIsDestroy:(BOOL)isDestroy
{
    if (_loadingTimer&&[_loadingTimer isValid])
    {
        if (isDestroy)
        {
            [_loadingTimer invalidate];
            self.loadingTimer=nil;
        }
        else
        {
            [_loadingTimer setFireDate:[NSDate distantFuture]];
        }
    }
}

-(void)updateLoadingViewAngle
{
    [_loadingImageView.layer setTransform:CATransform3DMakeRotation((M_PI / 180.0) * _loadingViewAngle, 0.0f, 0.0f, 1.0f)];
    _loadingViewAngle+=15.0f;
}
@end
