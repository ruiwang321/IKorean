//
//  BannerAdUnitView.m
//  ICinema
//
//  Created by wangyunlong on 16/8/8.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "BannerAdUnitView.h"
@interface BannerAdUnitView ()
<
AdViewDelegate
>

@property (nonatomic,assign) CGFloat adViewWidth;
@property (nonatomic,assign) CGFloat adViewHeight;
@property (nonatomic,strong) AdViewView * adView;
@property (nonatomic,strong) UIView * placeholderView;
@end

@implementation BannerAdUnitView

-(void)dealloc
{
    self.adView.delegate=nil;
    self.adView=nil;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        _adViewWidth=CGRectGetWidth(frame);
        _adViewHeight=CGRectGetHeight(frame);
        
        self.placeholderView=[[ICEAppHelper shareInstance]viewWithPlaceholderImageName:@"adPlaceholder@2x"
                                                                             viewWidth:_adViewWidth
                                                                            viewHeight:_adViewHeight
                                                                          cornerRadius:0];
        [self addSubview:_placeholderView];
        
        self.adView=[AdViewView requestAdViewViewWithAppKey:ADViewKey
                                               WithDelegate:self];
        [self addSubview:_adView];
    }
    return self;
}

- (void)adViewDidReceiveAd:(AdViewView *)adViewView
{
    CGSize actualAdSize=adViewView.actualAdSize;
    CGFloat widthOfAdSize=actualAdSize.width;
    CGFloat heightOfAdSize=actualAdSize.height;
    CGRect frameOfAdView=CGRectMake((_adViewWidth-widthOfAdSize)/2, (_adViewHeight-heightOfAdSize)/2, widthOfAdSize, heightOfAdSize);
    [_adView setFrame:frameOfAdView];
    [_placeholderView setHidden:YES];
}

-(void)setIsStopAutoRefresh:(BOOL)isStop
{
    if (isStop)
    {
        [_adView stopAutoRefresh];
    }
    else
    {
        [_adView startAutoRefresh];
    }
}

#pragma mark AdViewDelegateMethods
- (UIViewController*)viewControllerForPresentingModalView
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (BOOL)adViewLogMode
{
    return NO;
}
@end
