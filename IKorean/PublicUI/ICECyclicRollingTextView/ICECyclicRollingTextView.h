//
//  ICECyclicRollingTextView.h
//  TestVFLProject
//
//  Created by yunlongwang on 16/9/3.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICECyclicRollingTextView : UIView
-(id)initWithFrame:(CGRect)frame
              font:(UIFont *)font
         textColor:(UIColor *)textColor
         alignment:(NSTextAlignment)alignment
repeatTimeInterval:(NSTimeInterval)timeInterval;

-(void)setText:(NSString *)text;

-(void)startRolling;

-(void)stopRollingWithIsDestroy:(BOOL)isDestroy;

@end
