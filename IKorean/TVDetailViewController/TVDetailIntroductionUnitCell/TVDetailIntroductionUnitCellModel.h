//
//  TVDetailIntroductionUnitCellModel.h
//  ICinema
//
//  Created by yunlongwang on 16/7/8.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVDetailIntroductionUnitCellModel : NSObject

@property (nonatomic,assign,readonly) CGRect grayViewFrame;
@property (nonatomic,assign,readonly) CGRect blueImageFrame;
@property (nonatomic,assign,readonly) CGRect titleLabelFrame;
@property (nonatomic,assign,readonly) BOOL isCanExpand;
@property (nonatomic,assign) BOOL isExpand;
@property (nonatomic,assign,readonly) CGRect expandButtonFrame;
@property (nonatomic,weak,readonly) NSAttributedString * expandButtonTitle;
@property (nonatomic,copy,readonly) NSAttributedString * introductionString;
@property (nonatomic,assign,readonly) CGRect introductionLabelFrame;
@property (nonatomic,assign,readonly) CGFloat cellHeight;


-(id)initWithIntroduction:(NSString *)introduction
                cellWidth:(CGFloat)cellWidth;
@end
