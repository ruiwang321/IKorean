//
//  ICEAppGuideView.m
//  GameCircle
//
//  Created by wangyunlong on 15/10/9.
//  Copyright © 2015年 wangyunlong. All rights reserved.
//

#import "ICEAppGuideView.h"
////////////////////////////ICEAppGuidePageControl////////////////////////////
@interface ICEAppGuidePageControl : UIView

@property (nonatomic,strong)UIImageView * selectedPagePoint;
@property (nonatomic,strong)NSMutableArray * pagePointsArray;

-(id)initWithFrame:(CGRect)frame
         pageCount:(NSInteger)pageCount
  pagePointPadding:(CGFloat)pagePointPadding
normalPagePointImageName:(NSString *)normalPagePointImageName
selectedPagePointImageName:(NSString *)selectedPagePointImageName;


-(void)setCurrentPageWithIndex:(NSInteger)pageIndex;

@end

@implementation ICEAppGuidePageControl

-(id)initWithFrame:(CGRect)frame
         pageCount:(NSInteger)pageCount
  pagePointPadding:(CGFloat)pagePointPadding
normalPagePointImageName:(NSString *)normalPagePointImageName
selectedPagePointImageName:(NSString *)selectedPagePointImageName
{
    if (self=[super initWithFrame:frame])
    {
        UIImage * normalPagePointImage=IMAGENAME(normalPagePointImageName, @"png");
        CGFloat normalPagePointImageWidth = normalPagePointImage.size.width;
        CGFloat normalPagePointImageHeight = normalPagePointImage.size.height;
        
        UIImage * selectedPagePointImage=IMAGENAME(selectedPagePointImageName, @"png");
        CGFloat selectedPagePointImageWidth=selectedPagePointImage.size.width;
        CGFloat selectedPagePointImageHeight=selectedPagePointImage.size.height;
        
        CGFloat pagePointToTopPadding=(CGRectGetHeight(frame)-normalPagePointImageHeight)/2;
        CGFloat firstPagePointMinX=(CGRectGetWidth(frame)-pageCount*normalPagePointImageWidth-(pageCount-1)*pagePointPadding)/2;
        
        self.pagePointsArray=[[NSMutableArray alloc] initWithCapacity:pageCount];
        CGRect pagePointBaseFrame=CGRectMake(0, pagePointToTopPadding, normalPagePointImageWidth, normalPagePointImageHeight);
        
        for (NSInteger Index=0; Index<pageCount; Index++)
        {
            CGRect pagePointFrame=pagePointBaseFrame;
            pagePointFrame.origin.x=firstPagePointMinX+Index*(pagePointPadding+normalPagePointImageWidth);
            
            UIImageView * pagePoint=[[UIImageView alloc] initWithImage:normalPagePointImage];
            [pagePoint setFrame:pagePointFrame];
            [self addSubview:pagePoint];
            [_pagePointsArray addObject:pagePoint];
        }
        
        self.selectedPagePoint=[[UIImageView alloc] initWithImage:selectedPagePointImage];
        [_selectedPagePoint setFrame:CGRectMake(0, 0, selectedPagePointImageWidth, selectedPagePointImageHeight)];
        [self addSubview:_selectedPagePoint];
        [_selectedPagePoint setHidden:YES];
    }
    return self;
}

-(void)setCurrentPageWithIndex:(NSInteger)pageIndex
{
    [_selectedPagePoint setHidden:NO];
    UIImageView * pagePoint=[_pagePointsArray objectAtIndex:pageIndex];
    [_selectedPagePoint setCenter:pagePoint.center];
}
@end

////////////////////////////ICEAppGuideView////////////////////////////
@interface ICEAppGuideView ()
<
UIScrollViewDelegate
>
@property (nonatomic,strong) ICEAppGuidePageControl * pageControl;
@end

@implementation ICEAppGuideView
+(BOOL)isDisplayedAppGuideView
{
    BOOL isHaveDisplayed=NO;
    NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
    NSNumber * isDisplayed=[userDefaults objectForKey:keyOfAppGuideVersion];
    if (isDisplayed)
    {
        isHaveDisplayed=[isDisplayed boolValue];
    }
    return isHaveDisplayed;
}

+(void)saveAppGuideViewStatus
{
    NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSNumber numberWithBool:YES] forKey:keyOfAppGuideVersion];
    [userDefaults synchronize];
}

