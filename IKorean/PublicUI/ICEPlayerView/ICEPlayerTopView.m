//
//  ICEPlayerTopView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerTopView.h"
@interface ICEPlayerTopView ()

@property (nonatomic,assign) CGRect topViewVFrame;
@property (nonatomic,assign) CGRect topViewHFrame;
@property (nonatomic,strong) UIView * topViewVBackGround;
@property (nonatomic,strong) UIView * topViewHBackGround;
@property (nonatomic,strong) UILabel * vTitlabel;
@property (nonatomic,strong) ICECyclicRollingTextView * hTitleView;
@property (nonatomic,strong) ICEButton * selectEpisodeButton;
@property (nonatomic,strong) ICEButton * collectButton;
@property (nonatomic,strong) ICEButton * lockScreenButton;
@property (nonatomic,assign) BOOL isWillHide;
@end

@implementation ICEPlayerTopView
-(void)dealloc
{
    [_hTitleView stopRollingWithIsDestroy:YES];
}

-(id)initWithTopViewVFrame:(CGRect)vFrame
                    HFrame:(CGRect)hFrame
{
    if (self=[super initWithFrame:vFrame])
    {
        _isWillHide=NO;
        _topViewVFrame=vFrame;
        _topViewHFrame=hFrame;
        
        [self addTopViewVBackGround];
        [self addTopViewHBackGround];
    }
    return self;
}

-(void)addTopViewVBackGround
{
    if (_topViewVBackGround==nil)
    {
        //竖屏时的顶部栏的背景
        CGRect topViewVBackGroundFrame=_topViewVFrame;
        topViewVBackGroundFrame.origin=CGPointZero;
        self.topViewVBackGround=[[UIView alloc] initWithFrame:topViewVBackGroundFrame];
        [self addSubview:_topViewVBackGround];
        
        //渐变效果
        CAGradientLayer * gradientLayer = [CAGradientLayer layer];
        [gradientLayer setFrame:_topViewVBackGround.bounds];
        [gradientLayer setColors:@[(id)[[[UIColor blackColor]colorWithAlphaComponent:0.8] CGColor],
                                   (id)[[UIColor clearColor] CGColor]]];
        [_topViewVBackGround.layer insertSublayer:gradientLayer atIndex:0];
        
        //竖屏时的标题label
        CGRect vTitleLabelFrame=CGRectMake(45, 0, CGRectGetWidth(topViewVBackGroundFrame)-45-10, CGRectGetHeight(topViewVBackGroundFrame));
        self.vTitlabel=[[UILabel alloc] initWithFrame:vTitleLabelFrame];
        [_vTitlabel setTextAlignment:NSTextAlignmentLeft];
        [_vTitlabel setTextColor:[UIColor whiteColor]];
        [_vTitlabel setText:@""];
        [_vTitlabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:16]];
        [_topViewVBackGround addSubview:_vTitlabel];
    }
}

