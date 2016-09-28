//
//  MovieDetailSwitchView.m
//  ICinema
//
//  Created by yunlongwang on 16/9/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieDetailSwitchView.h"
@interface MovieDetailSwitchView ()

@property (nonatomic,strong) UIView * colorView;
@property (nonatomic,strong) NSMutableArray * titleButtonsArray;
@property (nonatomic,strong) UIColor * normalTitleColor;
@property (nonatomic,assign) ICEButton * lastSelectButton;
@property (nonatomic,copy)void (^selectBlock)(NSInteger Index);

@end

@implementation MovieDetailSwitchView

-(id)initWithFrame:(CGRect)frame selectBlock:(void (^)(NSInteger Index))selectBlock
{
    if (self=[super initWithFrame:frame])
    {
        self.normalTitleColor=[[UIColor alloc] initWithRed:65.0f/255.0f green:65.0f/255.0f blue:65.0f/255.0f alpha:1];
        self.titleButtonsArray=[[NSMutableArray alloc] init];
        self.selectBlock=selectBlock;
    }
    return self;
}

-(void)setTitles:(NSArray *)titles
{
    for (ICEButton * titleButton in _titleButtonsArray)
    {
        [titleButton removeFromSuperview];
    }
    [_titleButtonsArray removeAllObjects];
    
    NSInteger buttonCount=[titles count];
    CGFloat buttonWidth=CGRectGetWidth(self.frame)/buttonCount;
    CGFloat buttonHeight=CGRectGetHeight(self.frame);
    CGRect  buttonBaseFrame=CGRectMake(0, 0, buttonWidth, buttonHeight);
    for (NSInteger Index=0; Index<buttonCount; Index++)
    {
        CGRect buttonFrame=buttonBaseFrame;
        buttonFrame.origin.x=Index*buttonWidth;
        ICEButton * titleButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [titleButton setTitle:titles[Index] forState:UIControlStateNormal];
        [titleButton.titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:16]];
        [titleButton setTitleColor:_normalTitleColor forState:UIControlStateNormal];
        [titleButton addTarget:self action:@selector(switchTitle:) forControlEvents:UIControlEventTouchUpInside];
        [titleButton setFrame:buttonFrame];
        [self addSubview:titleButton];
        [_titleButtonsArray addObject:titleButton];
    }
}

-(void)setIndex:(NSInteger)Index animated:(BOOL)animated
{
    if (Index<[_titleButtonsArray count])
    {
        ICEButton * currentSelectButton=_titleButtonsArray[Index];
        if (currentSelectButton!=_lastSelectButton)
        {
            [_lastSelectButton setTitleColor:_normalTitleColor forState:UIControlStateNormal];
            self.lastSelectButton=currentSelectButton;
            [_lastSelectButton setTitleColor:[[ICEAppHelper shareInstance] appPublicColor] forState:UIControlStateNormal];
            
            if (_colorView==nil)
            {
                CGFloat colorViewHeight=5;
                CGFloat colorViewWidth=70;
                CGFloat colorViewMinX=CGRectGetMinX(_lastSelectButton.frame)+(CGRectGetWidth(_lastSelectButton.frame)-colorViewWidth)/2;
                CGFloat colorViewMinY=CGRectGetHeight(self.frame)-colorViewHeight/2;
                self.colorView=[[UIView alloc] initWithFrame:CGRectMake(colorViewMinX,colorViewMinY , colorViewWidth, colorViewHeight)];
                [_colorView setBackgroundColor:[[ICEAppHelper shareInstance] appPublicColor]];
                [_colorView.layer setCornerRadius:colorViewHeight/2];
                [_colorView.layer setMasksToBounds:YES];
                [self addSubview:_colorView];
            }
            else
            {
                CGRect colorViewFrame=[_colorView frame];
                colorViewFrame.origin.x=CGRectGetMinX(_lastSelectButton.frame)+(CGRectGetWidth(_lastSelectButton.frame)-CGRectGetWidth(colorViewFrame))/2;
                if (animated)
                {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.25];
                    [_colorView setFrame:colorViewFrame];
                    [UIView commitAnimations];
                }
                else
                {
                    [_colorView setFrame:colorViewFrame];
                }
            }
        }
    }
}

-(void)switchTitle:(ICEButton *)button
{
    NSInteger Index=[_titleButtonsArray indexOfObject:button];
    if (NSNotFound!=Index)
    {
        if (_selectBlock) {
            _selectBlock(Index);
        }
    }
}
@end
