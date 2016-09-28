//
//  ICEPlayerReadToPlayView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/5.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerReadToPlayView.h"
#import "ICELoadingView.h"

#define keyOfAdjustVolume         @"isLearnedAdjustVolume"
#define keyOfAdjustBrightness     @"isLearnedAdjustBrightness"
#define keyOfAdjustProgress       @"isLearnedAdjustProgress"

typedef NS_ENUM(NSInteger, ICEDirectiveViewStyle) {
    ICEDirectiveViewVerticalStyle,
    ICEDirectiveViewHorizontalStyle
};

@interface ICEDirectiveView:UIView

@property (nonatomic,assign)CGRect directiveViewVFrame;
@property (nonatomic,assign)CGRect directiveViewHFrame;

@property (nonatomic,strong)UIImageView * volumeDirectiveImageView;
@property (nonatomic,assign)CGFloat volumeDirectiveImageViewVMinX;
@property (nonatomic,assign)CGFloat volumeDirectiveImageViewHMinX;

@property (nonatomic,strong)UIImageView * progressDirectiveImageView;

@property (nonatomic,strong)UIImageView * brightnessDirectiveImageView;
@property (nonatomic,assign)CGFloat brightnessDirectiveImageViewVMinX;
@property (nonatomic,assign)CGFloat brightnessDirectiveImageViewHMinX;

@end

@implementation ICEDirectiveView

-(id)initWithVFrame:(CGRect)vFrame
             HFrame:(CGRect)hFrame
        OrigVHeight:(CGFloat)directiveViewOrigVHeight
{
    if (self=[super initWithFrame:vFrame])
    {
        _directiveViewVFrame=vFrame;
        _directiveViewHFrame=hFrame;
        
        CGFloat directiveViewVWidth=CGRectGetWidth(vFrame);
        CGFloat directiveViewVHeight=CGRectGetHeight(vFrame);
        
        CGFloat directiveViewOrigVWidth=375;
        CGFloat directiveImageOrigVPaddingToLeft=10;
        CGFloat directiveImageOrigVPaddingToBottom=12;
        CGFloat directiveImageVPaddingToLeft=directiveImageOrigVPaddingToLeft/directiveViewOrigVWidth*directiveViewVWidth;
        CGFloat directiveImageVPaddingToBottom=directiveImageOrigVPaddingToBottom/directiveViewOrigVHeight*directiveViewVHeight;
        
        CGFloat directiveViewHWidth=CGRectGetWidth(hFrame);
        CGFloat directiveViewOrigHWidth=667;
        CGFloat directiveImageOrigHPaddingToLeft=39;
        CGFloat directiveImageHPaddingToLeft=directiveImageOrigHPaddingToLeft/directiveViewOrigHWidth*directiveViewHWidth;
        
        //音量引导图片
        UIImage * volumeDirectiveImage=IMAGENAME(@"playerVolumeDirective@2x", @"png");
        CGFloat volumeDirectiveImageHeight=directiveViewVHeight-directiveImageVPaddingToBottom;
        CGFloat volumeDirectiveImageWidth=volumeDirectiveImage.size.width/volumeDirectiveImage.size.height*volumeDirectiveImageHeight;

        _volumeDirectiveImageViewVMinX=directiveImageVPaddingToLeft;
        _volumeDirectiveImageViewHMinX=directiveImageHPaddingToLeft;
        CGRect  volumeDirectiveImageViewVFrame=CGRectMake(_volumeDirectiveImageViewVMinX,
                                                          0,
                                                          volumeDirectiveImageWidth,
                                                          volumeDirectiveImageHeight);
        self.volumeDirectiveImageView=[[UIImageView alloc] initWithFrame:volumeDirectiveImageViewVFrame];
        [_volumeDirectiveImageView setImage:volumeDirectiveImage];
        [self addSubview:_volumeDirectiveImageView];
        
        //进度引导图片
        UIImage * progressDirectiveImage=IMAGENAME(@"playerProgressDirective@2x", @"png");
        CGFloat progressDirectiveImageHeight=progressDirectiveImage.size.height/volumeDirectiveImage.size.height*volumeDirectiveImageHeight;
        CGFloat progressDirectiveImageWidth=progressDirectiveImage.size.width/progressDirectiveImage.size.height*progressDirectiveImageHeight;
        CGRect  progressDirectiveImageViewFrame=CGRectMake((directiveViewHWidth-progressDirectiveImageWidth)/2,
                                                           volumeDirectiveImageHeight-progressDirectiveImageHeight,
                                                           progressDirectiveImageWidth,
                                                           progressDirectiveImageHeight);
        self.progressDirectiveImageView=[[UIImageView alloc] initWithFrame:progressDirectiveImageViewFrame];
        [_progressDirectiveImageView setImage:progressDirectiveImage];
        [self addSubview:_progressDirectiveImageView];
        [_progressDirectiveImageView setHidden:YES];
        
        //亮度引导图片
        UIImage * brightnessDirectiveImage=IMAGENAME(@"playerBrightnessDirective@2x", @"png");
        CGFloat brightnessDirectiveImageHeight=volumeDirectiveImageHeight;
        CGFloat brightnessDirectiveImageWidth=brightnessDirectiveImage.size.width/brightnessDirectiveImage.size.height*brightnessDirectiveImageHeight;

        _brightnessDirectiveImageViewVMinX=directiveViewVWidth-_volumeDirectiveImageViewVMinX-brightnessDirectiveImageWidth;
        _brightnessDirectiveImageViewHMinX=directiveViewHWidth-_volumeDirectiveImageViewHMinX-brightnessDirectiveImageWidth;
        CGRect  brightnessDirectiveImageViewFrame=CGRectMake(_brightnessDirectiveImageViewVMinX,
                                                             0,
                                                             brightnessDirectiveImageWidth,
                                                             brightnessDirectiveImageHeight);
        self.brightnessDirectiveImageView=[[UIImageView alloc] initWithFrame:brightnessDirectiveImageViewFrame];
        [_brightnessDirectiveImageView setImage:brightnessDirectiveImage];
        [self addSubview:_brightnessDirectiveImageView];
    }
    return self;
}

