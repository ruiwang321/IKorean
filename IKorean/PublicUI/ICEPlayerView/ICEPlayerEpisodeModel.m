//
//  ICEPlayerEpisodeModel.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerEpisodeModel.h"

@implementation ICEPlayerEpisodeModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (id)copyWithZone:(NSZone *)zone
{
    ICEPlayerEpisodeModel * model=[[self class] allocWithZone:zone];
    model.videoID=_videoID;
    model.spareID=_spareID;
    model.videoName=_videoName;
    model.episodeNumber=_episodeNumber;
    model.lastPlaySeconds=_lastPlaySeconds;
    model.url=_url;
    model.isPlay=_isPlay;
    return model;
}

@end
