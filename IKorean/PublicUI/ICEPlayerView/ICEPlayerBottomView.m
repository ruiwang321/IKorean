//
//  ICEPlayerBottomView.m
//  TestVFLProject
//
//  Created by yunlongwang on 16/8/28.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerBottomView.h"
#define currentTimeInitialValue       @"00:00:00"
#define totalDurationInitialValue     @" / 00:00:00"
#define lastValueInitialValue         (-1)

@interface ICEPlayerProgressSlider : UISlider
@end

@implementation ICEPlayerProgressSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    if (CGRectGetMinX(self.frame)>0)
    {
        rect.size.width+=4;
        rect.origin.x-=1;
    }
    return [super thumbRectForBounds:bounds trackRect:rect value:value];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

@end

@interface ICEProgressSliderEventModel:NSObject
@property (nonatomic,assign,readwrite) float value;
@property (nonatomic,assign,readwrite) ICEPlayerBottomViewSliderEvents event;
@end

@implementation ICEProgressSliderEventModel

@end

@interface ICEPlayerBottomView ()

@property (nonatomic,strong) NSDateFormatter * dateFormatter;
@property (nonatomic,assign) CGRect bottomVFrame;
@property (nonatomic,assign) CGRect bottomHFrame;

@property (nonatomic,strong) UIView * backgroundColorView;
@property (nonatomic,assign) CGRect backgroundColorViewHFrame;

@property (nonatomic,strong) ICEButton * playButton;
@property (nonatomic,assign) CGPoint playButtonVOrigin;
@property (nonatomic,assign) CGPoint playButtonHOrigin;

@property (nonatomic,strong) ICEButton * switchSizeButton;
@property (nonatomic,assign) CGPoint switchSizeButtonVOrigin;
@property (nonatomic,assign) CGPoint switchSizeButtonHOrigin;

@property (nonatomic,strong) ICEButton * nextEpisodeButton;

@property (nonatomic,strong) ICEPlayerProgressSlider * progressSlider;
@property (nonatomic,assign) CGRect progressSliderVFrame;
@property (nonatomic,assign) CGRect progressSliderHFrame;

@property (nonatomic,strong) UIProgressView * bufferView;

@property (nonatomic,strong) UILabel * currentTimeLabel;
@property (nonatomic,assign) CGPoint currentTimeLabelVOrigin;
@property (nonatomic,assign) CGPoint currentTimeLabelHOrigin;

@property (nonatomic,strong) UILabel * totalDurationLabel;

@property (nonatomic,assign) NSTimeInterval totalSeconds;
@property (nonatomic,strong) ICEProgressSliderEventModel * sliderEventModel;

@end

@implementation ICEPlayerBottomView