-(id)init
{
    if (self=[super initWithFrame:[[UIScreen mainScreen] bounds]])
    {
        NSArray * appGuidePageResArray=nil;
        CGFloat guidePageViewWidth=CGRectGetWidth(self.frame);
        CGFloat guidePageViewHeight=CGRectGetHeight(self.frame);
        if (guidePageViewWidth==320)
        {
            if (guidePageViewHeight==480)
            {
                appGuidePageResArray=@[
                                       @"appGuide_iphone4_p1@2x",
                                       @"appGuide_iphone4_p2@2x",
                                       @"appGuide_iphone4_p3@2x",
                                       ];
            }
            else
            {
                appGuidePageResArray=@[
                                       @"appGuide_iphone5_p1@2x",
                                       @"appGuide_iphone5_p2@2x",
                                       @"appGuide_iphone5_p3@2x",
                                       ];
            }
        }
        else if(guidePageViewWidth==375)
        {
            appGuidePageResArray=@[
                                   @"appGuide_iphone6_p1@2x",
                                   @"appGuide_iphone6_p2@2x",
                                   @"appGuide_iphone6_p3@2x",
                                   ];
        }
        else
        {
            appGuidePageResArray=@[
                                   @"appGuide_plus_p1@3x",
                                   @"appGuide_plus_p2@3x",
                                   @"appGuide_plus_p3@3x",
                                   ];
        }
        if (appGuidePageResArray)
        {
            //滚动视图
            NSInteger pageCount=[appGuidePageResArray count];
            UIScrollView * scrollView=[[UIScrollView alloc] initWithFrame:self.bounds];
            [scrollView setContentSize:CGSizeMake(pageCount*guidePageViewWidth,guidePageViewHeight)];
            [scrollView setBounces:NO];
            [scrollView setPagingEnabled:YES];
            [scrollView setDelegate:self];
            [scrollView setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1.0f]];
            [scrollView setShowsHorizontalScrollIndicator:NO];
            [scrollView setShowsVerticalScrollIndicator:NO];
            [self addSubview:scrollView];
            
            //pageControl
            CGFloat pageControlWidth=guidePageViewWidth;
            CGFloat pageControlHeight=20;
            CGRect  pageControlFrame=CGRectMake(0,
                                                guidePageViewHeight-15-pageControlHeight,
                                                pageControlWidth,
                                                pageControlHeight);
            self.pageControl=[[ICEAppGuidePageControl alloc] initWithFrame:pageControlFrame
                                                                 pageCount:pageCount
                                                          pagePointPadding:10
                                                  normalPagePointImageName:@"pagePoint_normal@2x"
                                                selectedPagePointImageName:@"pagePoint_current@2x"];
            [_pageControl setCurrentPageWithIndex:0];
            [_pageControl setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_pageControl];
            
            for (NSInteger Index=0; Index<pageCount; Index++)
            {
                UIImage * image=IMAGENAME(appGuidePageResArray[Index], @"jpg");
                CGFloat imageWidth=image.size.width;
                CGFloat imageHeight=image.size.height;
                CGFloat imageMinX=(guidePageViewWidth-imageWidth)/2+Index*guidePageViewWidth;
                UIImageView * guidePageImageView=[[UIImageView alloc] initWithImage:image];
                [guidePageImageView setFrame:CGRectMake(imageMinX, 0, imageWidth, imageHeight)];
                [scrollView addSubview:guidePageImageView];
                
                //立即体验按钮
                if (Index==pageCount-1)
                {
                    [guidePageImageView setUserInteractionEnabled:YES];
                    UIImage * experienceImage=IMAGENAME(@"enterAppNow@2x", @"png");
                    CGFloat experienceImageWidth=experienceImage.size.width;
                    CGFloat experienceImageHeight=experienceImage.size.height;
                    CGFloat experienceButtonMinX=imageMinX+(imageWidth-experienceImageWidth)/2;
                    CGRect  experienceButtonFrame=CGRectMake(experienceButtonMinX,
                                                             CGRectGetMinY(pageControlFrame)-15-experienceImageHeight,
                                                             experienceImageWidth,
                                                             experienceImageHeight);
                    ICEButton * experienceButton=[ICEButton buttonWithType:UIButtonTypeCustom];
                    [experienceButton setFrame:experienceButtonFrame];
                    [experienceButton setBackgroundImage:experienceImage forState:UIControlStateNormal];
                    [experienceButton addTarget:self action:@selector(goExperience) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:experienceButton];
                }
            }
        }
    }
    return self;
}

-(void)goExperience
{
    [ICEAppGuideView saveAppGuideViewStatus];
    __weak typeof(self) wself=self;
    [UIView animateWithDuration:1.0f animations:^
     {
         [wself setAlpha:0.0];
         [wself setTransform:CGAffineTransformMakeScale(1.2f, 1.2f)];
         
     } completion:^(BOOL finished)
     {
         [wself removeFromSuperview];
     }];
}

#pragma mark -UIScrollViewDelegateMethods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/CGRectGetWidth(self.frame);
    [_pageControl setCurrentPageWithIndex:page];
}
@end
