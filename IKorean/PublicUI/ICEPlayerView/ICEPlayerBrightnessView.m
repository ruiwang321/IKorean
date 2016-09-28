//
//  ICEPlayerBrightnessView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/8/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerBrightnessView.h"

@interface ICEPlayerBrightnessView ()
@property (nonatomic,strong) UIProgressView * brightnessProgressView;
@property (nonatomic,assign) CGFloat brightnessViewWidth;
@property (nonatomic,assign) CGFloat brightnessViewHeight;
@end

@implementation ICEPlayerBrightnessView

-(id)initWithBrightnessViewWidth:(CGFloat)brightnessViewWidth brightnessViewHeight:(CGFloat)brightnessViewHeight
{
    if (self=[super init])
    {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setBackgroundColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewPublicColor];
        
        _brightnessViewWidth=brightnessViewWidth;
        _brightnessViewHeight=brightnessViewHeight;
        
        CGFloat brightnessViewOrigHeight=120;
        CGFloat controlOrigPadding=9;
        CGFloat controlPadding=controlOrigPadding/brightnessViewOrigHeight*_brightnessViewHeight;
        
        //亮度图片
        UIImage * brightnessImage=IMAGENAME(@"playerBrightness@2x", @"png");
        CGFloat brightnessImageWidth=brightnessImage.size.width;
        CGFloat brightnessImageHeight=brightnessImage.size.height;
        CGRect  brightnessImageViewFrame=CGRectMake((_brightnessViewWidth-brightnessImageWidth)/2,
                                                    _brightnessViewHeight-brightnessImageHeight-controlPadding,
                                                    brightnessImageWidth,
                                                    brightnessImageHeight);
                                                    
        UIImageView * brightnessImageView=[[UIImageView alloc] initWithFrame:brightnessImageViewFrame];
        [brightnessImageView setImage:brightnessImage];
        [self addSubview:brightnessImageView];
        
        //亮度进度条
        CGFloat brightnessProgressViewWidth=CGRectGetMinY(brightnessImageViewFrame)-2*controlPadding;
        CGFloat brightnessProgressViewHeight=3;
        CGRect  brightnessProgressViewFrame=CGRectMake((_brightnessViewWidth-brightnessProgressViewWidth)/2,
                                                       controlPadding+brightnessProgressViewWidth/2,
                                                       brightnessProgressViewWidth,
                                                       brightnessProgressViewHeight);
        self.brightnessProgressView = [[UIProgressView alloc]initWithProgressViewStyle: UIProgressViewStyleBar];
        [_brightnessProgressView setProgressTintColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewControlColor];
        [_brightnessProgressView setTrackTintColor:[UIColor lightGrayColor]];
        [_brightnessProgressView setProgress:0];;
        [_brightnessProgressView setFrame:brightnessProgressViewFrame];
        [_brightnessProgressView setTransform:CGAffineTransformMakeRotation(M_PI/2 * 3)];
        [self addSubview:_brightnessProgressView];
    }
    return self;
}

-(void)addToSuperViewAndaddConstraintsWithSuperView:(UIView *)superView
{
    [superView addSubview:self];
    
    CGFloat paddingToRightScreen=10;
    
    NSLayoutConstraint * minXConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:superView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:-paddingToRightScreen];
    
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
                                                                       constant:_brightnessViewWidth];
    
    NSLayoutConstraint * heightConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:_brightnessViewHeight];
    
    [superView addConstraints:@[minXConstraint,centerYConstraint,widthConstraint,heightConstraint]];
}

-(void)setBrightness:(float)brightness
{
    [self setHidden:NO];
    [[UIScreen mainScreen] setBrightness:brightness];
    _brightnessProgressView.progress=[UIScreen mainScreen].brightness;
}

-(float)getBrightness
{
    return [UIScreen mainScreen].brightness;
}
@end
