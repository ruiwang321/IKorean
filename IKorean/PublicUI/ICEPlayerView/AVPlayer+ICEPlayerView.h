//
//  AVPlayer+ICEPlayerView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/9.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

extern  NSString * const CurrentItemStatusKeyPath;
extern  NSString * const CurrentItemLoadedTimeRangesKeyPath;
extern  NSString * const PlayerRateKeyPath;

extern  NSTimeInterval const INVALIDSECONDS;

@interface AVPlayer (ICEPlayerView)

-(NSTimeInterval)currentItemTotalSeconds;

-(NSTimeInterval)currentItemCurrentSeconds;

-(NSTimeInterval)currentItemLoadSeconds;

-(void)currentItemCancelSeek;

-(BOOL)currentItemIsValid;

-(void)setCurrentItemWithPlayerItem:(AVPlayerItem *)item observer:(NSObject *)observer;

-(BOOL)isPlayNow;

-(BOOL)isCanPlayNow;
@end
