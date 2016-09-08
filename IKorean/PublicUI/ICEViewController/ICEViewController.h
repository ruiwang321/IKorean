//
//  ICEViewController.h
//  ICinema
//
//  Created by wangyunlong on 16/6/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETabBarController.h"
@interface ICEViewController : UIViewController

@property (nonatomic,strong,readonly) ICETabBarItemModel * tabBarItemModel;
@property (nonatomic,assign,readonly) CGFloat screenWidth;
@property (nonatomic,assign,readonly) CGFloat screenHeight;
@property (nonatomic,assign,readonly) CGFloat navigationBarHeight;
@property (nonatomic,strong,readonly) UIView * myNavigationBar;

-(void)setTabBarItemWithTitle:(NSString *)title
              normalImageName:(NSString *)normalImageName
            selectedImageName:(NSString *)selectedImageName;

-(void)setLeftButtonWithImageName:(NSString *)imageName
                           action:(SEL)action;

-(void)setRightButtonWithImageName:(NSString *)imageName
                            action:(SEL)action;

-(void)showNetErrorAlert;

-(void)hideNetErrorAlert;

-(void)startLoading;

-(void)stopLoading;
@end
