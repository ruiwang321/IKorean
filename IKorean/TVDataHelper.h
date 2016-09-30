//
//  TVDataHelper.h
//  ICinema
//
//  Created by wangyunlong on 16/7/6.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@interface TVDataHelper : NSObject
+(TVDataHelper *)shareInstance;

-(BOOL)isFavoritesVideoWithVideoID:(NSNumber *)videoID;

-(void)favoriteVideoWithVideoID:(NSNumber *)videoID
                       imageUrl:(NSString *)imageUrl
                          title:(NSString *)title
                     updateinfo:(NSString *)updateinfo;

-(void)cancelFavoriteVideoWithVideoID:(NSNumber *)videoID;

-(NSArray *)getMyFavorites;

-(BOOL)isPlayedVideoWithNewStateWithEpisodeID:(NSNumber *)episodeID;

-(void)playVideoWithNewStateWithEpisodeID:(NSNumber *)episodeID;

-(void)addPlayHistoryWithVideoID:(NSNumber *)videoID
                        imageUrl:(NSString *)imageUrl
                           title:(NSString *)title
                      sourceName:(NSString *)sourceName
                     totalSecond:(NSNumber *)totalSecond
                  lastPlaySecond:(NSNumber *)lastPlaySecond
                       timeStamp:(NSNumber *)timeStamp
                   episodeNumber:(NSString *)episodeNumber;

-(void)delatePlayHistoryWithVideoID:(NSNumber *)videoID;

-(NSArray *)getAllPlayHistory;


-(NSArray *)getAllSearchHistory;
-(void)delateAllSearchHistory;
-(void)addSearchHistoryKeyword:(NSString *)keyword;
@end
