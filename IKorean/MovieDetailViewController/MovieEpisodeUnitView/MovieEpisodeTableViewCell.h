//
//  MovieEpisodeTableViewCell.h
//  ICinema
//
//  Created by yunlongwang on 16/9/28.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICETableViewCell.h"
#import "MovieEpisodeModel.h"
@interface MovieEpisodeTableViewCell : ICETableViewCell
-(void)updateCellWithModel:(MovieEpisodeModel *)model;
@end
