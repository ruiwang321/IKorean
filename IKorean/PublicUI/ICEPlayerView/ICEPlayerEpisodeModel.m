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
    [model setVideoID:_videoID];
    [model setSpareID:_spareID];
    [model setVideoName:_videoName];
    [model setEpisodeNumber:_episodeNumber];
    [model setUrl:_url];
    [model setIsPlay:_isPlay];
    [model setLastPlaySeconds:_lastPlaySeconds];
    [model setTotalSeconds:_totalSeconds];
    [model setTimeStamp:_timeStamp];
    return model;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"videoID=%@,spareID=%@,videoName=%@,episodeNumber=%@,url=%@,isPlay=%@,lastPlaySeconds=%@,totalSeconds=%@,timeStamp=%@",
            _videoID,_spareID,_videoName,_episodeNumber,_url,@(_isPlay),@(_lastPlaySeconds),@(_totalSeconds),@(_timeStamp)];
}
@end
