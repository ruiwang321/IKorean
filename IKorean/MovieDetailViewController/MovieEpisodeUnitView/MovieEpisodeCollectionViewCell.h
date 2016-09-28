//
//  MovieEpisodeCollectionViewCell.h
//  ICinema
//
//  Created by wangyunlong on 16/9/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieEpisodeModel.h"
@interface MovieEpisodeCollectionViewCell : UICollectionViewCell

-(void)updateCellWithModel:(MovieEpisodeModel *)model;
@end