-(void)setDirectiveViewStyle:(ICEDirectiveViewStyle)directiveViewStyle
{
    CGRect volumeDirectiveImageViewFrame=_volumeDirectiveImageView.frame;
    CGRect brightnessDirectiveImageViewFrame=_brightnessDirectiveImageView.frame;
    if (ICEDirectiveViewHorizontalStyle==directiveViewStyle)
    {
        [self setFrame:_directiveViewHFrame];
        volumeDirectiveImageViewFrame.origin.x=_volumeDirectiveImageViewHMinX;
        brightnessDirectiveImageViewFrame.origin.x=_brightnessDirectiveImageViewHMinX;
        [_progressDirectiveImageView setHidden:NO];
    }
    else
    {
        [self setFrame:_directiveViewVFrame];
        volumeDirectiveImageViewFrame.origin.x=_volumeDirectiveImageViewVMinX;
        brightnessDirectiveImageViewFrame.origin.x=_brightnessDirectiveImageViewVMinX;
        [_progressDirectiveImageView setHidden:YES];
    }
    [_volumeDirectiveImageView setFrame:volumeDirectiveImageViewFrame];
    [_brightnessDirectiveImageView setFrame:brightnessDirectiveImageViewFrame];
}

@end

@interface ICEPlayerReadToPlayView ()

@property (nonatomic,assign)CGRect readToPlayViewVFrame;
@property (nonatomic,assign)CGRect readToPlayViewHFrame;

@property (nonatomic,strong)ICEDirectiveView * directiveView;

@property (nonatomic,strong)ICELoadingView * loadingView;
@property (nonatomic,assign)CGPoint loadingViewVOrigin;
@property (nonatomic,assign)CGPoint loadingViewHOrigin;

@property (nonatomic,strong)UILabel * appNameLabel;
@property (nonatomic,assign)CGRect appNameLabelVFrame;
@property (nonatomic,assign)CGRect appNameLabelHFrame;

@property (nonatomic,strong)UILabel * titleLabel;
@property (nonatomic,assign)CGRect titleLabelVFrame;
@property (nonatomic,assign)CGRect titleLabelHFrame;

@property (nonatomic,strong)ICEButton * switchVSizeButton;
@property (nonatomic,assign)BOOL isLearnedAll;

@end

@implementation ICEPlayerReadToPlayView
-(void)dealloc
{
    [_loadingView destroyLoading];
}

-(BOOL)isHaveLearnedAll
{
    NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
    BOOL isLearnedAdjustVolume=[[userDefaults objectForKey:keyOfAdjustVolume] boolValue];
    BOOL isLearnedAdjustProgress=[[userDefaults objectForKey:keyOfAdjustProgress] boolValue];
    BOOL isLearnedAdjustBrightness=[[userDefaults objectForKey:keyOfAdjustBrightness] boolValue];
    return isLearnedAdjustVolume&&isLearnedAdjustProgress&&isLearnedAdjustBrightness;
}

-(void)haveLearnedAdjust:(ICEDirectiveType)directiveType
{
    if (_isLearnedAll)
    {
        return;
    }
    NSString * key=nil;
    switch (directiveType) {
        case ICEDirectiveForAdjustVolume:
            key=keyOfAdjustVolume;
            break;
        case ICEDirectiveForAdjustProgress:
            key=keyOfAdjustProgress;
            break;
        case ICEDirectiveForAdjustBrightness:
            key=keyOfAdjustBrightness;
            break;
        default:
            break;
    }
    NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSNumber numberWithBool:YES] forKey:key];
    [userDefaults synchronize];
    _isLearnedAll=[self isHaveLearnedAll];
}

