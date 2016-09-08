//
//  ICEPageControl.m
//  GreatCar
//
//  Created by wangyunlong on 16/1/27.
//  Copyright © 2016年 yunlongwang. All rights reserved.
//

#import "ICEPageControl.h"
#define ICEPagePointWidth        8
#define ICEPagePointPadding      6
#define ICEPageControlHeight     15
#define ICEPageControlButtomToSuperViewPadding  17
#define ICEPageControlPaddingFromeMaxXToSuperViewMaxX  26
@interface ICEPageControl ()

@property (nonatomic,assign) CGFloat superViewWidth;
@property (nonatomic,assign) CGFloat superViewHeight;
@property (nonatomic,assign) CGFloat pageControlMinY;
@property (nonatomic,assign) CGFloat pagePointMinY;
@property (nonatomic,strong) UIColor * normalColor;
@property (nonatomic,strong) UIColor * selectedColor;
@property (nonatomic,strong) NSMutableArray * pagePointArray;
@property (nonatomic,strong) UIView * pagePointBackGroundView;
@property (nonatomic,strong) UIView * currentPagePoint;

@end

@implementation ICEPageControl

-(id)initWithSuperViewSize:(CGSize)superViewSize
{
    if (self=[super init])
    {
        [self setUserInteractionEnabled:NO];
        _superViewWidth=superViewSize.width;
        _superViewHeight=superViewSize.height;
        _pageControlMinY=_superViewHeight-ICEPageControlButtomToSuperViewPadding-ICEPageControlHeight;
        _pagePointMinY=(ICEPageControlHeight-ICEPagePointWidth)/2;
        self.normalColor=[[UIColor alloc] initWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1];
        self.selectedColor=[ICEAppHelper shareInstance].appPublicColor;
        self.pagePointArray=[[NSMutableArray alloc]init];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    }
    return self;
}

-(UIView *)pagePointWithIsNormal:(BOOL)isNormal
{
    UIColor * pagePointColor = isNormal?_normalColor:_selectedColor;
    UIView  * pagePoint = [[UIView alloc] init];
    [pagePoint setBackgroundColor:pagePointColor];
    pagePoint.layer.cornerRadius=ICEPagePointWidth/2;
    pagePoint.layer.masksToBounds=YES;
    return pagePoint;
}

-(void)addOrUpdateBackGroundViewWithPageCount:(NSInteger)pageCount
{
    CGFloat pageControlWidth = pageCount*ICEPagePointWidth+(pageCount+1)*ICEPagePointPadding;
    CGFloat pageControlMinX = _superViewWidth-pageControlWidth-ICEPageControlPaddingFromeMaxXToSuperViewMaxX;
    CGRect  pageControlFrame = CGRectMake(pageControlMinX, _pageControlMinY, pageControlWidth, ICEPageControlHeight);
    [self setFrame:pageControlFrame];
    
    if (_pagePointBackGroundView==nil)
    {
        self.pagePointBackGroundView=[[UIView alloc] init];
        [_pagePointBackGroundView setBackgroundColor:[UIColor whiteColor]];
        [_pagePointBackGroundView setAlpha:0.5];
        [_pagePointBackGroundView.layer setCornerRadius:ICEPageControlHeight/2];
        [_pagePointBackGroundView.layer setMasksToBounds:YES];
        [self addSubview:_pagePointBackGroundView];
    }
    [_pagePointBackGroundView setFrame:self.bounds];
}

-(void)setPageCount:(NSInteger)currentPageCount
{
    if (currentPageCount>0)
    {
        [self setHidden:NO];
        
        [self addOrUpdateBackGroundViewWithPageCount:currentPageCount];
        
        NSInteger alreadyExistsPagePointCount=[_pagePointArray count];
        
        if (currentPageCount>alreadyExistsPagePointCount)
        {
            //如果当前的page数量比原来的多，需要创建新的数据
            for (NSInteger Index=alreadyExistsPagePointCount; Index<currentPageCount; Index++)
            {
                UIView * pagePoint=[self pagePointWithIsNormal:YES];
                [self insertSubview:pagePoint atIndex:0];
                [_pagePointArray addObject:pagePoint];
            }
        }
        
        alreadyExistsPagePointCount=[_pagePointArray count];
        
        NSInteger Index=0;
        
        CGRect pagePointBaseFrame=CGRectMake(0, _pagePointMinY, ICEPagePointWidth, ICEPagePointWidth);
        for (; Index<currentPageCount; Index++)
        {
            CGRect pagePointFrame=pagePointBaseFrame;
            pagePointFrame.origin.x=ICEPagePointPadding+Index*(ICEPagePointPadding+ICEPagePointWidth);
            UIView * pagePoint=_pagePointArray[Index];
            [pagePoint setFrame:pagePointFrame];
            [pagePoint setHidden:NO];
        }
        
        for (; Index<alreadyExistsPagePointCount; Index++)
        {
            UIView * pagePoint=_pagePointArray[Index];
            [pagePoint setHidden:YES];
        }
        [self setCurrentPageIndex:0];
    }
    else
    {
        [self setHidden:YES];
    }
}

-(void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    NSInteger alreadyExistsPagePointCount=[_pagePointArray count];
    if (currentPageIndex<alreadyExistsPagePointCount)
    {
        if (_currentPagePoint==nil)
        {
            self.currentPagePoint=[self pagePointWithIsNormal:NO];
            [self addSubview:_currentPagePoint];
        }
        [self bringSubviewToFront:_currentPagePoint];
        UIView * pagePoint=_pagePointArray[currentPageIndex];
        [_currentPagePoint setFrame:pagePoint.frame];
    }
}

@end
