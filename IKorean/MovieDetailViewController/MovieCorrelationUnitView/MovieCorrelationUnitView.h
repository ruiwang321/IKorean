//
//  MovieCorrelationUnitView.h
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCorrelationUnitView : UIView

-(id)initWithFrame:(CGRect)frame
        recommends:(NSArray *)recommends
       selectBlock:(MovieItemAction)selectBlock;

@end
