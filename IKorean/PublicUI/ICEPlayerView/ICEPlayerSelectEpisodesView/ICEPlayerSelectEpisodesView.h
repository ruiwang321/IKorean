//
//  ICEPlayerSelectEpisodesView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/12.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEPlayerEpisodeModel.h"

typedef NS_ENUM(NSInteger, ICEPlayerSelectEpisodesViewStyle) {
    ICEPlayerSelectEpisodesViewTableViewStyle,
    ICEPlayerSelectEpisodesViewCollectionViewStyle
};

typedef void (^SelectEpisodesViewSelectBlock)(ICEPlayerEpisodeModel * model);

@interface ICEPlayerSelectEpisodesView : UIView

@property (nonatomic,copy) SelectEpisodesViewSelectBlock selectBlock;

-(id)initWithFrame:(CGRect)frame showMinX:(CGFloat)showMinX hideMinX:(CGFloat)hideMinX;

-(void)updateSelectEpisodesViewWithModels:(NSArray *)models style:(ICEPlayerSelectEpisodesViewStyle)style;

-(void)playEpisode;

@end
