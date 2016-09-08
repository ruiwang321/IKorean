//
//  ICEButton.m
//  ICinema
//
//  Created by wangyunlong on 16/6/8.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEButton.h"
@interface ICEButton ()
@property (nonatomic,strong) UIImage * normalImage;
@property (nonatomic,strong) UIImage * highlightedImage;
@end

@implementation ICEButton

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self setExclusiveTouch:YES];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [self setBackgroundImage:[UIImage imageWithColor:backgroundColor size:self.frame.size] forState:state];
}

-(void)setNormalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage
{
    if (normalImage)
    {
        self.normalImage=normalImage;
    }
    if (highlightedImage)
    {
        self.highlightedImage=highlightedImage;
    }
    [self setIsHighlighted:NO];
}

-(void)setIsHighlighted:(BOOL)isHighlighted
{
    _isHighlighted=isHighlighted;
    if (_isHighlighted)
    {
        if (_highlightedImage)
        {
            [self setImage:_highlightedImage forState:UIControlStateNormal];
            [self setImage:_highlightedImage forState:UIControlStateHighlighted];
        }
    }
    else
    {
        if (_normalImage)
        {
            [self setImage:_normalImage forState:UIControlStateNormal];
            [self setImage:_normalImage forState:UIControlStateHighlighted];
        }
    }
}
@end
