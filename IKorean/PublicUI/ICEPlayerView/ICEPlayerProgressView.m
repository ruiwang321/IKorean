//
//  ICEPlayerProgressView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/8/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerProgressView.h"
#define currentTimeInitialValue       @"00:00:00"
#define totalDurationInitialValue     @" / 00:00:00"
@interface ICEPlayerProgressView ()

@property (nonatomic,strong) UIImage * forwardImage;
@property (nonatomic,strong) UIImage * reverseImage;
@property (nonatomic,strong) UIImageView * directionImageView;
@property (nonatomic,strong) UILabel * totalDurationLabel;
@property (nonatomic,strong) UILabel * currentTimeLabel;
@property (nonatomic,strong) UIProgressView * progressView;
@property (nonatomic,assign) CGFloat progressViewWidth;
@property (nonatomic,assign) CGFloat progressViewHeight;
@property (nonatomic,strong) NSDateFormatter * dateFormatter;
@property (nonatomic,assign) NSTimeInterval totalSeconds;
@end

@implementation ICEPlayerProgressView

-(id)initWithProgressViewWidth:(CGFloat)playerProgressViewWidth
{
    if (self=[super init])
    {
        [self setHidden:YES];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setBackgroundColor:[UIColor colorWithRed:10.0f/255.0f green:10.0f/255.0f blue:10.0f/255.0f alpha:0.9]];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm:ss"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        _progressViewWidth = playerProgressViewWidth;
        CGFloat  controlPadding=10;

        //方向图片
        self.forwardImage=IMAGENAME(@"playerForward@2x", @"png");
        self.reverseImage=IMAGENAME(@"playerReverse@2x", @"png");

        CGFloat directionImageWidth=_forwardImage.size.width;
        CGFloat directionImageHeight=_forwardImage.size.height;
        CGFloat directionImageViewMinX=(_progressViewWidth-directionImageWidth)/2;
        CGFloat directionImageViewMinY=controlPadding;
        CGRect  directionImageViewFrame=CGRectMake(directionImageViewMinX, directionImageViewMinY, directionImageWidth, directionImageHeight);
        self.directionImageView=[[UIImageView alloc] initWithFrame:directionImageViewFrame];
        [self addSubview:_directionImageView];
        
        //当前时间label
        CGFloat currentTimeLabelMinY=CGRectGetMaxY(directionImageViewFrame)+controlPadding;
        CGFloat currentTimeLabelWidth=_progressViewWidth/2-4;
        CGFloat currentTimeLabelHeight=15;
        CGRect  currentTimeLabelFrame=CGRectMake(0, currentTimeLabelMinY, currentTimeLabelWidth, currentTimeLabelHeight);
        self.currentTimeLabel=[[UILabel alloc] initWithFrame:currentTimeLabelFrame];
        [_currentTimeLabel setText:currentTimeInitialValue];
        [_currentTimeLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:14]];
        [_currentTimeLabel setTextColor:PlayerControlColor];
        [_currentTimeLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_currentTimeLabel];
        
        //总时间
        CGRect  totalDurationLabelFrame=currentTimeLabelFrame;
        totalDurationLabelFrame.origin.x=CGRectGetMaxX(currentTimeLabelFrame);
        totalDurationLabelFrame.size.width=_progressViewWidth-totalDurationLabelFrame.origin.x;
        self.totalDurationLabel=[[UILabel alloc]initWithFrame:totalDurationLabelFrame];
        [_totalDurationLabel setText:totalDurationInitialValue];
        [_totalDurationLabel setFont:_currentTimeLabel.font];
        [_totalDurationLabel setTextColor:[UIColor whiteColor]];
        [_totalDurationLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_totalDurationLabel];
        
        //进度条
        CGFloat  progressViewMinX = controlPadding;
        CGFloat  progressViewMinY = CGRectGetMaxY(totalDurationLabelFrame)+controlPadding;
        CGFloat  progressViewWidth = playerProgressViewWidth-2*progressViewMinX;
        CGFloat  progressViewHeight = 3;
        CGRect   progressViewFrame = CGRectMake(progressViewMinX, progressViewMinY, progressViewWidth, progressViewHeight);
        self.progressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [_progressView setFrame:progressViewFrame];
        [_progressView setProgressTintColor:PlayerControlColor];
        [_progressView setTrackTintColor:[UIColor lightGrayColor]];
        [_progressView setProgress:0];
        [self addSubview:_progressView];
    
        _progressViewHeight = CGRectGetMaxY(progressViewFrame)+controlPadding;
    }
    return self;
}

