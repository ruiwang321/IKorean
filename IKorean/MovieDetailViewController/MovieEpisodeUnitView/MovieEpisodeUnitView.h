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

typedef NS_ENUM(NSInteger,MovieEpisodeUnitViewLookMoreViewStyle) {
    LookMoreViewTableViewStyle,
    LookMoreViewCollectionViewStyle
};

@interface MovieEpisodeUnitView : UIView

-(id)initWithFrame:(CGRect)frame
             style:(MovieEpisodeUnitViewLookMoreViewStyle)style
            videos:(NSArray *)videos
        recommends:(NSArray *)recommends
selectEpisodeBlock:(void (^)(NSString * videoID))selectEpisodeBlock
selectMovieItemBlock:(MovieItemAction)selectMovieItemBlock;

-(void)playEpisodeWithVideoID:(NSString *)videoID;
@end
