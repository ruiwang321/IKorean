//
//  MovieItemCellLayoutHelper.h
//  ICinema
//
//  Created by wangyunlong on 16/7/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieItemCellLayoutHelper : NSObject

@property (nonatomic,assign,readonly) CGFloat itemCountInCell;
@property (nonatomic,assign,readonly) CGFloat movieItemPaddingH;
@property (nonatomic,assign,readonly) CGRect  movieItemOriginFrame;
@property (nonatomic,assign,readonly) CGFloat cellWidth;
@property (nonatomic,assign,readonly) CGFloat cellHeight;

+(MovieItemCellLayoutHelper *)shareInstance;

@end
