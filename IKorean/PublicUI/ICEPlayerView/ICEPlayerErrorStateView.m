//
//  ICEPlayerErrorStateView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerErrorStateView.h"

#define ErrorMessageNoNetWorkString           @"网络未连接，请检查网络设置"
#define ErrorMessageNetWorkBusy               @"当前网络繁忙，建议您稍后再试"
#define ErrorMessageNoWIFIString              @"当前网络状态不是WIFI,继续观看将产生流量"
#define ErrorMessageVideoURLInValidString     @"视频播放地址似乎失效，请重试或去网上观看"
#define ErrorMessageVideoLoadFailedString     @"视频加载失败，请重试"

#define EnsureKeepWatching                    @"继续观看"
#define EnsureRetry                           @"重试"

#define EnsureKeepWatchingTag                 8000
#define EnsureRetryTag                        8001
@interface ICEPlayerErrorStateView ()

@property (nonatomic,strong)ICEButton * switchVSizeButton;
@property (nonatomic,strong)UILabel * errorMessageLabel;
@property (nonatomic,strong)ICEButton * ensureButton;
@end

@implementation ICEPlayerErrorStateView

-(id)init
{
    if (self=[super init])
    {
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor blackColor]];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        //错误信息Label
        CGFloat errorMessageLabelHeight=15;
        self.errorMessageLabel=[[UILabel alloc] init];
        [_errorMessageLabel setText:@""];
        [_errorMessageLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:errorMessageLabelHeight]];
        [_errorMessageLabel setTextAlignment:NSTextAlignmentCenter];
        [_errorMessageLabel setTextColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1]];
        [_errorMessageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_errorMessageLabel];
        NSArray * errorMessageLabelHConstraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-hPadding-[_errorMessageLabel]-hPadding-|"
                                                                                        options:0
                                                                                        metrics:@{@"hPadding":@10}
                                                                                          views:NSDictionaryOfVariableBindings(_errorMessageLabel)];
        
        NSLayoutConstraint * errorMessageLabelHeightConstraint=[NSLayoutConstraint constraintWithItem:_errorMessageLabel
                                                                                            attribute:NSLayoutAttributeHeight
                                                                                            relatedBy:NSLayoutRelationEqual
                                                                                               toItem:nil
                                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                                           multiplier:1
                                                                                             constant:errorMessageLabelHeight];
        
        NSLayoutConstraint * errorMessageLabelCenterXConstraint=[NSLayoutConstraint constraintWithItem:_errorMessageLabel
                                                                                             attribute:NSLayoutAttributeCenterX
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self
                                                                                             attribute:NSLayoutAttributeCenterX
                                                                                            multiplier:1
                                                                                              constant:0];
        
        NSLayoutConstraint * errorMessageLabelCenterYConstraint=[NSLayoutConstraint constraintWithItem:_errorMessageLabel
                                                                                             attribute:NSLayoutAttributeCenterY
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self
                                                                                             attribute:NSLayoutAttributeCenterY
                                                                                            multiplier:1
                                                                                              constant:-35];
        
        [self addConstraints:@[errorMessageLabelHeightConstraint,errorMessageLabelCenterXConstraint,errorMessageLabelCenterYConstraint]];
        [self addConstraints:errorMessageLabelHConstraints];
        
        //确定按钮
        UIColor * ensureButtonColor=[ICEPlayerViewPublicDataHelper shareInstance].playerViewControlColor;
        CGFloat ensureButtonWidth=90;
        CGFloat ensureButtonHeight=30;
        self.ensureButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [_ensureButton addTarget:self action:@selector(goEnsure) forControlEvents:UIControlEventTouchUpInside];
        [_ensureButton setTitleColor:ensureButtonColor forState:UIControlStateNormal];
        [_ensureButton setBackgroundColor:[UIColor clearColor]];
        [_ensureButton setTitle:@"" forState:UIControlStateNormal];
        [_ensureButton.titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:14]];
        [_ensureButton.layer setMasksToBounds:YES];
        [_ensureButton.layer setBorderWidth:1.5];
        [_ensureButton.layer setBorderColor:ensureButtonColor.CGColor];
        [_ensureButton.layer setCornerRadius:ensureButtonHeight/2];
        [_ensureButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_ensureButton];
        
        NSLayoutConstraint * ensureButtonCenterXConstraint=[NSLayoutConstraint constraintWithItem:_ensureButton
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                       multiplier:1
                                                                                         constant:0];
        
        NSLayoutConstraint * ensureButtonWidthConstraint=[NSLayoutConstraint constraintWithItem:_ensureButton
                                                                                      attribute:NSLayoutAttributeWidth
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1
                                                                                       constant:ensureButtonWidth];
        
        NSArray * ensureButtonVConstraints=[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_errorMessageLabel]-hPadding-[_ensureButton(height)]"
                                                                                   options:0
                                                                                   metrics:@{@"hPadding":@20,@"height":@(ensureButtonHeight)}
                                                                                     views:NSDictionaryOfVariableBindings(_errorMessageLabel,_ensureButton)];
        
        [self addConstraints:@[ensureButtonCenterXConstraint,ensureButtonWidthConstraint]];
        [self addConstraints:ensureButtonVConstraints];
        
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

