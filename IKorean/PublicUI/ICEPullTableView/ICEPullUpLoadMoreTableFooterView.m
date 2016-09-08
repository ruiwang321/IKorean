//
//  ICEPullUpLoadMoreTableFooterView.m
//  GameCircle
//
//  Created by wangyunlong on 15/8/4.
//  Copyright (c) 2015年 wangyunlong. All rights reserved.
//

#import "ICEPullUpLoadMoreTableFooterView.h"
@interface ICEPullUpLoadMoreTableFooterView ()

@property (nonatomic,assign,readwrite) BOOL isLoading;
@property (nonatomic,assign) CGFloat   loadMoreViewWidth;
@property (nonatomic,assign) CGFloat   loadMoreViewHeight;
@property (nonatomic,strong) UILabel * statueLabel;
@property (nonatomic,strong) UIImageView * loadingImageView;
@property (nonatomic,strong) NSTimer * loadingTimer;
@property (nonatomic,assign) CGFloat loadingViewAngle;
@end

@implementation ICEPullUpLoadMoreTableFooterView

-(void)dealloc
{
    [self destroyLoading];
}

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        _isLoading=NO;
        _loadMoreViewWidth=CGRectGetWidth(frame);
        _loadMoreViewHeight=CGRectGetHeight(frame);
        _loadingViewAngle=0.0f;
        
        //状态label
        CGFloat statusLabelWidth=110;
        CGFloat statusLabelHeight=16;
        CGRect  statusLabelFrame=CGRectMake((_loadMoreViewWidth-statusLabelWidth)/2,
                                            (_loadMoreViewHeight-statusLabelHeight)/2,
                                            statusLabelWidth,
                                            statusLabelHeight);
        self.statueLabel=[[UILabel alloc] initWithFrame:statusLabelFrame];
        [_statueLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:14]];
        [_statueLabel setText:@"加载中...."];
        [_statueLabel setTextAlignment:NSTextAlignmentCenter];
        [_statueLabel setTextColor:[UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1.0f]];
        [self addSubview:_statueLabel];
        
        //loadingView
        UIImage * loadingImage=IMAGENAME(@"cut_loading_gery@2x", @"png");;
        CGFloat loadingImageWidth=loadingImage.size.width;
        CGFloat loadingImageHeight=loadingImage.size.height;
        CGRect  loadingImageFrame=CGRectMake(CGRectGetMinX(statusLabelFrame)-5-loadingImageWidth,
                                             (_loadMoreViewHeight-loadingImageHeight)/2,
                                             loadingImageWidth,
                                             loadingImageHeight);
        
        self.loadingImageView=[[UIImageView alloc] initWithFrame:loadingImageFrame];
        [_loadingImageView setImage:loadingImage];
        [self addSubview:_loadingImageView];
        [_loadingImageView setHidden:YES];
    }
    return self;
}

-(void)startLoading
{
    _isLoading=YES;
    _loadingImageView.layer.transform = CATransform3DIdentity;
    [_loadingImageView setHidden:NO];
    [self startTimer];
}

-(void)stopLoading
{
    [self stopTimerIsDestroy:NO];
    _loadingViewAngle=0.0f;
    [_loadingImageView setHidden:YES];
    _loadingImageView.layer.transform = CATransform3DIdentity;
    _isLoading=NO;
}

-(void)destroyLoading
{
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

-(void)isStartLoadMore:(BOOL)isStart ifStopLoadMoreThenIsDestroy:(BOOL)isDestroy currentStatus:(NSString *)status
{
    [_statueLabel setText:status];
    if (isStart)
    {
        [self startLoading];
    }
    else
    {
        if (isDestroy)
        {
            [self destroyLoading];
        }
        else
        {
            [self stopLoading];
        }
    }
    
}
@end
