//
//  ICEPlayerTopView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ICEPlayerTopViewControlEvents) {
    ICEPlayerTopViewLockScreenEvent,
    ICEPlayerTopViewCollectEvent,
    ICEPlayerTopViewSelectEpisodeEvent
};

typedef void (^ICEPlayerTopViewControlEventBlock)(ICEPlayerTopViewControlEvents event);

@interface ICEPlayerTopView : UIView

@property (nonatomic,copy) ICEPlayerTopViewControlEventBlock controlEventBlock;

@property (nonatomic,copy) void (^switchPlayerViewOrientationBlock)();

@property (nonatomic,assign,readonly) BOOL isWillHide;

-(id)initWithVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame;

-(void)setIsFullScreenDisplay:(BOOL)isFullScreen;

-(void)setTitle:(NSString*)title;

-(void)setIsLockScreen:(BOOL)isLockScreen;

-(void)setIsCollected:(BOOL)isCollected;

-(void)setIsCanSelectEpisode:(BOOL)isCanSelectEpisode;

-(void)destroyRolling;

-(void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@end
