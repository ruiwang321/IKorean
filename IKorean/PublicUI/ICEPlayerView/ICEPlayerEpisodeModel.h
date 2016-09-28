//
//  ICEPlayerEpisodeModel.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICEPlayerEpisodeModel : NSObject

//用来获取url和区分视频的id，需要唯一，由用户赋值  link
@property (nonatomic,copy) NSString * videoID;
//备用id，播放器没有使用，留给外部类                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
@property (nonatomic,copy) NSString * spareID;
//所有类型的视频都会使用videoName,如果选集页的风格是TableView，videoName作为剧集标题在选集页中使用，由用户赋值 title
@property (nonatomic,copy) NSString * videoName;
//如果选集页的风格是CollectionView，episodeNumber作为剧集标题在选集页中使用，由用户赋值 seg
@property (nonatomic,copy) NSString * episodeNumber;
//视频播放地址（外部类不需要赋值）
@property (nonatomic,copy) NSString * url;
//上一次播放的时间（外部类不需要赋值）
@property (nonatomic,assign) NSTimeInterval lastPlaySeconds;
//视频总时长 (外部类不需要赋值）
@property (nonatomic,assign) NSTimeInterval totalSeconds;
//播放时的时间戳 (外部类不需要赋值)
@property (nonatomic,assign) NSTimeInterval timeStamp;
//是否播放（外部类不需要赋值）
@property (nonatomic,assign) BOOL isPlay;
@end
//model会在掉用loadplayer后被深拷贝到播放器中的数组中
