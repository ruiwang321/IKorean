//
//  MyADView.h
//  ICinema
//
//  Created by wangyunlong on 16/9/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyImageADModel:NSObject
@property (nonatomic,copy) NSString * img;
@property (nonatomic,copy) NSString * url;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@end

@interface MyTextADModel : NSObject
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * url;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@end

@interface MyADView : UIView

-(id)initWithFrame:(CGRect)frame imageADModel:(MyImageADModel *)imageADModel;

-(id)initWithFrame:(CGRect)frame textADModel:(MyTextADModel *)textADModel;

@end
