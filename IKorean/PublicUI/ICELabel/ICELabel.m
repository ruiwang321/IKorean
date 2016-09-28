//
//  ICELabel.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/13.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICELabel.h"

@interface ICELabel ()
@property (nonatomic,assign) UIEdgeInsets textInsets;
@end

@implementation ICELabel

- (id)initWithFrame:(CGRect)frame textInsets:(UIEdgeInsets)textInsets
{
    if (self=[super initWithFrame:frame])
    {
        _textInsets=textInsets;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect,_textInsets)];
}
@end