-(void)addTopViewHBackGround
{
    if (_topViewHBackGround==nil)
    {
        CGFloat topViewHWidth=CGRectGetWidth(_topViewHFrame);
        CGFloat topViewHHeight=CGRectGetHeight(_topViewHFrame);
        CGFloat hControlTopBaseLineY=20;
        CGFloat hControlMaxHeight=topViewHHeight-hControlTopBaseLineY;
        
        //横屏时的顶部栏背景
        CGRect  topViewHBackGroundFrame=_topViewHFrame;
        topViewHBackGroundFrame.origin=CGPointZero;
        self.topViewHBackGround=[[UIView alloc] initWithFrame:topViewHBackGroundFrame];
        [_topViewHBackGround setBackgroundColor:[UIColor colorWithRed:10.0f/255.0f green:10.0f/255.0f blue:10.0f/255.0f alpha:0.9]];
        [self addSubview:_topViewHBackGround];
        [_topViewHBackGround setHidden:YES];
        
        //切换到小屏的按钮
        CGRect switchVSizeButtonFrame=CGRectMake(0, hControlTopBaseLineY, 42, hControlMaxHeight);
        ICEButton * switchVSizeButton = [ICEButton buttonWithType:UIButtonTypeCustom];
        [switchVSizeButton setFrame:switchVSizeButtonFrame];
        [switchVSizeButton setImage:IMAGENAME(@"playerTopViewSmallScreen@2x", @"png") forState:UIControlStateNormal];
        [switchVSizeButton addTarget:self action:@selector(goSwitchToVSize) forControlEvents:UIControlEventTouchUpInside];
        [_topViewHBackGround addSubview:switchVSizeButton];
        
        //分割线
        CGFloat dividingLineWidth=1;
        CGFloat dividingLineHeight=18;
        CGRect  dividingLine1Frame=CGRectMake(CGRectGetMaxX(switchVSizeButtonFrame),
                                              hControlTopBaseLineY+(hControlMaxHeight-dividingLineHeight)/2,
                                              dividingLineWidth,
                                              dividingLineHeight);
        UIView * dividingLine1=[[UIView alloc] initWithFrame:dividingLine1Frame];
        [dividingLine1 setBackgroundColor:[UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:0.8]];
        [_topViewHBackGround addSubview:dividingLine1];
        
        //选集按钮
        CGFloat hButtonWidth=55;
        CGRect  selectEpisodeButtonFrame=CGRectMake(topViewHWidth-hButtonWidth, hControlTopBaseLineY, hButtonWidth, hControlMaxHeight);
        self.selectEpisodeButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [_selectEpisodeButton setFrame:selectEpisodeButtonFrame];
        [_selectEpisodeButton setTitle:@"选集" forState:UIControlStateNormal];
        [_selectEpisodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectEpisodeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [_selectEpisodeButton.titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:16]];
        [_selectEpisodeButton addTarget:self action:@selector(goSelectEpisode) forControlEvents:UIControlEventTouchUpInside];
        [_topViewHBackGround addSubview:_selectEpisodeButton];
        
        //分割线
        CGRect  dividingLine2Frame=dividingLine1Frame;
        dividingLine2Frame.origin.x=CGRectGetMinX(selectEpisodeButtonFrame)-dividingLineWidth;
        UIView * dividingLine2=[[UIView alloc] initWithFrame:dividingLine2Frame];
        [dividingLine2 setBackgroundColor:dividingLine1.backgroundColor];
        [_topViewHBackGround addSubview:dividingLine2];
        
        //收藏按钮
        CGRect  collectButtonFrame=selectEpisodeButtonFrame;
        collectButtonFrame.origin.x=CGRectGetMinX(dividingLine2Frame)-hButtonWidth;
        self.collectButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [_collectButton setFrame:collectButtonFrame];
        [_collectButton addTarget:self action:@selector(goCollect) forControlEvents:UIControlEventTouchUpInside];
        [_collectButton setNormalImage:IMAGENAME(@"playerNoSave@2x", @"png") highlightedImage:IMAGENAME(@"playerSave@2x", @"png")];
        [_topViewHBackGround addSubview:_collectButton];
        
        //分割线
        CGRect  dividingLine3Frame=dividingLine1Frame;
        dividingLine3Frame.origin.x=CGRectGetMinX(collectButtonFrame)-dividingLineWidth;
        UIView * dividingLine3=[[UIView alloc] initWithFrame:dividingLine3Frame];
        [dividingLine3 setBackgroundColor:dividingLine1.backgroundColor];
        [_topViewHBackGround addSubview:dividingLine3];
        
        //锁屏按钮
        CGRect  lockScreenButtonFrame=selectEpisodeButtonFrame;
        lockScreenButtonFrame.origin.x=CGRectGetMinX(dividingLine3Frame)-hButtonWidth;
        self.lockScreenButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [_lockScreenButton setFrame:lockScreenButtonFrame];
        [_lockScreenButton addTarget:self action:@selector(goLockScreen) forControlEvents:UIControlEventTouchUpInside];
        [_lockScreenButton setNormalImage:IMAGENAME(@"playerUnLockScreen@2x", @"png") highlightedImage:IMAGENAME(@"playerLockScreen@2x", @"png")];
        [_topViewHBackGround addSubview:_lockScreenButton];
        
        //横屏时的标题
        CGFloat hTitleViewMinX=CGRectGetMaxX(dividingLine1Frame)+5;
        CGFloat hTitleViewWidth=CGRectGetMinX(lockScreenButtonFrame)-5-hTitleViewMinX;
        CGRect  hTitleViewFrame=CGRectMake(hTitleViewMinX, hControlTopBaseLineY, hTitleViewWidth, hControlMaxHeight);
        self.hTitleView=[[ICECyclicRollingTextView alloc] initWithFrame:hTitleViewFrame
                                                                   font:_selectEpisodeButton.titleLabel.font
                                                              textColor:[UIColor whiteColor]
                                                              alignment:NSTextAlignmentLeft
                                                     repeatTimeInterval:0.04];
        [_topViewHBackGround addSubview:_hTitleView];
    }
}

