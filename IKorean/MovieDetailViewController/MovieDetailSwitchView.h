//
//  MovieDetailSwitchView.h
//  ICinema
//
//  Created by yunlongwang on 16/9/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieDetailSwitchView : UIView
-(id)initWithFrame:(CGRect)frame selectBlock:(void (^)(NSInteger Index))selectBlock;
-(void)setTitles:(NSArray *)titles;
-(void)setIndex:(NSInteger)Index animated:(BOOL)animated;
@end
