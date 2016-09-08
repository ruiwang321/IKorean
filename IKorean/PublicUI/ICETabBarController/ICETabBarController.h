//
//  ICETabBarController.h
//  ICinema
//
//  Created by wangyunlong on 16/6/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ICETabBarItemModel : NSObject
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * normalStateImage;
@property (nonatomic,copy) NSString * selectedStateImage;
@end

@interface ICETabBar : UIView
@end

@interface ICETabBarController : UITabBarController
@property (nonatomic,strong,readonly) ICETabBar * myTabBar;
@end
