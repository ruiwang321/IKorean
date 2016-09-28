//
//  ICECyclicRollingTextView.m
//  TestVFLProject
//
//  Created by yunlongwang on 16/9/3.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICECyclicRollingTextView.h"
@interface ICECyclicRollingTextView ()

@property (nonatomic,assign) BOOL isNeedRolling;
@property (nonatomic,assign) NSStringDrawingOptions textOption;
@property (nonatomic,strong) NSDictionary * textAttributes;
@property (nonatomic,assign) CGFloat labelPadding;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,assign) NSTimeInterval repeatTimeInterval;
@property (nonatomic,strong) UILabel * firstLabel;
@property (nonatomic,strong) UILabel * secondLabel;

@end

@implementation ICECyclicRollingTextView
-(void)dealloc
{
    [self stopRollingWithIsDestroy:YES];
}

-(id)initWithFrame:(CGRect)frame
              font:(UIFont *)font
         textColor:(UIColor *)textColor
         alignment:(NSTextAlignment)alignment
repeatTimeInterval:(NSTimeInterval)timeInterval
{
    if (self=[super initWithFrame:frame])
    {
        [self setClipsToBounds:YES];
        
        _labelPadding=15;
        _repeatTimeInterval=MAX(0.01, timeInterval);
        _isNeedRolling=NO;
        
        _textOption = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        
        NSMutableParagraphStyle * textParagraphStyle=[[NSMutableParagraphStyle alloc]init];
        textParagraphStyle.alignment = alignment;
    
        self.textAttributes=@{
                              NSFontAttributeName:font,
                              NSForegroundColorAttributeName:textColor,
                              NSParagraphStyleAttributeName:textParagraphStyle
                              };
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(self.frame, frame))
    {
        [super setFrame:frame];
        if (_firstLabel)
        {
            [self setText:_firstLabel.text];
        }
    }
}

-(void)setText:(NSString *)text
{
    if (text)
    {
        //关掉定时器
        [self stopRollingWithIsDestroy:NO];
        CGFloat textViewWidth=CGRectGetWidth(self.bounds);
        CGFloat textViewHeight=CGRectGetHeight(self.bounds);
        
        if (_firstLabel==nil)
        {
            self.firstLabel=[[UILabel alloc] init];
            [_firstLabel setText:@""];
            [self addSubview:_firstLabel];
        }
        
        NSAttributedString * textAttributedString=[[NSAttributedString alloc] initWithString:text attributes:_textAttributes];
        CGSize  textSize=[textAttributedString boundingRectWithSize:CGSizeMake(10000, textViewHeight) options:_textOption context:nil].size;
        CGFloat textWidth=textSize.width;
        if (textWidth<=textViewWidth)
        {
            _isNeedRolling=NO;
            
            CGRect firstLabelFrame=self.bounds;
            [_firstLabel setFrame:firstLabelFrame];
            [_firstLabel setAttributedText:textAttributedString];
            [_secondLabel setHidden:YES];
        }
        else
        {
            _isNeedRolling=YES;
            
            CGRect firstLabelFrame=self.bounds;
            firstLabelFrame.size.width=textWidth;
            [_firstLabel setFrame:firstLabelFrame];
            [_firstLabel setAttributedText:textAttributedString];
            
            CGRect secondLabelFrame=firstLabelFrame;
            secondLabelFrame.origin.x=CGRectGetMaxX(firstLabelFrame)+_labelPadding;
            if (_secondLabel==nil)
            {
                self.secondLabel=[[UILabel alloc] init];
                [_secondLabel setText:@""];
                [self addSubview:_secondLabel];
            }
            [_secondLabel setFrame:secondLabelFrame];
            [_secondLabel setAttributedText:textAttributedString];
            [_secondLabel setHidden:NO];
            //打开定时器
            [self startRolling];
        }
    }
}

-(void)startRolling
{
    if (_isNeedRolling)
    {
        if (_timer==nil)
        {
            self.timer=[NSTimer  timerWithTimeInterval:_repeatTimeInterval
                                                target:self
                                              selector:@selector(rollingLabel)
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
    
}

-(void)stopRollingWithIsDestroy:(BOOL)isDestroy
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

-(void)rollingLabel
{
    CGRect firstTitleLabelFrame=_firstLabel.frame;
    CGRect secondTitleLabelFrame=_secondLabel.frame;
    
    firstTitleLabelFrame.origin.x-=1;
    secondTitleLabelFrame.origin.x-=1;
    
    CGFloat firstLabelMaxX=CGRectGetMaxX(firstTitleLabelFrame);
    CGFloat secondLabelMaxX=CGRectGetMaxX(secondTitleLabelFrame);
    if (firstLabelMaxX<=0)
    {
        firstTitleLabelFrame.origin.x=secondLabelMaxX+_labelPadding;
    }
    
    if (secondLabelMaxX<=0)
    {
        secondTitleLabelFrame.origin.x=firstLabelMaxX+_labelPadding;
    }
    
    _firstLabel.frame=firstTitleLabelFrame;
    _secondLabel.frame=secondTitleLabelFrame;
}
@end