-(id)initWithVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame
{
    if (self=[super initWithFrame:vFrame])
    {
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:NO];
        
        _bottomVFrame=vFrame;
        _bottomHFrame=hFrame;
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm:ss"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        self.sliderEventModel=[[ICEProgressSliderEventModel alloc] init];
        _sliderEventModel.value=lastValueInitialValue;
        _sliderEventModel.event=ICEPlayerBottomViewSliderAdjustProgressEnd;

        CGFloat bottomViewVWidth=CGRectGetWidth(vFrame);
        CGFloat bottomViewVHeight=CGRectGetHeight(vFrame);
        CGFloat bottomViewHWidth=CGRectGetWidth(hFrame);
        CGFloat bottomViewHHeight=CGRectGetHeight(hFrame);

        CGFloat controlMinWidth=35;
        CGFloat controlVPadding=10;
        CGFloat controlHPadding=15;
        CGSize  sliderImageSize=CGSizeMake(5, 3);
        UIImage * thumbImage=IMAGENAME(@"playerProgressDot@2x", @"png");
        CGFloat progressSliderHeight=thumbImage.size.height;
        CGFloat controlHBaseLineY=progressSliderHeight/2+sliderImageSize.height/2;
        CGFloat backgroundColorViewHMinY=controlHBaseLineY-sliderImageSize.height;
        
        //背景颜色View
        _backgroundColorViewHFrame=_bottomHFrame;
        _backgroundColorViewHFrame.origin.y=backgroundColorViewHMinY;
        _backgroundColorViewHFrame.size.height=CGRectGetHeight(_bottomHFrame)-backgroundColorViewHMinY;
        self.backgroundColorView=[[UIView alloc] initWithFrame:self.bounds];
        [_backgroundColorView setBackgroundColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewPublicColor];
        [_backgroundColorView setUserInteractionEnabled:NO];
        [self addSubview:_backgroundColorView];
        
        //暂停播放按钮
        UIImage * playButtonPauseImage=IMAGENAME(@"playerPause@2x", @"png");
        UIImage * playButtonPlayImage=IMAGENAME(@"playerPlay@2x", @"png");
        CGFloat playImageWidth=playButtonPlayImage.size.width;
        CGFloat playButtonVMinX=controlVPadding-(controlMinWidth-playImageWidth)/2;
        CGFloat playButtonVMinY=(bottomViewVHeight-controlMinWidth)/2;
        CGFloat playButtonHMinX=controlHPadding-(controlMinWidth-playImageWidth)/2;
        CGFloat playButtonHMinY=controlHBaseLineY+(bottomViewHHeight-controlHBaseLineY-controlMinWidth)/2;
        _playButtonVOrigin=CGPointMake(playButtonVMinX,playButtonVMinY);
        _playButtonHOrigin=CGPointMake(playButtonHMinX,playButtonHMinY);
        CGRect  playButtonVFrame=CGRectMake(playButtonVMinX, playButtonVMinY, controlMinWidth, controlMinWidth);
        self.playButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [_playButton setFrame:playButtonVFrame];
        [_playButton addTarget:self action:@selector(goPlayOrPause) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setNormalImage:playButtonPauseImage highlightedImage:playButtonPlayImage];
        [_playButton setIsHighlighted:YES];
        [self addSubview:_playButton];
        
        //横竖屏幕切换按钮
        UIImage * switchSizeButtonVImage=IMAGENAME(@"playerFullScreen@2x", @"png");
        UIImage * switchSizeButtonHImage=IMAGENAME(@"playerSmallScreen@2x", @"png");
        CGFloat fullScreenImage=switchSizeButtonVImage.size.width;
        CGFloat switchSizeButtonVMinX=bottomViewVWidth-controlVPadding-controlMinWidth+(controlMinWidth-fullScreenImage)/2;
        CGFloat switchSizeButtonVMinY=(bottomViewVHeight-controlMinWidth)/2;
        CGFloat switchSizeButtonHMinX=bottomViewHWidth-controlHPadding-controlMinWidth+(controlMinWidth-fullScreenImage)/2;
        CGFloat switchSizeButtonHMinY=playButtonHMinY;
        _switchSizeButtonVOrigin=CGPointMake(switchSizeButtonVMinX, switchSizeButtonVMinY);
        _switchSizeButtonHOrigin=CGPointMake(switchSizeButtonHMinX, switchSizeButtonHMinY);
        CGRect  switchSizeButtonVFrame=CGRectMake(switchSizeButtonVMinX, switchSizeButtonVMinY, controlMinWidth, controlMinWidth);
        self.switchSizeButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [_switchSizeButton setFrame:switchSizeButtonVFrame];
        [_switchSizeButton addTarget:self action:@selector(goSwitchSize) forControlEvents:UIControlEventTouchUpInside];
        [_switchSizeButton setNormalImage:switchSizeButtonVImage highlightedImage:switchSizeButtonHImage];
        [self addSubview:_switchSizeButton];
        
        //进度slider
        UIImage * minimumTrackImage=[UIImage imageWithColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewControlColor size:sliderImageSize];
        UIImage * maximumTrackImage=[UIImage imageWithColor:[UIColor clearColor] size:sliderImageSize];
        CGFloat progressSliderVMinX=CGRectGetMaxX(playButtonVFrame)+controlVPadding;
        CGFloat progressSliderVMinY=7;
        CGFloat progressSliderVWidth=switchSizeButtonVMinX-controlVPadding-progressSliderVMinX;
        _progressSliderVFrame=CGRectMake(progressSliderVMinX, progressSliderVMinY, progressSliderVWidth, progressSliderHeight);
        _progressSliderHFrame=_progressSliderVFrame;
        _progressSliderHFrame.origin.x=-2;
        _progressSliderHFrame.origin.y=0;
        _progressSliderHFrame.size.width=bottomViewHWidth+4;
        self.progressSlider = [[ICEPlayerProgressSlider alloc]initWithFrame:_progressSliderVFrame];
        [_progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackImage:minimumTrackImage forState:UIControlStateNormal];
        [_progressSlider setMaximumTrackImage:maximumTrackImage forState:UIControlStateNormal];
        [_progressSlider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(sliderTouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        _progressSlider.value=0;
        [self addSubview:_progressSlider];
        
        //缓冲进度条
        CGFloat  bufferViewHeight=2.5;
        CGFloat  bufferViewOffsetX=2;
        UIImage * progressImage=[UIImage imageWithColor:[UIColor lightGrayColor]size:sliderImageSize];
        UIImage * trackImage=[UIImage imageWithColor:[UIColor colorWithRed:80.0f/255.0f green:80.0f/255.0f blue:80.0f/255.0f alpha:1]  size:sliderImageSize];
        CGRect bufferViewFrame=CGRectMake(bufferViewOffsetX, (progressSliderHeight-bufferViewHeight)/2, progressSliderVWidth-bufferViewOffsetX, bufferViewHeight);
        self.bufferView=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        [_bufferView setProgressImage:progressImage];
        [_bufferView setTrackImage:trackImage];
        [_bufferView setUserInteractionEnabled:NO];
        [_bufferView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_bufferView setFrame:bufferViewFrame];
        [_progressSlider addSubview:_bufferView];
        [_progressSlider sendSubviewToBack:_bufferView];

        //下一集按钮
        UIImage * nextEpisodeImage=IMAGENAME(@"playerNext@2x", @"png");
        CGFloat  nextEpisodeButtonMinX=_playButtonHOrigin.x+controlMinWidth+controlHPadding;
        CGFloat  nextEpisodeButtonMinY=playButtonHMinY;
        CGRect   nextEpisodeButtonFrame=CGRectMake(nextEpisodeButtonMinX, nextEpisodeButtonMinY, controlMinWidth, controlMinWidth);
        self.nextEpisodeButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [_nextEpisodeButton setFrame:nextEpisodeButtonFrame];
        [_nextEpisodeButton setImage:nextEpisodeImage forState:UIControlStateNormal];
        [_nextEpisodeButton addTarget:self action:@selector(goLookNextEpisode) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextEpisodeButton];
        [_nextEpisodeButton setHidden:YES];
        
        //当前时间label
        CGFloat currentTimeLabelVMinX=progressSliderVMinX;
        CGFloat currentTimeLabelVMinY=CGRectGetMaxY(_progressSliderVFrame);
        CGFloat currentTimeLabelWidth=50;
        CGFloat currentTimeLabelHeight=bottomViewVHeight-currentTimeLabelVMinY;
        CGRect  currentTimeLabelFrame=CGRectMake(currentTimeLabelVMinX, currentTimeLabelVMinY, currentTimeLabelWidth, currentTimeLabelHeight);
        CGFloat currentTimeLabelHMinX=CGRectGetMaxX(nextEpisodeButtonFrame)+controlHPadding;
        CGFloat currentTimeLabelHMinY=controlHBaseLineY+(bottomViewHHeight-controlHBaseLineY-currentTimeLabelHeight)/2;
        _currentTimeLabelVOrigin=CGPointMake(currentTimeLabelVMinX, currentTimeLabelVMinY);
        _currentTimeLabelHOrigin=CGPointMake(currentTimeLabelHMinX, currentTimeLabelHMinY);
        self.currentTimeLabel=[[UILabel alloc] initWithFrame:currentTimeLabelFrame];
        [_currentTimeLabel setText:currentTimeInitialValue];
        [_currentTimeLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:11]];
        [_currentTimeLabel setTextColor:[UIColor whiteColor]];
        [_currentTimeLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_currentTimeLabel];
        
        //总时间
        CGFloat totalDurationLabelWidth=60;
        self.totalDurationLabel=[[UILabel alloc] init];
        [_totalDurationLabel setText:totalDurationInitialValue];
        [_totalDurationLabel setFont:_currentTimeLabel.font];
        [_totalDurationLabel setTextColor:[UIColor colorWithRed:148.0f/255.0f green:148.0f/255.0f blue:148.0f/255.0f alpha:1]];
        [_totalDurationLabel setTextAlignment:NSTextAlignmentLeft];
        [_totalDurationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_totalDurationLabel];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_currentTimeLabel][_totalDurationLabel(width)]"
                                                                     options:0
                                                                     metrics:@{@"width":@(totalDurationLabelWidth)}
                                                                       views:NSDictionaryOfVariableBindings(_currentTimeLabel,_totalDurationLabel)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_totalDurationLabel(==_currentTimeLabel)]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_currentTimeLabel,_totalDurationLabel)]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_totalDurationLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_currentTimeLabel
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:0]];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

