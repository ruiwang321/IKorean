//
//  TVDetailTopUnitView.h
//  ICinema
//
//  Created by wangyunlong on 16/6/21.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface TVDetailTopUnitModel : NSObject
@property (nonatomic,assign) NSInteger movieID;
@property (nonatomic,assign) BOOL isCanPlay;
@property (nonatomic,assign) float grade;
@property (nonatomic,copy) NSString * imgUrl;
@property (nonatomic,copy) NSString * types;
@property (nonatomic,copy) NSString * source;
@property (nonatomic,copy) NSString * title;
@end

@interface TVDetailTopUnitView : UIView
-(id)initWithFrame:(CGRect)frame model:(TVDetailTopUnitModel *)model;
@end
