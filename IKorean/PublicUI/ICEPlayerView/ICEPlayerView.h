//
//  ICEPlayerView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ICEPlayerViewSelectEpisodesViewStyle) {
    SelectEpisodesViewTableViewStyle,
    SelectEpisodesViewCollectionViewStyle
};

typedef NS_ENUM(NSInteger,ICEPlayerViewVideoPlayReasons) {
    VideoPlayBecauseOfUserSelect,
    VideoPlayBecauseOfFirstLoadSuccessAutoPlay,
    VideoPlayBecauseOfPlayerViewReappearOrNetworkResolvedAutoPlay,
    VideoPlayBecauseOfBufferEnoughAutoPlay,
};

typedef NS_ENUM(NSInteger,ICEPlayerViewVideoPauseReasons) {
    VideoPauseBecauseOfUserSelect,
    VideoPauseBecauseOfNormalPlayLeadToBufferEmpty,
    VideoPauseBecauseOfAdjustProgressLeadToBufferEmpty,
    VideoPauseBecauseOfNetworkChanges,
    VideoPauseBecauseOfPlayerViewDisappearButNotDestroy,
    VideoPauseBecauseOfUnKnown
};

typedef NS_ENUM(NSInteger,ICEPlayerViewVideoEndReasons) {
    VideoEndBecauseOfNormalPlayToEnd,
    VideoEndBecauseOfVideoSwitch
};

typedef NS_ENUM(NSInteger,ICEPlayerViewVideoFailedReasons) {
    VideoFailedBecauseOfVideoURLInValid,
    VideoFailedBecauseOfVideoLoadFailed,
    VideoFailedBecauseOfNetWorkBusy
};

//通过block返回的所有model全是深copy后的，不要用指针判断是否相等

typedef void (^ICEPlayerViewWillRemoveCurrentPlayEpisodeModelsBlock)(NSArray * currentPlayEpisodeModels);

typedef void (^ICEPlayerViewVideoIsSelectedToPlayBlock)(ICEPlayerEpisodeModel * model);

typedef void (^ICEPlayerViewVideoPlayBlock)(ICEPlayerEpisodeModel * model,ICEPlayerViewVideoPlayReasons playReason);

typedef void (^ICEPlayerViewVideoPauseBlock)(ICEPlayerEpisodeModel * model,ICEPlayerViewVideoPauseReasons pauseReason);

typedef void (^ICEPlayerViewVideoEndBlock)(ICEPlayerEpisodeModel * model,ICEPlayerViewVideoEndReasons endReason);

typedef void (^ICEPlayerViewVideoFailedBlock)(ICEPlayerEpisodeModel * model,ICEPlayerViewVideoFailedReasons failedReasons);

typedef void (^ICEPlayerViewCollectVideoBlock)(ICEPlayerEpisodeModel * model);

typedef void (^ICEPlayerViewLockScreenBlock)(BOOL isLockScreen);

typedef void (^ICEPlayerViewEnsurePlayVideoNoWIFIBlock)();

typedef void (^ICEPlayerViewReturnBlock)();

@interface ICEPlayerView : UIView

@property (nonatomic,copy) ICEPlayerViewWillRemoveCurrentPlayEpisodeModelsBlock willRemoveCurrentPlayEpisodeModelsBlock;

@property (nonatomic,copy) ICEPlayerViewVideoIsSelectedToPlayBlock  videoIsSelectedToPlayBlock;

@property (nonatomic,copy) ICEPlayerViewVideoPlayBlock videoPlayBlock;

@property (nonatomic,copy) ICEPlayerViewVideoPauseBlock videoPauseBlock;

@property (nonatomic,copy) ICEPlayerViewVideoEndBlock videoEndBlock;

@property (nonatomic,copy) ICEPlayerViewVideoFailedBlock videoFailedBlock;

@property (nonatomic,copy) ICEPlayerViewCollectVideoBlock collectVideoBlock;

@property (nonatomic,copy) ICEPlayerViewLockScreenBlock lockScreenBlock;

@property (nonatomic,copy) ICEPlayerViewEnsurePlayVideoNoWIFIBlock ensurePlayVideoNoWIFIBlock;

@property (nonatomic,copy) ICEPlayerViewReturnBlock returnBlock;

-(id)initWithPlayerViewVFrame:(CGRect)vFrame HFrame:(CGRect)hFrame;

-(void)loadPlayerWithEpisodeModels:(NSArray *)episodeModels
            isNeedRemindUserNoWIFI:(BOOL)isNeedRemindUserNoWIFI
           selectEpisodesViewStyle:(ICEPlayerViewSelectEpisodesViewStyle)selectEpisodesViewStyle;

-(void)playWithEpisodeModel:(ICEPlayerEpisodeModel *)model;

-(void)setIsCollectCurrentVideo:(BOOL)isCollectCurrentVideo;

-(void)setIsNeedRemindUserNoWIFI:(BOOL)isNeedRemindUserNoWIFI;

-(void)playerViewDisappearWithIsDestroy:(BOOL)isDestroy;

-(void)playerViewAppear;

@end