-(void)setIsFullScreenDisplay:(BOOL)isFullScreen
{
    CGRect playButtonFrame=_playButton.frame;
    CGRect switchSizeButtonFrame=_switchSizeButton.frame;
    CGRect currentTimeLabelFrame=_currentTimeLabel.frame;
    if (isFullScreen)
    {
        [self setFrame:_bottomHFrame];
        [_backgroundColorView setFrame:_backgroundColorViewHFrame];
        [_progressSlider setFrame:_progressSliderHFrame];
        [_switchSizeButton setIsHighlighted:YES];
        [_nextEpisodeButton setHidden:NO];
        playButtonFrame.origin=_playButtonHOrigin;
        switchSizeButtonFrame.origin=_switchSizeButtonHOrigin;
        currentTimeLabelFrame.origin=_currentTimeLabelHOrigin;
    }
    else
    {
        [self setFrame:_bottomVFrame];
        [_backgroundColorView setFrame:self.bounds];
        [_progressSlider setFrame:_progressSliderVFrame];
        [_switchSizeButton setIsHighlighted:NO];
        [_nextEpisodeButton setHidden:YES];
        playButtonFrame.origin=_playButtonVOrigin;
        switchSizeButtonFrame.origin=_switchSizeButtonVOrigin;
        currentTimeLabelFrame.origin=_currentTimeLabelVOrigin;
    }
    [_playButton setFrame:playButtonFrame];
    [_switchSizeButton setFrame:switchSizeButtonFrame];
    [_currentTimeLabel setFrame:currentTimeLabelFrame];
}

