//
//  ICEPlayerVolumeView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/8/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerVolumeView.h"
#define SystemVolumeDidChangeNotification         @"AVSystemController_SystemVolumeDidChangeNotification"
#define AudioVolumeNotificationParameter          @"AVSystemController_AudioVolumeNotificationParameter"
@interface ICEPlayerVolumeView ()
@property (nonatomic,strong) UIProgressView * volumeProgressView;
@property (nonatomic,strong) UISlider * systemVolumeSlider;
@property (nonatomic,assign) CGFloat volumeViewWidth;
@property (nonatomic,assign) CGFloat volumeViewHeight;
@end

@implementation ICEPlayerVolumeView

-(void)dealloc
{
    self.systemVolumeSlider=nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
}

-(UISlider *)getSystemVolumeSlider
{
    UISlider * volumeSlider=nil;
    
    MPVolumeView * volumeView = [[MPVolumeView alloc]init];
    volumeView.showsVolumeSlider=NO;
    [volumeView setHidden:YES];
    [self addSubview:volumeView];
    
    for (UIControl *view in volumeView.subviews)
    {
        if ([view.superclass isSubclassOfClass:[UISlider class]])
        {
            volumeSlider = (UISlider *)view;
            break;
        }
    }
    return volumeSlider;
}

-(id)initWithVolumeViewWidth:(CGFloat)volumeViewWidth volumeViewHeight:(CGFloat)volumeViewHeight
{
    if (self=[super init])
    {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setBackgroundColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewPublicColor];
        
        //获取系统音量
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:SystemVolumeDidChangeNotification
                                                   object:nil];
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        _volumeViewWidth=volumeViewWidth;
        _volumeViewHeight=volumeViewHeight;
        self.systemVolumeSlider=[self getSystemVolumeSlider];

        CGFloat volumeViewOrigHeight=120;
        CGFloat controlOrigPadding=9;
        CGFloat controlPadding=controlOrigPadding/volumeViewOrigHeight*_volumeViewHeight;
        
        //音量图片
        UIImage * volumeImage=IMAGENAME(@"playerVolume@2x", @"png");
        CGFloat volumeImageWidth=volumeImage.size.width;
        CGFloat volumeImageHeight=volumeImage.size.height;
        CGRect  volumeImageViewFrame=CGRectMake((_volumeViewWidth-volumeImageWidth)/2,
                                                _volumeViewHeight-volumeImageHeight-controlPadding,
                                                volumeImageWidth,
                                                volumeImageHeight);
        UIImageView * volumeImageView=[[UIImageView alloc] initWithFrame:volumeImageViewFrame];
        [volumeImageView setImage:volumeImage];
        [self addSubview:volumeImageView];
        
        //音量大小进度条
        CGFloat volumeProgressViewWidth=CGRectGetMinY(volumeImageViewFrame)-2*controlPadding;
        CGFloat volumeProgressViewHeight=3;
        CGRect  volumeProgressViewFrame=CGRectMake((_volumeViewWidth-volumeProgressViewWidth)/2,
                                                   controlPadding+volumeProgressViewWidth/2,
                                                   volumeProgressViewWidth,
                                                   volumeProgressViewHeight);
        self.volumeProgressView = [[UIProgressView alloc]initWithProgressViewStyle: UIProgressViewStyleBar];
        [_volumeProgressView setProgressTintColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewControlColor];
        [_volumeProgressView setTrackTintColor:[UIColor lightGrayColor]];
        [_volumeProgressView setProgress:0];;
        [_volumeProgressView setFrame:volumeProgressViewFrame];
        [_volumeProgressView setTransform:CGAffineTransformMakeRotation(M_PI/2 * 3)];
        [self addSubview:_volumeProgressView];
    }
    return self;
}

-(void)addToSuperViewAndaddConstraintsWithSuperView:(UIView *)superView
{
    [superView addSubview:self];
    
    CGFloat paddingToLeftScreen=10;
    
    NSLayoutConstraint * minXConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:superView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:paddingToLeftScreen];

    NSLayoutConstraint * centerYConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:superView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1
                                                                         constant:0];
    
    NSLayoutConstraint * widthConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:_volumeViewWidth];
    
    NSLayoutConstraint * heightConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:_volumeViewHeight];
    
    [superView addConstraints:@[minXConstraint,centerYConstraint,widthConstraint,heightConstraint]];
}

- (void)volumeChanged:(NSNotification *)notification
{
    [self setHidden:NO];
    float volume = [[[notification userInfo]objectForKey:AudioVolumeNotificationParameter] floatValue];
    _volumeProgressView.progress=volume;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideVolumeView) object:nil];
    [self performSelector:@selector(hideVolumeView) withObject:nil afterDelay:1];
}

-(void)setVolume:(float)volume
{
    _systemVolumeSlider.value=volume;
}

-(float)getVolume
{
    return _systemVolumeSlider.value;
}

-(void)hideVolumeView
{
    [self setHidden:YES];
}
@end
