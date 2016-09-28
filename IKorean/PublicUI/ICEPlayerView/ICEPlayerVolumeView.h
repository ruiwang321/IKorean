//
//  ICEPlayerVolumeView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/8/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEPlayerVolumeView : UIView

-(id)initWithVolumeViewWidth:(CGFloat)volumeViewWidth volumeViewHeight:(CGFloat)volumeViewHeight;

-(void)addToSuperViewAndaddConstraintsWithSuperView:(UIView *)superView;

-(void)setVolume:(float)volume;

-(float)getVolume;

@end
