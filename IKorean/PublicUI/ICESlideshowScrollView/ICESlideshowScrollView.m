//
//  ICESlideshowScrollView.m
//  GreatCar
//
//  Created by wangyunlong on 16/1/27.
//  Copyright © 2016年 yunlongwang. All rights reserved.
//

#import "ICESlideshowScrollView.h"
#import "ICEPageControl.h"
#define ICEPageAutoScrollTimeInterval       4
@interface ICESlideshowScrollView ()
<
UIScrollViewDelegate
>

@property (nonatomic,copy) SelectPageBlock selectPageBlock;
@property (nonatomic,copy) NSString * placeholderImageName;
@property (nonatomic,strong) NSMutableArray * slideshowPageModelsArray;
@property (nonatomic,strong) UIScrollView  * scrollView;
@property (nonatomic,assign) CGFloat scrollViewWidth;
@property (nonatomic,assign) CGFloat scrollViewHeight;
@property (nonatomic,assign) BOOL isScrollByTimer;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) ICEPageControl * pageControl;
@property (nonatomic,strong) ICESlideshowPageView  * leftSlideshowPageView;
@property (nonatomic,strong) ICESlideshowPageView  * middleSlideshowPageView;
@property (nonatomic,strong) ICESlideshowPageView  * rightSlideshowPageView;

@end

@implementation ICESlideshowScrollView
-(void)dealloc
{
    [self stopTimerWithDate:nil isDelete:YES];
}

-(id)initWithFrame:(CGRect)frame
placeholderImageName:(NSString *)imageName
   selectPageBlock:(SelectPageBlock)selectPageBlock
{
    if (self=[super initWithFrame:frame])
    {
        _isScrollByTimer=NO;
        _scrollViewWidth=CGRectGetWidth(frame);
        _scrollViewHeight=CGRectGetHeight(frame);
        self.placeholderImageName=imageName;
        self.slideshowPageModelsArray=[[NSMutableArray alloc] initWithCapacity:10];
        self.selectPageBlock=selectPageBlock;
        [self setSlideshowScrollViewWithPageModels:nil];
    }
    return self;
}

-(void)setSlideshowScrollViewWithPageModels:(NSArray *)pageModels
{
    if (_scrollView==nil)
    {
        self.scrollView=[[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setBounces:NO];
        [_scrollView setDelegate:self];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:_scrollView];
        
        //左侧幻灯片
        CGRect leftSlideshowPageViewFrame=CGRectMake(0, 0, _scrollViewWidth, _scrollViewHeight);
        self.leftSlideshowPageView=[[ICESlideshowPageView alloc] initWithFrame:leftSlideshowPageViewFrame
                                                          placeholderImageName:_placeholderImageName];
        _leftSlideshowPageView.selectPageBlock=_selectPageBlock;
        [_scrollView addSubview:_leftSlideshowPageView];

        
        //pageControl
        self.pageControl=[[ICEPageControl alloc] initWithSuperViewSize:self.frame.size];
        [self addSubview:_pageControl];
    }
    
    if (pageModels&&[pageModels count])
    {
        //支持根据服务器返回的数据动态改变幻灯片数量，当数量大于1时，无论多少条数据，都是3屏处理滑动，这样比较节省内存
        [_slideshowPageModelsArray setArray:pageModels];
        NSInteger currentSlideshowPageCount=[_slideshowPageModelsArray count];
        if (currentSlideshowPageCount>1)
        {
            //大于1个幻灯片，需要滚动，恢复或开启定时器，显示pageControl。
            [_scrollView setContentSize:CGSizeMake(_scrollViewWidth*3, _scrollViewHeight)];
            
            //更新左侧幻灯片
            [_leftSlideshowPageView setSlideshowPageWithPageModel:[_slideshowPageModelsArray lastObject]];
            
            //创建或更新中间幻灯片
            if (_middleSlideshowPageView==nil)
            {
                CGRect middleSlideshowPageViewFrame=CGRectMake(_scrollViewWidth, 0, _scrollViewWidth, _scrollViewHeight);
                self.middleSlideshowPageView=[[ICESlideshowPageView alloc] initWithFrame:middleSlideshowPageViewFrame
                                                                    placeholderImageName:_placeholderImageName];
                _middleSlideshowPageView.selectPageBlock=_selectPageBlock;
                [_scrollView addSubview:_middleSlideshowPageView];
            }
            [_middleSlideshowPageView setSlideshowPageWithPageModel:[_slideshowPageModelsArray firstObject]];
            
            //创建或更新右侧幻灯片
            if (_rightSlideshowPageView==nil)
            {
                CGRect rightSlideshowPageViewFrame=CGRectMake(_scrollViewWidth*2, 0, _scrollViewWidth, _scrollViewHeight);
                self.rightSlideshowPageView=[[ICESlideshowPageView alloc] initWithFrame:rightSlideshowPageViewFrame
                                                                   placeholderImageName:_placeholderImageName];
                _rightSlideshowPageView.selectPageBlock=_selectPageBlock;
                [_scrollView addSubview:_rightSlideshowPageView];
            }
            [_rightSlideshowPageView setSlideshowPageWithPageModel:[_slideshowPageModelsArray objectAtIndex:1]];
            
            //将scrollView恢复起始位置
            [_scrollView setContentOffset:CGPointMake(_scrollViewWidth, 0)];
            
            //开启或恢复定时器
            [self startTimerWithDate:[NSDate dateWithTimeIntervalSinceNow:ICEPageAutoScrollTimeInterval]];
            
            //更新pageControlView
            [_pageControl setPageCount:currentSlideshowPageCount];
        }
        else
        {
            //1个幻灯片，不需要滚动，停掉定时器,隐藏pageControl。
            [_leftSlideshowPageView setSlideshowPageWithPageModel:[_slideshowPageModelsArray firstObject]];
            [_middleSlideshowPageView setSlideshowPageWithPageModel:nil];
            [_rightSlideshowPageView setSlideshowPageWithPageModel:nil];
            [self stopTimerWithDate:[NSDate distantFuture] isDelete:NO];
            [_scrollView setContentOffset:CGPointZero];
            [_scrollView setContentSize:CGSizeMake(_scrollViewWidth, _scrollViewHeight)];
            [_pageControl setPageCount:0];
        }
    }
    else
    {
        //如果返回空值时想保留上一次有数据时的幻灯片状态而不更新，把这段代码屏蔽掉
        [_leftSlideshowPageView setSlideshowPageWithPageModel:nil];
        [_middleSlideshowPageView setSlideshowPageWithPageModel:nil];
        [_rightSlideshowPageView setSlideshowPageWithPageModel:nil];
        [self stopTimerWithDate:[NSDate distantFuture] isDelete:NO];
        [_scrollView setContentOffset:CGPointZero];
        [_scrollView setContentSize:CGSizeMake(_scrollViewWidth, _scrollViewHeight)];
        [_pageControl setPageCount:0];
    }
}

