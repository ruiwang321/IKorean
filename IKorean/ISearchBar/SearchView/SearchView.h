//
//  SearchView.h
//  ICinema
//
//  Created by yunlongwang on 16/7/31.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SearchView : UIView
-(id)initWithFrame:(CGRect)frame
  selectMovieBlock:(void (^)(NSInteger ,NSString * ))selectBlock;
@end
