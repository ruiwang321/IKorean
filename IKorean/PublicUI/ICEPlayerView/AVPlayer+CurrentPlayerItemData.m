//
//  AVPlayer+CurrentPlayerItemData.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/3.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "AVPlayer+CurrentPlayerItemData.h"

@implementation AVPlayer (CurrentPlayerItemData)

-(BOOL)currentItemIsValid
{
    BOOL isValid=FALSE;
    AVPlayerItem * currentPlayerItem=self.currentItem;
    if (currentPlayerItem&&(AVPlayerItemStatusReadyToPlay==currentPlayerItem.status))
    {
        isValid=TRUE;
    }
    return isValid;
}

-(NSTimeInterval)currentItemTotalSeconds
{
    NSTimeInterval totalSeconds=-1000;
    if ([self currentItemIsValid])
    {
        CMTime totalTime=self.currentItem.duration;
        if (CMTIME_IS_VALID(totalTime))
        {
            totalSeconds=CMTimeGetSeconds(totalTime);
        }
    }
    return totalSeconds;
}

-(NSTimeInterval)currentItemCurrentSeconds
{
    NSTimeInterval currentSeconds=0;
    if ([self currentItemIsValid])
    {
        CMTime currentTime=self.currentItem.currentTime;
        if (CMTIME_IS_VALID(currentTime))
        {
            currentSeconds=CMTimeGetSeconds(currentTime);
        }
    }
    return currentSeconds;
}

-(NSTimeInterval)currentItemLoadSeconds
{
    NSTimeInterval loadSeconds=0;
    if ([self currentItemIsValid])
    {
        AVPlayerItem * currentPlayerItem=self.currentItem;
        NSArray * timeRanges = currentPlayerItem.loadedTimeRanges;
        if (timeRanges&&[timeRanges count])
        {
            CMTimeRange firstTimeRange = [timeRanges.firstObject CMTimeRangeValue];
            if (CMTIMERANGE_IS_VALID(firstTimeRange))
            {
                float startSeconds = CMTimeGetSeconds(firstTimeRange.start);
                float durationSeconds = CMTimeGetSeconds(firstTimeRange.duration);
                loadSeconds = startSeconds + durationSeconds;
            }
        }
    }
    return loadSeconds;
}

@end
