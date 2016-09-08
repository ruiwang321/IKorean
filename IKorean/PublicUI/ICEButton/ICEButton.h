//
//  ICEButton.h
//  ICinema
//
//  Created by wangyunlong on 16/6/8.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEButton : UIButton

@property (nonatomic, assign) BOOL isHighlighted;

-(void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

-(void)setNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage;

@end
