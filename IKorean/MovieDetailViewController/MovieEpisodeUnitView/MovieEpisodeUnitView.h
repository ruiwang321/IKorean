//
//  MovieEpisodeUnitView.h
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieEpisodeCollectionViewCell.h"
#import "MovieEpisodeTableViewCell.h"
#import "MovieLookMoreEpisodeView.h"

typedef void(^SourceSelectedBlock)(NSString *);
@interface MovieEpisodeUnitView : UIView

-(id)initWithFrame:(CGRect)frame
             style:(MovieLookMoreEpisodeViewStyle)style
            videos:(NSDictionary *)videos
    selectedSource:(NSString *)selectedSouurce
        recommends:(NSArray *)recommends
selectEpisodeBlock:(void (^)(NSString * videoID))selectEpisodeBlock
selectMovieItemBlock:(MovieItemAction)selectMovieItemBlock
sourceSelectedBlock:(SourceSelectedBlock)sourceSelectedBlock
lookMoreEpisodeBlock:(void (^)(NSArray * episodeModelArray,MovieLookMoreEpisodeViewStyle style))lookMoreEpisodeBlock;

-(void)playEpisodeWithVideoID:(NSString *)videoID;
@end
