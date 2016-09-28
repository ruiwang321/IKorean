//
//  ICELoadingView.m
//  ICinema
//
//  Created by wangyunlong on 16/6/14.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICELoadingView.h"
@interface ICELoadingView ()
@property (nonatomic,assign) CGFloat loadingImageViewAngle;
@property (nonatomic,strong) UIImageView * loadingImageView;
@property (nonatomic,strong) NSTimer * timer;
@end

@implementation ICELoadingView
-(id)init
{
    if (self=[super init])
    {
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

-(void)startLoading
{
    if (_loadingImageView==nil)
    {
        UIImage * loadingImage=IMAGENAME((_loadingViewImageName?_loadingViewImageName:@"publicLoading@2x"), @"png");
        CGFloat loadingImageWidth=loadingImage.size.width;
        CGFloat loadingImageHeight=loadingImage.size.height;
        self.loadingImageView=[[UIImageView alloc] initWithImage:loadingImage];
        [_loadingImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_loadingImageView];
        
        NSLayoutConstraint * centerXConstraint=[NSLayoutConstraint constraintWithItem:_loadingImageView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1
                                                                             constant:0];
        
        NSLayoutConstraint * centerYConstraint=[NSLayoutConstraint constraintWithItem:_loadingImageView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1
                                                                             constant:0];
        
        NSLayoutConstraint * widthConstraint=[NSLayoutConstraint constraintWithItem:_loadingImageView
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1
                                                                           constant:loadingImageWidth];
        
        NSLayoutConstraint * heightConstraint=[NSLayoutConstraint constraintWithItem:_loadingImageView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:loadingImageHeight];
        
        [self addConstraints:@[centerXConstraint,centerYConstraint,widthConstraint,heightConstraint]];
    }
    [_loadingImageView.layer setTransform:CATransform3DIdentity];
    [self setHidden:NO];
    [self startTimer];
}

-(void)stopLoading
{
    [self setHidden:YES];
    [self stopTimerIsDestroy:NO];
    _loadingImageViewAngle=0;
    [_loadingImageView.layer setTransform:CATransform3DIdentity];
}

-(void)destroyLoading
{
    [self setHidden:YES];
    [self stopTimerIsDestroy:YES];
    _loadingImageViewAngle=0;
    [_loadingImageView.layer setTransform:CATransform3DIdentity];
}

-(void)startTimer
{
    if (_timer==nil)
    {
        self.timer=[NSTimer  timerWithTimeInterval:1/360.0f
                                            target:self
                                          selector:@selector(changeAngle)
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

-(void)changeAngle
{
    [_loadingImageView.layer setTransform:CATransform3DMakeRotation((M_PI / 180.0) * _loadingImageViewAngle, 0.0f, 0.0f, 1.0f)];
    _loadingImageViewAngle+=1;
}

@end
