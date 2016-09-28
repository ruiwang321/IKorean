//
//  MovieDetailUnitView.h
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MovieDetailUnitViewModel:NSObject

@property (nonatomic,copy) NSString * videoName;
@property (nonatomic,copy) NSString * videoGrade;
@property (nonatomic,copy) NSString * videoShowTime;
@property (nonatomic,copy) NSString * videoDirector;
@property (nonatomic,copy) NSString * videoActor;
@property (nonatomic,copy) NSString * videoArea;
@property (nonatomic,copy) NSString * videoIntroduction;

@end

@interface MovieDetailUnitView : UIView
-(void)updateMovieDetailUnitViewWithModel:(MovieDetailUnitViewModel *)model;
@end
