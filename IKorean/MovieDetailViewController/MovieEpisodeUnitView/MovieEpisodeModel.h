//
//  MovieEpisodeModel.h
//  ICinema
//
//  Created by wangyunlong on 16/9/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieEpisodeModel : NSObject
@property (nonatomic,copy) NSString * videoID;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,assign) BOOL isNew;
@property (nonatomic,assign) BOOL isPlay;
@end
