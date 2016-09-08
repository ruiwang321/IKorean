//
//  TVDataHelper.m
//  ICinema
//
//  Created by wangyunlong on 16/7/6.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "TVDataHelper.h"
#import "FMDatabase.h"
static TVDataHelper * tvDataHelper=nil;
@interface TVDataHelper ()
{
    FMDatabase * m_dataBase;
}
@property (nonatomic,copy) NSString * stringOfDBName;
@property (nonatomic,copy) NSString * stringOfVideoNewStatusTableName;
@property (nonatomic,copy) NSString * stringOfMyFavoritesTableName;
@property (nonatomic,copy) NSString * stringOfPlayHistoryTableName;
@property (nonatomic,copy) NSString * stringOfDBPath;
@end

@implementation TVDataHelper
+(TVDataHelper *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tvDataHelper=[[TVDataHelper alloc]init];
    });
    return tvDataHelper;
}

-(id)init
{
    if (self=[super init])
    {
        self.stringOfDBName=@"videoData";
        self.stringOfVideoNewStatusTableName=@"videoNewStatus";
        self.stringOfMyFavoritesTableName=@"myFavorites";
        self.stringOfPlayHistoryTableName=@"playHistory";
        self.stringOfDBPath=[[NSString alloc] initWithFormat:@"%@/Library/Caches/%@.db",NSHomeDirectory(),_stringOfDBName];
        m_dataBase=[[FMDatabase alloc] initWithPath:_stringOfDBPath];
        [m_dataBase open];
        [m_dataBase executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (episodeid INTEGER);",_stringOfVideoNewStatusTableName]];
        [m_dataBase executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (videoid INTEGER,image TEXT, title TEXT,grade REAL);",_stringOfMyFavoritesTableName]];
        [m_dataBase executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (videoid INTEGER,image TEXT, title TEXT,grade REAL);",_stringOfPlayHistoryTableName]];
    }
    return self;
}

-(BOOL)isFavoritesVideoWithVideoID:(NSNumber *)videoID
{
    BOOL isFavorites=NO;
    if ([m_dataBase open])
    {
        FMResultSet * rs=[m_dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE videoid = ?",
                                                   _stringOfMyFavoritesTableName],videoID];
        if ([rs next])
        {
            isFavorites=YES;
        }
        [rs close];
    }
    return isFavorites;
}


-(void)favoriteVideoWithVideoID:(NSNumber *)videoID
                       imageUrl:(NSString *)imageUrl
                          title:(NSString *)title
                          grade:(NSNumber *)grade
{
    if ([m_dataBase open])
    {
        [m_dataBase executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (videoid,image,title,grade) SELECT ?,?,?,? WHERE NOT EXISTS (SELECT * FROM %@ WHERE videoid = ?)",_stringOfMyFavoritesTableName,_stringOfMyFavoritesTableName],videoID,imageUrl,title,grade,videoID];
    }
}

-(void)cancelFavoriteVideoWithVideoID:(NSNumber *)videoID
{
    if ([m_dataBase open])
    {
        [m_dataBase executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE videoid=?",_stringOfMyFavoritesTableName],videoID];
    }
}


-(NSArray *)getMyFavorites
{
    NSMutableArray * array=[NSMutableArray array];
    FMResultSet    * rs=[m_dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",_stringOfMyFavoritesTableName]];
    while ([rs next])
    {
        NSDictionary * dicOfVideoData=@{
                                        @"grade":[rs stringForColumn:@"grade"],
                                        @"id":[rs stringForColumn:@"videoid"],
                                        @"img":[rs stringForColumn:@"image"],
                                        @"title":[rs stringForColumn:@"title"]
                                        };
        [array addObject:dicOfVideoData];
    }
    [rs close];
    return array;
}

-(BOOL)isPlayedVideoWithNewStateWithEpisodeID:(NSNumber *)episodeID
{
    BOOL isPlayed=NO;
    if ([m_dataBase open])
    {
        FMResultSet * rs=[m_dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE episodeid = ?",
                                                   _stringOfVideoNewStatusTableName],episodeID];
        if ([rs next])
        {
            isPlayed=YES;
        }
        [rs close];
    }
    return isPlayed;
}

-(void)playVideoWithNewStateWithEpisodeID:(NSNumber *)episodeID
{
    if ([m_dataBase open])
    {
        [m_dataBase executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (episodeid) SELECT ? WHERE NOT EXISTS (SELECT * FROM %@ WHERE episodeid=?)",_stringOfVideoNewStatusTableName,_stringOfVideoNewStatusTableName],episodeID,episodeID ];
    }
}

-(void)addPlayHistoryWithVideoID:(NSNumber *)videoID
                        imageUrl:(NSString *)imageUrl
                           title:(NSString *)title
                           grade:(NSNumber *)grade
{
    if ([m_dataBase open])
    {
        [m_dataBase executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (videoid,image,title,grade) SELECT ?,?,?,? WHERE NOT EXISTS (SELECT * FROM %@ WHERE videoid = ?)",_stringOfPlayHistoryTableName,_stringOfPlayHistoryTableName],videoID,imageUrl,title,grade,videoID];
    }
}

-(void)delatePlayHistoryWithVideoID:(NSNumber *)videoID
{
    if ([m_dataBase open])
    {
        [m_dataBase executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE videoid=?",_stringOfPlayHistoryTableName],videoID];
    }
}

-(NSArray *)getAllPlayHistory
{
    NSMutableArray * array=[NSMutableArray array];
    FMResultSet    * rs=[m_dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",_stringOfPlayHistoryTableName]];
    while ([rs next])
    {
        NSDictionary * dicOfVideoData=@{
                                        @"grade":[rs stringForColumn:@"grade"],
                                        @"id":[rs stringForColumn:@"videoid"],
                                        @"img":[rs stringForColumn:@"image"],
                                        @"title":[rs stringForColumn:@"title"]
                                        };
        [array addObject:dicOfVideoData];
    }
    [rs close];
    return array;
}
@end
