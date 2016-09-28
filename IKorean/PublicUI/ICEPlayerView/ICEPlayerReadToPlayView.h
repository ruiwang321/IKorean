//
//  ICEPlayerReadToPlayView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/5.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ICEDirectiveType) {
    ICEDirectiveForAdjustVolume,
    ICEDirectiveForAdjustProgress,
    ICEDirectiveForAdjustBrightness
};

@interface ICEPlayerReadToPlayView : UIView

@property (nonatomic,copy) void (^switchPlayerViewOrientationBlock)();

-(id)initWithVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame;

-(void)setIsFullScreenDisplay:(BOOL)isFullScreen;

-(void)startLoadingWithTitle:(NSString *)title;

-(void)stopLoading;

-(void)destroyLoading;

-(void)haveLearnedAdjust:(ICEDirectiveType)directiveType;

@end