-(void)addToSuperViewAndaddConstraintsWithSuperView:(UIView *)superView
{
    [superView addSubview:self];
    
    CGFloat  centerYOffsetY=40;
    
    NSLayoutConstraint * centerXConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:superView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0];
    
    NSLayoutConstraint * centerYConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:superView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1
                                                                         constant:-centerYOffsetY];
    
    NSLayoutConstraint * widthConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:_progressViewWidth];
    
    NSLayoutConstraint * heightConstraint=[NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:_progressViewHeight];
    
    [superView addConstraints:@[centerXConstraint,centerYConstraint,widthConstraint,heightConstraint]];
}

- (NSString *)convertTimeWithSeconds:(NSTimeInterval)seconds
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSString * timeString = [_dateFormatter stringFromDate:date];
    return timeString;
}

-(void)reloadWithCurrentSeconds:(NSTimeInterval)currentSeconds
                   totalSeconds:(NSTimeInterval)totalSeconds
{
    _totalSeconds=totalSeconds;
    [_progressView setProgress:currentSeconds/totalSeconds];
    [_currentTimeLabel setText:[self convertTimeWithSeconds:currentSeconds]];
    [_totalDurationLabel setText:[NSString stringWithFormat:@" / %@",[self convertTimeWithSeconds:totalSeconds]]];
}

-(void)updateProgressWithChangeSeconds:(NSTimeInterval)changeSeconds
                         actionOptions:(ICEPlayerProgressViewActionOptions)actionOptions
                        updatedSeconds:(NSTimeInterval *)updatedSeconds
{
    NSTimeInterval desiredSeconds;
    if (PlayerProgressViewUpdateBegan==actionOptions)
    {
        [self setHidden:NO];
        desiredSeconds=changeSeconds;
    }
    else if(PlayerProgressViewUpdateEnd==actionOptions)
    {
        [self setHidden:YES];
        desiredSeconds=_progressView.progress*_totalSeconds;
    }
    else
    {
        desiredSeconds=_progressView.progress*_totalSeconds;
        if (PlayerProgressViewGoForward==actionOptions)
        {
            [_directionImageView setImage:_forwardImage];
            desiredSeconds+=changeSeconds;
        }
        else
        {
            [_directionImageView setImage:_reverseImage];
            desiredSeconds-=changeSeconds;
        }
        if (desiredSeconds<0)
        {
            desiredSeconds=0;
        }
        else if(desiredSeconds>_totalSeconds)
        {
            desiredSeconds=_totalSeconds;
        }
    }
    [_progressView setProgress:(desiredSeconds/_totalSeconds)];
    [_currentTimeLabel setText:[self convertTimeWithSeconds:desiredSeconds]];
    *updatedSeconds=desiredSeconds;
}

-(void)updateProgressWithDesiredSeconds:(NSTimeInterval)desiredSeconds
                          actionOptions:(ICEPlayerProgressViewActionOptions)actionOptions
{
    if (PlayerProgressViewUpdateBegan==actionOptions)
    {
        [self setHidden:NO];
    }
    else if(PlayerProgressViewUpdateEnd==actionOptions)
    {
        [self setHidden:YES];
    }
    else if (PlayerProgressViewGoForward==actionOptions)
    {
        [_directionImageView setImage:_forwardImage];
    }
    else
    {
        [_directionImageView setImage:_reverseImage];
    }
    [_progressView setProgress:(desiredSeconds/_totalSeconds)];
    [_currentTimeLabel setText:[self convertTimeWithSeconds:desiredSeconds]];
}
@end
