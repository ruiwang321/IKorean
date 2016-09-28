//
//  ICEPlayerErrorStateView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ICEPlayerErrorStateType) {
    ICEPlayerNoNetWork,
    ICEPlayerNetWorkBusy,
    ICEPlayerNoWIFI,
    ICEPlayerVideoURLInValid,
    ICEPlayerVideoLoadFailed
};

typedef void (^ErrorStateViewRetryBlock)();

typedef void (^ErrorStateViewNoWIFIPlayVideoBlock)();

@interface ICEPlayerErrorStateView : UIView

@property (nonatomic,copy) void (^switchPlayerViewOrientationBlock)();

@property (nonatomic,copy) ErrorStateViewNoWIFIPlayVideoBlock noWIFIPlayVideoBlock;

@property (nonatomic,copy) ErrorStateViewRetryBlock retryBlock;

-(void)addToSuperViewAndaddConstraintsWithSuperView:(UIView *)superView;

-(void)setIsFullScreenDisplay:(BOOL)isFullScreen;

-(void)showErrorStateViewWithType:(ICEPlayerErrorStateType)errorStateType;

-(void)hideErrorStateView;

@end
