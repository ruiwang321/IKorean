//
//  ICEPlayerTopView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ICEPlayerTopViewStyle) {
    ICEPlayerTopViewVerticalStyle,
    ICEPlayerTopViewHorizontalStyle
};

typedef NS_ENUM(NSInteger, ICEPlayerTopViewControlEvents) {
    ICEPlayerTopViewSwitchToVSizeEvent,
    ICEPlayerTopViewLockScreenEvent,
    ICEPlayerTopViewCollectEvent,
    ICEPlayerTopViewSelectEpisodeEvent
};

typedef void (^ICEPlayerTopViewControlEventBlock)(ICEPlayerTopViewControlEvents event);

@interface ICEPlayerTopView : UIView

@property (nonatomic,copy) ICEPlayerTopViewControlEventBlock controlEventBlock;

-(id)initWithTopViewVFrame:(CGRect)vFrame
                    HFrame:(CGRect)hFrame;

-(void)setTopViewStyle:(ICEPlayerTopViewStyle)topViewStyle;

-(void)setTitle:(NSString*)title;

-(void)setIsLockScreen:(BOOL)isLockScreen;

-(void)setIsCollected:(BOOL)isCollected;

-(void)setIsCanSelectEpisode:(BOOL)isCanSelectEpisode;

@end
