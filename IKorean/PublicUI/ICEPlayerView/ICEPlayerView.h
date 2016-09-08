//
//  ICEPlayerView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEPlayerEpisodeModel.h"

typedef NS_ENUM(NSInteger,ICEPlayerViewPlayStateOptions) {
    ICEPlayerViewWillBeganPlay,
    ICEPlayerViewDidBeganPlay,
    ICEPlayerViewDidPausePlay,
    ICEPlayerViewDidEndPlay
};

typedef void (^ICEPlayerViewPlayStateBlock)(ICEPlayerViewPlayStateOptions state,ICEPlayerEpisodeModel * model);

typedef void (^ICEPlayerViewCollectVideoBlock)(ICEPlayerEpisodeModel * model);

typedef void (^ICEPlayerViewLockScreenBlock)(BOOL isLockScreen);

typedef void (^ICEPlayerViewReturnBlock)();

@interface ICEPlayerView : UIView

@property (nonatomic,copy) ICEPlayerViewPlayStateBlock  playStateBlock;

@property (nonatomic,copy) ICEPlayerViewCollectVideoBlock collectVideoBlock;

@property (nonatomic,copy) ICEPlayerViewLockScreenBlock lockScreenBlock;

@property (nonatomic,copy) ICEPlayerViewReturnBlock returnBlock;

-(id)initWithPlayerViewVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame;

-(void)loadPlayerWithEpisodeModels:(NSArray *)episodeModels;

-(void)loadPlayerWithEpisodeModel:(ICEPlayerEpisodeModel *)episodeModel;

@end
