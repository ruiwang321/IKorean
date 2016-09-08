//
//  ICELoadingView.m
//  ICinema
//
//  Created by wangyunlong on 16/6/14.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICELoadingView.h"
@interface ICELoadingView ()
{
    CGFloat  m_widthOfLoadingView;
    CGFloat  m_heightOfLoadingView;
    UIView * m_maskView;
    UIImageView * m_loadingImageView;
    CGFloat m_angleOfLoadingView;
}
@property (nonatomic,strong) NSTimer * timer;
@end

@implementation ICELoadingView
-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        m_widthOfLoadingView=CGRectGetWidth(frame);
        m_heightOfLoadingView=CGRectGetHeight(frame);
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

-(void)startLoading
{
    if (m_maskView==nil)
    {
        UIImage * imageOfLoading=IMAGENAME(@"cut_loading_blue@2x", @"png");
        CGFloat widthOfImage=imageOfLoading.size.width;
        CGFloat heightOfImage=imageOfLoading.size.height;
        
        CGFloat widthOfMaskView=widthOfImage+20;
        CGFloat heightOfMaskView=heightOfImage+20;
        CGRect  frameOfMaskView=CGRectMake((m_widthOfLoadingView-widthOfMaskView)/2, (m_heightOfLoadingView-heightOfMaskView)/2, widthOfMaskView, heightOfMaskView);
        m_maskView=[[UIView alloc] initWithFrame:frameOfMaskView];
        m_maskView.backgroundColor=[UIColor blackColor];
        m_maskView.alpha=0.5;
        m_maskView .layer.cornerRadius=8;
        m_maskView.layer.masksToBounds=YES;
        [self addSubview:m_maskView];
        
        CGRect  frameOfLoadingView=CGRectMake((m_widthOfLoadingView-widthOfImage)/2, (m_heightOfLoadingView-heightOfImage)/2, widthOfImage, heightOfImage);
        m_loadingImageView=[[UIImageView alloc] initWithFrame:frameOfLoadingView];
        [m_loadingImageView setImage:imageOfLoading];
        [self addSubview:m_loadingImageView];
    }
    m_loadingImageView.layer.transform = CATransform3DIdentity;
    [self setHidden:NO];
    [self startTimer];
}

-(void)stopLoading
{
    [self setHidden:YES];
    [self stopTimerIsDestroy:NO];
    m_angleOfLoadingView=0.0f;
    m_loadingImageView.layer.transform = CATransform3DIdentity;
}

-(void)destroyLoading
{
    [self setHidden:YES];
    [self stopTimerIsDestroy:YES];
    m_angleOfLoadingView=0.0f;
    m_loadingImageView.layer.transform = CATransform3DIdentity;
}

-(void)startTimer
{
    if (_timer==nil)
    {
        self.timer=[NSTimer  timerWithTimeInterval:0.02
                                            target:self
                                          selector:@selector(updateLoadingViewAngle)
                                          userInfo:nil
                                           repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer
                                     forMode:NSRunLoopCommonModes];
        [_timer fire];
    }
    else
    {
        [_timer setFireDate:[NSDate distantPast]];
    }
}

-(void)stopTimerIsDestroy:(BOOL)isDestroy
{
    if (_timer&&[_timer isValid])
    {
        if (isDestroy)
        {
            [_timer invalidate];
            self.timer=nil;
        }
        else
        {
            [_timer setFireDate:[NSDate distantFuture]];
        }
    }
}

-(void)updateLoadingViewAngle
{
    [m_loadingImageView.layer setTransform:CATransform3DMakeRotation((M_PI / 180.0) * m_angleOfLoadingView, 0.0f, 0.0f, 1.0f)];
    m_angleOfLoadingView+=15.0f;
}

@end
