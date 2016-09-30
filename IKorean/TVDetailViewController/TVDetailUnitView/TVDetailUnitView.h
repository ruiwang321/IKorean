//
//  TVDetailUnitView.h
//  ICinema
//
//  Created by wangyunlong on 16/6/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVDetailUnitView : UIView
-(id)initWithFrame:(CGRect)frame
          director:(NSString *)director
             actor:(NSString *)actor
              area:(NSString *)area
          showtime:(NSString *)showtime;
@end