-(void)stopTimerWithDate:(NSDate *)date isDelete:(BOOL)isDelete
{
    if (_timer&&[_timer isValid])
    {
        if (isDelete)
        {
            [_timer invalidate];
            self.timer=nil;
        }
        else
        {
            [_timer setFireDate:date];
        }
    }
}

-(void)startTimerWithDate:(NSDate *)date
{
    if (_timer==nil)
    {
        self.timer=[NSTimer scheduledTimerWithTimeInterval:ICEPageAutoScrollTimeInterval
                                                    target:self
                                                  selector:@selector(timerAction)
                                                  userInfo:nil
                                                   repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    else
    {
        [_timer setFireDate:date];
    }
}

- (void)timerAction
{
    //不要调用[m_scrollViewOfSlideshowView setContentOffset:CGPointMake(2*sizeOfSelf.width, 0) animated:YES];
    //上面这种调用当动画执行时会被滑动或点击手势打断，小概率出现奇怪的问题，比如当页面返回时会停在两张图片中间。
    _isScrollByTimer=YES;
    __weak typeof(self) wself=self;
    [UIView animateWithDuration:0.4f animations:^
     {
         [wself.scrollView setContentOffset:CGPointMake(2*_scrollViewWidth, 0)];
         
     } completion:^(BOOL finished)
     {
         [wself changeSlideshow];
     }];
}

-(void)isStopScroll:(BOOL)isStop
{
    if (isStop)
    {
        [self stopTimerWithDate:[NSDate distantFuture] isDelete:NO];
    }
    else
    {
        [self startTimerWithDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
}

- (NSInteger)getPageIndexWithPageModel:(ICESlideshowPageModel *)pageModel
{
    NSInteger Index=[_slideshowPageModelsArray indexOfObject:pageModel];
    if (Index==NSNotFound)
    {
        return 0;
    }
    return Index;
}

#pragma mark-UIScrollViewDelegateMethods
- (void)changeSlideshow
{
    ICESlideshowPageModel * pageModel=_middleSlideshowPageView.pageModel;
    if (pageModel)
    {
        CGFloat offsetX=_scrollView.contentOffset.x;
        if (offsetX==0||offsetX==2*_scrollViewWidth)
        {
            NSInteger modelCount=[_slideshowPageModelsArray count];
            NSInteger middlePageIndex=[self getPageIndexWithPageModel:pageModel];
            NSInteger leftPageIndex=0;
            NSInteger rightPageIndex=0;
            if (offsetX==0)
            {
                //向右滑
                //NSLog(@"-------->");
                rightPageIndex=middlePageIndex;
                middlePageIndex=(middlePageIndex-1<0?modelCount-1:middlePageIndex-1);
                leftPageIndex=(middlePageIndex-1<0?modelCount-1:middlePageIndex-1);
            }
            else if(offsetX==2*_scrollViewWidth)
            {
                //向左滑
                //NSLog(@"<--------");
                leftPageIndex=middlePageIndex;
                middlePageIndex=(middlePageIndex+1>=modelCount?0:middlePageIndex+1);
                rightPageIndex=(middlePageIndex+1>=modelCount?0:middlePageIndex+1);
            }
            
            [_pageControl setCurrentPageIndex:middlePageIndex];
            [_middleSlideshowPageView setSlideshowPageWithPageModel:[_slideshowPageModelsArray objectAtIndex:middlePageIndex]];
            [_leftSlideshowPageView setSlideshowPageWithPageModel:[_slideshowPageModelsArray objectAtIndex:leftPageIndex]];
            [_rightSlideshowPageView setSlideshowPageWithPageModel:[_slideshowPageModelsArray objectAtIndex:rightPageIndex]];
            [_scrollView setContentOffset:CGPointMake(_scrollViewWidth, 0)];
        }
        else
        {
            return;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isScrollByTimer)
    {
        [self changeSlideshow];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isScrollByTimer=NO;
    [self stopTimerWithDate:[NSDate distantFuture] isDelete:NO];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimerWithDate:[NSDate dateWithTimeIntervalSinceNow:ICEPageAutoScrollTimeInterval]];
}

@end