- (NSString *)convertTimeWithSeconds:(NSTimeInterval)seconds
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSString * timeString = [_dateFormatter stringFromDate:date];
    return timeString;
}

-(void)reloadWithTotalSeconds:(NSTimeInterval)totalSeconds
{
    _totalSeconds=totalSeconds;
    [_progressSlider setMaximumValue:totalSeconds];
    [_progressSlider setMinimumValue:0];
    [_progressSlider setValue:0];
    [_currentTimeLabel setText:currentTimeInitialValue];
    [_totalDurationLabel setText:[NSString stringWithFormat:@" / %@",[self convertTimeWithSeconds:totalSeconds]]];
}

-(void)updateBufferWithLoadSeconds:(NSTimeInterval)loadSeconds
{
    if (_totalSeconds)
    {
        [_bufferView setProgress:loadSeconds/_totalSeconds];
    }
}

-(void)setProgressSeconds:(float)progressSeconds
{
    [_progressSlider setValue:progressSeconds];
    [_currentTimeLabel setText:[self convertTimeWithSeconds:progressSeconds]];
}

-(float)getProgressSeconds
{
    return _progressSlider.value;
}

-(void)setIsPlay:(BOOL)isPlay
{
    [_playButton setIsHighlighted:!isPlay];
}

-(BOOL)isAdjustProgress
{
    return (ICEPlayerBottomViewSliderAdjustProgressEnd==_sliderEventModel.event?NO:YES);
}

-(void)sliderValueChange
{
    float newValue=_progressSlider.value;
    float lastValue=_sliderEventModel.value;
    ICEPlayerBottomViewSliderEvents event=_sliderEventModel.event;
    if (lastValue==lastValueInitialValue)
    {
        event = ICEPlayerBottomViewSliderAdjustProgressBegan;
    }
    else if ((newValue!=_progressSlider.maximumValue)&&
             (newValue!=_progressSlider.minimumValue))
    {
        if (newValue>lastValue)
        {
            event = ICEPlayerBottomViewSliderAdjustProgressForward;
        }
        else
        {
            event = ICEPlayerBottomViewSliderAdjustProgressReverse;
        }
    }
    _sliderEventModel.value=newValue;
    _sliderEventModel.event=event;
    [self executeSliderEventBlock];
}

-(void)sliderTouchUp
{
    _sliderEventModel.value=lastValueInitialValue;
    _sliderEventModel.event=ICEPlayerBottomViewSliderAdjustProgressEnd;
    [self executeSliderEventBlock];
}

-(void)executeSliderEventBlock
{
    NSTimeInterval desiredSeconds=(NSTimeInterval)_progressSlider.value;
    [_currentTimeLabel setText:[self convertTimeWithSeconds:desiredSeconds]];
    if (_sliderEventBlock)
    {
        _sliderEventBlock(desiredSeconds,_sliderEventModel.event);
    }
}

-(void)executeControlEventBlockWithControlEvent:(ICEPlayerBottomViewControlEvents)controlEvent
{
    if (_controlEventBlock)
    {
        _controlEventBlock(controlEvent);
    }
}

-(void)goPlayOrPause
{
    [self executeControlEventBlockWithControlEvent:ICEPlayerBottomViewControlPlayOrPause];
}

-(void)goSwitchSize
{
    if (_switchPlayerViewOrientationBlock) {
        _switchPlayerViewOrientationBlock();
    }
}

-(void)goLookNextEpisode
{
    [self executeControlEventBlockWithControlEvent:ICEPlayerBottomViewControlLookNextEpisode];
}

-(void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (animated)
    {
        if (hidden)
        {
            [self setAlpha:1];
            [UIView animateWithDuration:0.2 animations:^{
                [self setAlpha:0];
            }completion:^(BOOL finished){
                [self setHidden:YES];
                [self setAlpha:0];
            }];
        }
        else
        {
            [self setHidden:NO];
            [UIView animateWithDuration:0.2 animations:^{
                [self setAlpha:1];
            }completion:^(BOOL finished){
                [self setAlpha:1];
            }];
        }
    }
    else
    {
        [self setHidden:hidden];
    }
}
@end
