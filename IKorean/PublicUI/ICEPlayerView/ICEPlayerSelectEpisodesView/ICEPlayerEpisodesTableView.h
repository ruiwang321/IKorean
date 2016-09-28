//
//  ICEPlayerEpisodesTableView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/13.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEPlayerEpisodesTableView : UIView

@property (nonatomic,copy)void (^selectEpisodeBlock)(ICEPlayerEpisodeModel * model);

-(void)updateWithModels:(NSArray *)models;

-(void)playEpisode;

@end