-(BOOL)isHorizontalStyle
{
    return CGRectEqualToRect(self.frame, _topViewHFrame);
}

-(void)setTopViewStyle:(ICEPlayerTopViewStyle)topViewStyle
{
    if (ICEPlayerTopViewHorizontalStyle==topViewStyle)
    {
        [self setFrame:_topViewHFrame];
        [_topViewVBackGround setHidden:YES];
        [_topViewHBackGround setHidden:NO];
        if (!_isWillHide) {
            [_hTitleView startRolling];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:_isWillHide withAnimation:UIStatusBarAnimationNone];
    }
    else if(ICEPlayerTopViewVerticalStyle==topViewStyle)
    {
        [self setFrame:_topViewVFrame];
        [_topViewVBackGround setHidden:NO];
        [_topViewHBackGround setHidden:YES];
        [_hTitleView stopRollingWithIsDestroy:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}

-(void)setHidden:(BOOL)hidden
{
    _isWillHide=hidden;
    if ([self isHorizontalStyle])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
        if (hidden)
        {
            [_hTitleView stopRollingWithIsDestroy:NO];
        }
        else
        {
            [_hTitleView startRolling];
        }
    }
    if (hidden)
    {
        [self setAlpha:1];
        [UIView animateWithDuration:0.25 animations:^{
            [self setAlpha:0];
        }completion:^(BOOL finished){
            [super setHidden:YES];
        }];
    }
    else
    {
        [super setHidden:NO];
        [self setAlpha:0];
        [UIView animateWithDuration:0.25 animations:^{
            [self setAlpha:1];
        }completion:^(BOOL finished){
            [self setAlpha:1];
        }];
    }
}

-(void)setTitle:(NSString*)title
{
    [_vTitlabel setText:title];
    [_hTitleView setText:title];
    if (![self isHorizontalStyle]||_isWillHide||_topViewHBackGround.isHidden) {
        [_hTitleView stopRollingWithIsDestroy:NO];
    }
}

-(void)setIsLockScreen:(BOOL)isLockScreen
{
    [_lockScreenButton setIsHighlighted:isLockScreen];
}

-(void)setIsCollected:(BOOL)isCollected
{
    [_collectButton setIsHighlighted:isCollected];
}

-(void)setIsCanSelectEpisode:(BOOL)isCanSelectEpisode
{
    [_selectEpisodeButton setEnabled:isCanSelectEpisode];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
}

-(void)executeControlEventBlockWithControlEvent:(ICEPlayerTopViewControlEvents)controlEvent
{
    if (_controlEventBlock)
    {
        _controlEventBlock(controlEvent);
    }
}

-(void)goSwitchToVSize
{
    [self executeControlEventBlockWithControlEvent:ICEPlayerTopViewSwitchToVSizeEvent];
}

-(void)goLockScreen
{
    [self executeControlEventBlockWithControlEvent:ICEPlayerTopViewLockScreenEvent];
}

-(void)goCollect
{
    [self executeControlEventBlockWithControlEvent:ICEPlayerTopViewCollectEvent];
}

-(void)goSelectEpisode
{
    [self executeControlEventBlockWithControlEvent:ICEPlayerTopViewSelectEpisodeEvent];
}

@end