-(void)addToSuperViewAndaddConstraintsWithSuperView:(UIView *)superView
{
    [superView addSubview:self];
    
    NSDictionary * views=NSDictionaryOfVariableBindings(self);
    
    NSArray * hConstraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|[self]|"
                                                                   options:NSLayoutFormatAlignAllCenterX
                                                                   metrics:nil
                                                                     views:views];
    
    NSArray * vConstraints=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|"
                                                                   options:NSLayoutFormatAlignAllCenterY
                                                                   metrics:nil
                                                                     views:views];
    [superView addConstraints:hConstraints];
    [superView addConstraints:vConstraints];
}

-(void)setIsFullScreenDisplay:(BOOL)isFullScreen
{
    [_switchVSizeButton setHidden:!isFullScreen];
}

-(void)showErrorStateViewWithType:(ICEPlayerErrorStateType)errorStateType
{
    [self setHidden:NO];
    if (ICEPlayerNoNetWork==errorStateType)
    {
        [_errorMessageLabel setText:ErrorMessageNoNetWorkString];
        [_ensureButton setHidden:YES];
    }
    else if(ICEPlayerNoWIFI==errorStateType)
    {
        [_errorMessageLabel setText:ErrorMessageNoWIFIString];
        [_ensureButton setTitle:EnsureKeepWatching forState:UIControlStateNormal];
        [_ensureButton setTag:EnsureKeepWatchingTag];
        [_ensureButton setHidden:NO];
    }
    else
    {
        if (ICEPlayerVideoURLInValid==errorStateType)
        {
            [_errorMessageLabel setText:ErrorMessageVideoURLInValidString];
        }
        else if(ICEPlayerVideoLoadFailed==errorStateType)
        {
            [_errorMessageLabel setText:ErrorMessageVideoLoadFailedString];
        }
        else if(ICEPlayerNetWorkBusy==errorStateType)
        {
            [_errorMessageLabel setText:ErrorMessageNetWorkBusy];
        }
        [_ensureButton setTitle:EnsureRetry forState:UIControlStateNormal];
        [_ensureButton setTag:EnsureRetryTag];
        [_ensureButton setHidden:NO];
    }
}

-(void)hideErrorStateView
{
    if (![self isHidden])
    {
        [self setHidden:YES];
    }
}

-(void)goEnsure
{
    [self setHidden:YES];
    NSInteger buttonTag=_ensureButton.tag;
    if(EnsureKeepWatchingTag==buttonTag&&_noWIFIPlayVideoBlock)
    {
        _noWIFIPlayVideoBlock();
    }
    else if(EnsureRetryTag==buttonTag&&_retryBlock)
    {
        _retryBlock();
    }
}

-(void)goSwitchToVSize
{
    if (_switchPlayerViewOrientationBlock) {
        _switchPlayerViewOrientationBlock();
    }
}
@end
