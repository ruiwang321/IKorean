//
//  AVPlayer+ICEPlayerView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/9.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "AVPlayer+ICEPlayerView.h"

#define SULPLUSSECONDS  10

NSTimeInterval const INVALIDSECONDS=-1234;

NSString * const CurrentItemStatusKeyPath=@"status";
NSString * const CurrentItemLoadedTimeRangesKeyPath=@"loadedTimeRanges";
NSString * const CurrentItemBufferFullKeyPath=@"playbackBufferFull";
NSString * const CurrentItemBufferEmptyKeyPath=@"playbackBufferEmpty";
NSString * const CurrentItemBufferLikelyToKeepUp=@"playbackLikelyToKeepUp";
NSString * const PlayerRateKeyPath=@"rate";

@implementation AVPlayer (ICEPlayerView)
-(BOOL)currentItemIsValid
{
    BOOL isValid=NO;
    AVPlayerItem * currentPlayerItem=self.currentItem;
    if (currentPlayerItem&&(AVPlayerItemStatusReadyToPlay==currentPlayerItem.status))
    {
        isValid=YES;
    }
    return isValid;
}

-(NSTimeInterval)currentItemTotalSeconds
{
    NSTimeInterval totalSeconds=INVALIDSECONDS;
    CMTime totalTime=self.currentItem.duration;
    if (CMTIME_IS_VALID(totalTime))
    {
       NSTimeInterval currentItemTotalSeconds=CMTimeGetSeconds(totalTime);
        if (!isnan(currentItemTotalSeconds)&&!isinf(currentItemTotalSeconds)&&currentItemTotalSeconds>0)
        {
            totalSeconds=currentItemTotalSeconds;
        }
    }
    return totalSeconds;
}

-(NSTimeInterval)currentItemCurrentSeconds
{
    NSTimeInterval currentSeconds=INVALIDSECONDS;
    CMTime currentTime=self.currentItem.currentTime;
    if (CMTIME_IS_VALID(currentTime))
    {
        NSTimeInterval currentItemCurrentSeconds=CMTimeGetSeconds(currentTime);
        if (!isnan(currentItemCurrentSeconds)&&!isinf(currentItemCurrentSeconds)&&currentItemCurrentSeconds>=0)
        {
            currentSeconds=currentItemCurrentSeconds;
        }
    }
    return currentSeconds;
}

-(NSTimeInterval)currentItemLoadSeconds
{
    NSTimeInterval loadSeconds=INVALIDSECONDS;
    NSArray * timeRanges = self.currentItem.loadedTimeRanges;
    CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
    if (CMTIMERANGE_IS_VALID(timeRange)&&
      !((CMTIME_IS_INDEFINITE(timeRange.start)||CMTIME_IS_INDEFINITE(timeRange.duration))&&
      !(CMTIME_COMPARE_INLINE(timeRange.duration, ==, kCMTimeZero))))
    {
        NSTimeInterval currentItemLoadSeconds=CMTimeGetSeconds(CMTimeRangeGetEnd(timeRange));
        if (!isnan(currentItemLoadSeconds)&&!isinf(currentItemLoadSeconds)&&currentItemLoadSeconds>=0) {
            loadSeconds=currentItemLoadSeconds;
        }
    }
    return loadSeconds;
}

-(void)playerItem:(AVPlayerItem *)item addObserver:(NSObject *)observer
{
    if (item)
    {
        [item addObserver:observer forKeyPath:CurrentItemStatusKeyPath options:NSKeyValueObservingOptionOld context:nil];
        [item addObserver:observer forKeyPath:CurrentItemLoadedTimeRangesKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [item addObserver:observer forKeyPath:CurrentItemBufferLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void)playerItem:(AVPlayerItem *)item removeObserver:(NSObject *)observer
{
    if (item)
    {
        [item.asset cancelLoading];
        [item cancelPendingSeeks];
        [item removeObserver:observer forKeyPath:CurrentItemStatusKeyPath];
        [item removeObserver:observer forKeyPath:CurrentItemLoadedTimeRangesKeyPath];
        [item removeObserver:observer forKeyPath:CurrentItemBufferLikelyToKeepUp];
    }
}

-(void)setCurrentItemWithPlayerItem:(AVPlayerItem *)item observer:(NSObject *)observer
{
    [self playerItem:self.currentItem removeObserver:observer];
    [self playerItem:item addObserver:observer];
    [self replaceCurrentItemWithPlayerItem:item];
}

-(BOOL)isPlayNow
{
    return self.rate?YES:NO;
}

-(BOOL)isCanPlayNow
{
    BOOL isCanPlayNow=NO;
    if ([self currentItemIsValid])
    {
        NSTimeInterval currentSeconds=[self currentItemCurrentSeconds];
        NSTimeInterval loadSeconds=[self currentItemLoadSeconds];
        //NSLog(@"current=%@,load=%@,keepUP=%@,empty=%@",@(currentSeconds),@(loadSeconds),@(self.currentItem.isPlaybackLikelyToKeepUp),@(self.currentItem.isPlaybackBufferEmpty));
        if (loadSeconds!=INVALIDSECONDS&&
            currentSeconds!=INVALIDSECONDS)
        {
            NSTimeInterval totalSeconds=[self currentItemTotalSeconds];
            //buffer必须比当前已经播放的时间＋SULPLUSSECONDS秒还要大。这个SULPLUSSECONDS可以自己根据情况调整
            NSTimeInterval minCanPlayLoadSeconds=currentSeconds+SULPLUSSECONDS;
            if (minCanPlayLoadSeconds>=totalSeconds)
            {
                minCanPlayLoadSeconds=currentSeconds;
            }
            if (loadSeconds>=minCanPlayLoadSeconds&&self.currentItem.isPlaybackLikelyToKeepUp)
            {
                isCanPlayNow=YES;
            }
        }
    }
    return isCanPlayNow;
}
@end
