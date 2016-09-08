//
//  ICEPlayerBottomView.h
//  TestVFLProject
//
//  Created by yunlongwang on 16/8/28.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ICEPlayerBottomViewStyle) {
    ICEPlayerBottomViewVerticalStyle,
    ICEPlayerBottomViewHorizontalStyle
};

typedef NS_ENUM(NSInteger, ICEPlayerBottomViewSliderEvents) {
    ICEPlayerBottomViewSliderAdjustProgressBegan,
    ICEPlayerBottomViewSliderAdjustProgressForward,
    ICEPlayerBottomViewSliderAdjustProgressReverse,
    ICEPlayerBottomViewSliderAdjustProgressEnd
};

typedef NS_ENUM(NSInteger, ICEPlayerBottomViewControlEvents) {
    ICEPlayerBottomViewControlPlayOrPause,
    ICEPlayerBottomViewControlSwitchSize,
    ICEPlayerBottomViewControlLookNextEpisode
}; 

typedef void (^ICEPlayerBottomViewSliderEventBlock) (NSTimeInterval desiredSeconds,ICEPlayerBottomViewSliderEvents sliderEvent);

typedef void (^ICEPlayerBottomViewControlEventBlock)(ICEPlayerBottomViewControlEvents controlEvent);

@interface ICEProgressSliderEventModel:NSObject

@property (nonatomic,assign,readonly) float value;

@property (nonatomic,assign,readonly) ICEPlayerBottomViewSliderEvents event;

@end

@interface ICEPlayerBottomView : UIView

@property (nonatomic,strong,readonly) ICEProgressSliderEventModel * sliderEventModel;

@property (nonatomic,copy) ICEPlayerBottomViewSliderEventBlock sliderEventBlock;

@property (nonatomic,copy) ICEPlayerBottomViewControlEventBlock controlEventBlock;

-(id)initWithBottomViewVFrame:(CGRect)vFrame
                       HFrame:(CGRect)hFrame;

-(void)setBottomViewStyle:(ICEPlayerBottomViewStyle)bottomViewStyle;

-(void)reloadWithCurrentSeconds:(NSTimeInterval)currentSeconds
                   totalSeconds:(NSTimeInterval)totalSeconds;

-(void)updateProgressWithDesiredSeconds:(NSTimeInterval)desiredSeconds;

-(void)updateBufferWithLoadSeconds:(NSTimeInterval)loadSeconds;

-(void)setIsPlay:(BOOL)isPlay;

@end
