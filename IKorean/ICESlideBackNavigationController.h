//
//  ICESlideBackNavigationController.h
//  PlayerViewDemo
//
//  Created by wangyunlong on 16/9/20.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ICESlideBackNavigationControllerDelegate <NSObject>
- (BOOL)isSupportSlidePop;
@end

@interface ICESlideBackNavigationController : UINavigationController
+(void)clearAllSnapshot;
@end