-(id)initWithVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame
{
    if (self=[super initWithFrame:vFrame])
    {
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor blackColor]];
        
        _isLearnedAll=[self isHaveLearnedAll];
        _readToPlayViewVFrame=vFrame;
        _readToPlayViewHFrame=hFrame;
        
        //竖屏数据
        CGFloat readToPlayViewVWidth=CGRectGetWidth(vFrame);
        CGFloat readToPlayViewVHeight=CGRectGetHeight(vFrame);
        CGFloat readToPlayViewOrigVHeight=210;
        CGFloat directiveViewOrigVHeight=109;
        CGFloat loadingViewOrigVPaddingToBottom=66;
        CGFloat titleLableOrigVPaddingToDirectiveImage=10;
        CGFloat appNameLabelOrigVPaddingToTitleLable=15;
        CGFloat directiveViewVHeight=directiveViewOrigVHeight/readToPlayViewOrigVHeight*readToPlayViewVHeight;
        CGFloat loadingViewVPaddingToBottom=loadingViewOrigVPaddingToBottom/readToPlayViewOrigVHeight*readToPlayViewVHeight;
        CGFloat titleLableVPaddingToDirectiveImage=titleLableOrigVPaddingToDirectiveImage/readToPlayViewOrigVHeight*readToPlayViewVHeight;
        CGFloat appNameLabelVPaddingToTitleLable=appNameLabelOrigVPaddingToTitleLable/readToPlayViewOrigVHeight*readToPlayViewVHeight;
        
        //横屏数据
        CGFloat readToPlayViewHWidth=CGRectGetWidth(hFrame);
        CGFloat readToPlayViewHHeight=CGRectGetHeight(hFrame);
        CGFloat readToPlayViewOrigHHeight=375;
        CGFloat directiveViewOrigHHeight=130;
        CGFloat loadingViewOrigHPaddingToBottom=160;
        CGFloat titleLableOrigHPaddingTolLoadingView=20;
        CGFloat appNameLabelOrigHPaddingToTitleLable=30;
        CGFloat directiveViewHHeight=directiveViewOrigHHeight/readToPlayViewOrigHHeight*readToPlayViewHHeight;
        CGFloat loadingViewHPaddingToBottom=loadingViewOrigHPaddingToBottom/readToPlayViewOrigHHeight*readToPlayViewHHeight;
        CGFloat titleLableHPaddingTolLoadingView=titleLableOrigHPaddingTolLoadingView/readToPlayViewOrigHHeight*readToPlayViewHHeight;
        CGFloat appNameLabelHPaddingToTitleLable=appNameLabelOrigHPaddingToTitleLable/readToPlayViewOrigHHeight*readToPlayViewHHeight;
        
        //手势新手引导展示view
        CGFloat directiveViewVMinY=readToPlayViewVHeight-directiveViewVHeight;
        CGFloat directiveViewHMinY=readToPlayViewHHeight-directiveViewHHeight;
        if (!_isLearnedAll)
        {
            CGRect  directiveViewVFrame=CGRectMake(0, directiveViewVMinY, readToPlayViewVWidth, directiveViewVHeight);
            CGRect  directiveViewHFrame=CGRectMake(0, directiveViewHMinY, readToPlayViewHWidth, directiveViewHHeight);
            self.directiveView=[[ICEDirectiveView alloc] initWithVFrame:directiveViewVFrame
                                                                 HFrame:directiveViewHFrame
                                                            OrigVHeight:directiveViewOrigVHeight];
            [self addSubview:_directiveView];
        }
        
        //loadingView
        NSString * loadingImageName=@"publicLoading@2x";
        UIImage * loadingViewImage=IMAGENAME(loadingImageName, @"png");
        CGFloat loadingViewWidth=loadingViewImage.size.width;
        CGFloat loadingViewHeight=loadingViewImage.size.height;
        CGFloat loadingViewVMinX=(readToPlayViewVWidth-loadingViewWidth)/2;
        CGFloat loadingViewVMinY=(readToPlayViewVHeight-loadingViewVPaddingToBottom-loadingViewHeight);
        CGFloat loadingViewHMinX=(readToPlayViewHWidth-loadingViewWidth)/2;
        CGFloat loadingViewHMinY=(readToPlayViewHHeight-loadingViewHPaddingToBottom-loadingViewHeight);
        _loadingViewVOrigin=CGPointMake(loadingViewVMinX, loadingViewVMinY);
        _loadingViewHOrigin=CGPointMake(loadingViewHMinX, loadingViewHMinY);
        CGRect  loadingViewFrame=CGRectMake(loadingViewVMinX, loadingViewVMinY, loadingViewWidth, loadingViewHeight);
        self.loadingView=[[ICELoadingView alloc] initWithFrame:loadingViewFrame];
        [_loadingView setLoadingViewImageName:loadingImageName];
        [self addSubview:_loadingView];
        
        //titleLabel
        CGFloat titleLabelHeight=12;
        CGFloat titleLabelVMinY=directiveViewVMinY-titleLableVPaddingToDirectiveImage-titleLabelHeight;
        CGFloat titleLabelHMinY=loadingViewHMinY-titleLableHPaddingTolLoadingView-titleLabelHeight;
        _titleLabelVFrame=CGRectMake(0, titleLabelVMinY, readToPlayViewVWidth, titleLabelHeight);
        _titleLabelHFrame=CGRectMake(0, titleLabelHMinY, readToPlayViewHWidth, titleLabelHeight);
        self.titleLabel=[[UILabel alloc] initWithFrame:_titleLabelVFrame];
        [_titleLabel setText:@""];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:titleLabelHeight]];
        [_titleLabel setTextColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1]];
        [self addSubview:_titleLabel];
        
        //应用名称
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString * appName=infoDictionary[@"CFBundleDisplayName"];
        CGFloat appNameLabelHeight=18;
        CGFloat appNameLabelVMinY=titleLabelVMinY-appNameLabelVPaddingToTitleLable-appNameLabelHeight;
        CGFloat appNameLabelHMinY=titleLabelHMinY-appNameLabelHPaddingToTitleLable-appNameLabelHeight;
        _appNameLabelVFrame=CGRectMake(0, appNameLabelVMinY, readToPlayViewVWidth, appNameLabelHeight);
        _appNameLabelHFrame=CGRectMake(0, appNameLabelHMinY, readToPlayViewHWidth, appNameLabelHeight);
        self.appNameLabel=[[UILabel alloc] initWithFrame:_appNameLabelVFrame];
        [_appNameLabel setText:(appName?appName:@"影视大全播放器")];
        [_appNameLabel setTextAlignment:NSTextAlignmentCenter];
        [_appNameLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:appNameLabelHeight]];
        [_appNameLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:_appNameLabel];
        
        //切换到小屏的按钮
        CGRect switchVSizeButtonFrame=CGRectMake(0, 20, 42, 40);
        self.switchVSizeButton = [ICEButton buttonWithType:UIButtonTypeCustom];
        [_switchVSizeButton setFrame:switchVSizeButtonFrame];
        [_switchVSizeButton setImage:IMAGENAME(@"playerTopViewSmallScreen@2x", @"png") forState:UIControlStateNormal];
        [_switchVSizeButton addTarget:self action:@selector(goSwitchToVSize) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchVSizeButton];
        [_switchVSizeButton setHidden:YES];
    }
    return self;
}

