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
        [self setBackgroundColor:[UIColor colorWithRed:10.0f/255.0f green:10.0f/255.0f blue:10.0f/255.0f alpha:0.9]];
        
        _brightnessViewWidth=brightnessViewWidth;
        _brightnessViewHeight=brightnessViewHeight;
        
        CGFloat controlPadding=10;
        
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
        _brightnessProgressView.progressTintColor=PlayerControlColor;
        _brightnessProgressView.trackTintColor=[UIColor lightGrayColor];
        _brightnessProgressView.progress=0;
        _brightnessProgressView.frame=brightnessProgressViewFrame;
        _brightnessProgressView.transform = CGAffineTransformMakeRotation(M_PI/2 * 3);
        [self addSubview:_brightnessProgressView];
        
        [self setHidden:YES];
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
    if (brightness<0)
    {
        brightness=0;
    }
    else if(brightness>1)
    {
        brightness=1;
    }
    [self setHidden:NO];
    _brightnessProgressView.progress=brightness;
    [[UIScreen mainScreen] setBrightness:brightness];
}

-(float)brightness
{
    return [UIScreen mainScreen].brightness;
}
@end
