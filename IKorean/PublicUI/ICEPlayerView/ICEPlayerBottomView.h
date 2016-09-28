//
//  ICEPlayerBottomView.h
//  TestVFLProject
//
//  Created by yunlongwang on 16/8/28.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ICEPlayerBottomViewSliderEvents) {
    ICEPlayerBottomViewSliderAdjustProgressBegan,
    ICEPlayerBottomViewSliderAdjustProgressForward,
    ICEPlayerBottomViewSliderAdjustProgressReverse,
    ICEPlayerBottomViewSliderAdjustProgressEnd
};

typedef NS_ENUM(NSInteger, ICEPlayerBottomViewControlEvents) {
    ICEPlayerBottomViewControlPlayOrPause,
    ICEPlayerBottomViewControlLookNextEpisode
}; 

typedef void (^ICEPlayerBottomViewSliderEventBlock) (NSTimeInterval desiredSeconds,ICEPlayerBottomViewSliderEvents sliderEvent);

typedef void (^ICEPlayerBottomViewControlEventBlock)(ICEPlayerBottomViewControlEvents controlEvent);

@interface ICEPlayerBottomView : UIView


@property (nonatomic,copy) ICEPlayerBottomViewSliderEventBlock sliderEventBlock;

@property (nonatomic,copy) ICEPlayerBottomViewControlEventBlock controlEventBlock;

@property (nonatomic,copy) void (^switchPlayerViewOrientationBlock)();

-(id)initWithVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame;

-(void)setIsFullScreenDisplay:(BOOL)isFullScreen;

-(void)reloadWithTotalSeconds:(NSTimeInterval)totalSeconds;

-(void)updateBufferWithLoadSeconds:(NSTimeInterval)loadSeconds;

-(void)setProgressSeconds:(float)progressSeconds;

-(float)getProgressSeconds;

-(void)setIsPlay:(BOOL)isPlay;

-(BOOL)isAdjustProgress;

@end
