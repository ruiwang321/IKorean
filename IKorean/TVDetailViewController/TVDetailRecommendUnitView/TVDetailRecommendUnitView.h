//
//  TVDetailRecommendUnitView.h
//  ICinema
//
//  Created by yunlongwang on 16/7/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieItem.h"

@interface TVDetailRecommendUnitView : UIView
-(id)initWithFrame:(CGRect)frame
   recommendVideos:(NSArray *)recommendVideos
selectSomeMovieItemBlock:(MovieItemAction)selectblock;
@end
