//
//  MovieLookMoreEpisodeView.h
//  ICinema
//
//  Created by wangyunlong on 16/9/29.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MovieLookMoreEpisodeViewStyle) {
    LookMoreViewTableViewStyle,
    LookMoreViewCollectionViewStyle
};

@interface MovieLookMoreEpisodeView : UIView

-(id)initWithFrame:(CGRect)frame
             style:(MovieLookMoreEpisodeViewStyle)style
     episodeModels:(NSArray *)episodeModels
selectEpisodeBlock:(void (^)(NSString * videoID))selectEpisodeBlock;

-(void)showLookMoreEpisodeView;

-(void)hideLookMoreEpisodeView;

-(void)reloadLookMoreEpisodeView;

@end