-(void)setIsFullScreenDisplay:(BOOL)isFullScreen
{
    CGRect loadingViewFrame=_loadingView.frame;
    if (isFullScreen)
    {
        [_switchVSizeButton setHidden:NO];
        [self setFrame:_readToPlayViewHFrame];
        loadingViewFrame.origin=_loadingViewHOrigin;
        [_titleLabel setFrame:_titleLabelHFrame];
        [_appNameLabel setFrame:_appNameLabelHFrame];
        [_directiveView setDirectiveViewStyle:ICEDirectiveViewHorizontalStyle];
    }
    else
    {
        [_switchVSizeButton setHidden:YES];
        [self setFrame:_readToPlayViewVFrame];
        loadingViewFrame.origin=_loadingViewVOrigin;
        [_titleLabel setFrame:_titleLabelVFrame];
        [_appNameLabel setFrame:_appNameLabelVFrame];
        [_directiveView setDirectiveViewStyle:ICEDirectiveViewVerticalStyle];
    }
    [_loadingView setFrame:loadingViewFrame];
}

-(void)destroyLoading
{
    [_loadingView destroyLoading];
}

-(void)startLoadingWithTitle:(NSString *)title
{
    [self setHidden:NO];
    [_directiveView setHidden:_isLearnedAll];
    [_titleLabel setText:[NSString stringWithFormat:@"即将播放：%@",title]];
    [_loadingView startLoading];
}

-(void)stopLoading
{
    if (![self isHidden])
    {
        [self setHidden:YES];
    }
    [_loadingView stopLoading];
}

-(void)goSwitchToVSize
{
    if (_switchPlayerViewOrientationBlock) {
        _switchPlayerViewOrientationBlock();
    }
}
@end
