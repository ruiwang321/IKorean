//
//  ICEPageControl.h
//  GreatCar
//
//  Created by wangyunlong on 16/1/27.
//  Copyright © 2016年 yunlongwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEPageControl : UIView

-(id)initWithSuperViewSize:(CGSize)superViewSize;

-(void)setPageCount:(NSInteger)currentPageCount;

-(void)setCurrentPageIndex:(NSInteger)currentPageIndex;

@end
