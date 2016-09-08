//
//  ICESlideshowScrollView.h
//  GreatCar
//
//  Created by wangyunlong on 16/1/27.
//  Copyright © 2016年 yunlongwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICESlideshowPageView.h"
@interface ICESlideshowScrollView : UIView

-(id)initWithFrame:(CGRect)frame
placeholderImageName:(NSString *)imageName
   selectPageBlock:(SelectPageBlock)selectPageBlock;

-(void)setSlideshowScrollViewWithPageModels:(NSArray *)pageModels;

-(void)isStopScroll:(BOOL)isStop;
@end
