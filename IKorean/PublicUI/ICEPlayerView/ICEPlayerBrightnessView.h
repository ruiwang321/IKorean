//
//  ICEPlayerBrightnessView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/8/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEPlayerBrightnessView : UIView
@property (nonatomic,assign) float brightness;

-(id)initWithBrightnessViewWidth:(CGFloat)brightnessViewWidth brightnessViewHeight:(CGFloat)brightnessViewHeight;

-(void)addToSuperViewAndaddConstraintsWithSuperView:(UIView *)superView;

@end
