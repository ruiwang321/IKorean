//
//  ICEPullTableView.m
//  GameCircle
//
//  Created by wangyunlong on 15/8/4.
//  Copyright (c) 2015年 wangyunlong. All rights reserved.
//

#import "ICEPullTableView.h"
#import "ICEPullDownRefreshTableHeaderView.h"
#import "ICEPullUpLoadMoreTableFooterView.h"

//////////////////////////ICEMsgforwardingObject///////////////////////////
@interface ICEMsgforwardingObject: NSObject

@property (nonatomic, assign) id tableViewMessageReceiver;

@property (nonatomic, assign) id scrollViewMessageReceiver;

@end

@implementation ICEMsgforwardingObject

- (void)dealloc
{
    self.tableViewMessageReceiver = nil;
    self.scrollViewMessageReceiver = nil;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([_tableViewMessageReceiver respondsToSelector:aSelector])
    {
        return _tableViewMessageReceiver;
    }
    if ([_scrollViewMessageReceiver respondsToSelector:aSelector])
    {
        return _scrollViewMessageReceiver;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([_tableViewMessageReceiver respondsToSelector:aSelector])
    {
        return YES;
    }
    if ([_scrollViewMessageReceiver respondsToSelector:aSelector])
    {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}
@end

//////////////////////////ICEPullTableView///////////////////////////

static NSInteger defaultRefreshViewHeight=50;
static NSInteger defaultLoadMoreViewHeight=40;

@interface ICEPullTableView ()

@property (nonatomic,assign) BOOL    isNeedLoadMore;
@property (nonatomic,assign) CGFloat lastOffsetY;
@property (nonatomic,assign) CGFloat triggerLoadMoreOffsetY;
@property (nonatomic,strong) ICEMsgforwardingObject * msgforwardingObject;
@property (nonatomic,strong) ICEPullDownRefreshTableHeaderView * refreshView;
@property (nonatomic,strong) ICEPullUpLoadMoreTableFooterView  * loadMoreView;

@end

@implementation ICEPullTableView

+(CGFloat)refreshViewHeight
{
    return defaultRefreshViewHeight;
}

+(CGFloat)loadMoreViewHeight
{
    return defaultLoadMoreViewHeight;
}

-(void)dealloc
{
    [_refreshView isStartRefresh:NO ifStopRefreshThenIsDestroy:YES scrollView:nil];
    [_loadMoreView isStartLoadMore:NO ifStopLoadMoreThenIsDestroy:YES currentStatus:@""];
}

-(id)initWithFrame:(CGRect)frame
    isNeedLoadMore:(BOOL)isNeedLoadMore
     tableViewName:(NSString *)tableViewName
refreshTimeInterval:(NSTimeInterval)refreshTimeInterval
{
    if (self=[super initWithFrame:frame style:UITableViewStylePlain])
    {
        CGFloat tableViewWidth=CGRectGetWidth(frame);

        _isNeedLoadMore=isNeedLoadMore;
        _triggerLoadMoreOffsetY=-1.0f;

        //消息转发object
        self.msgforwardingObject = [[ICEMsgforwardingObject alloc] init];

        //refreshView
        CGRect refreshViewFrame=CGRectMake(0, -defaultRefreshViewHeight, tableViewWidth, defaultRefreshViewHeight);
        self.refreshView=[[ICEPullDownRefreshTableHeaderView alloc]initWithFrame:refreshViewFrame
                                                                   tableViewName:tableViewName
                                                             refreshTimeInterval:refreshTimeInterval];
        _refreshView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_refreshView];

        //loadMoreView
        if (_isNeedLoadMore)
        {
            CGRect loadMoreViewFrame=CGRectMake(0, 0, tableViewWidth, defaultLoadMoreViewHeight);
            self.loadMoreView=[[ICEPullUpLoadMoreTableFooterView alloc] initWithFrame:loadMoreViewFrame];
            _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            [self setTableFooterView:_loadMoreView];
            [_loadMoreView setHidden:YES];
        }
        self.panGestureRecognizer.delaysTouchesBegan =self.delaysContentTouches;
    }
    return self;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if (_msgforwardingObject)
    {
        _msgforwardingObject.scrollViewMessageReceiver = self;
        _msgforwardingObject.tableViewMessageReceiver = delegate;
        super.delegate = (id)_msgforwardingObject;
    }
}

-(void)executeTableViewBlockWithOperationType:(ICEPullTableViewOperationTypeOptions)typeOptions
{
    if (_tableViewOperationStartBlock)
    {
        _tableViewOperationStartBlock(typeOptions);
    }
}

-(void)executeScrollViewBlockWithOperationType:(ScrollViewOperationTypeOptions)typeOptions offSetY:(CGFloat)offSetY
{
    if (_scrollViewOperationStartBlock)
    {
        _scrollViewOperationStartBlock(typeOptions,offSetY);
    }
}

-(BOOL)isShouldRefresh
{
    return [_refreshView isShouldRefresh];
}

-(BOOL)refreshNewDataStart
{
    if (!_refreshView.isLoading&&
        !_loadMoreView.isLoading)
    {
        [_refreshView isStartRefresh:YES ifStopRefreshThenIsDestroy:NO scrollView:self];
        return YES;
    }
    return NO;
}

-(void)tableOperationCompleteWithOperationType:(ICEPullTableViewOperationTypeOptions)operationType
                            andOperationResult:(ICEPullTableViewOperationResultOptions)operationResult
{
    switch (operationType)
    {
        case ICEPullTableViewRefresh:
            [self refreshNewDataCompleteWithResultOption:operationResult];
            break;
        case ICEPullTableViewLoadMore:
            [self loadMoreDataCompleteWithResultOption:operationResult];
            break;
        default:
            break;
    }
}

-(void)refreshNewDataCompleteWithResultOption:(ICEPullTableViewOperationResultOptions)operationResult
{
    if (_isNeedLoadMore)
    {
        [self loadMoreDataCompleteWithResultOption:operationResult];
        [_loadMoreView setHidden:NO];
    }
    [_refreshView isStartRefresh:NO ifStopRefreshThenIsDestroy:NO scrollView:self];
}

-(void)loadMoreDataCompleteWithResultOption:(ICEPullTableViewOperationResultOptions)operationResult
{
    NSString * statusString=nil;
    if (self.contentSize.height>CGRectGetHeight(self.frame))
    {
        switch (operationResult)
        {
            case ICEPullTableViewOperationSuccess:
                statusString=@"上拉加载更多";
                break;
            case ICEPullTableViewOperationNoMore:
                statusString=@"暂无更多";
                break;
            default:
                statusString=@"加载失败,请重试";
                break;
        }
    }
    else
    {
        switch (operationResult)
        {
            case ICEPullTableViewOperationSuccess:
            case ICEPullTableViewOperationNoMore:
                statusString=@"暂无更多";
                break;
            default:
                statusString=@"加载失败,请重试";
                break;
        }
    }
    [_loadMoreView isStartLoadMore:NO ifStopLoadMoreThenIsDestroy:NO currentStatus:statusString];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _lastOffsetY=scrollView.contentOffset.y;
    [_refreshView updateLastRefreshDateLabel];
    [self executeScrollViewBlockWithOperationType:ScrollViewWillBeginDragging offSetY:0];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetY=scrollView.contentOffset.y;
    
    [self executeScrollViewBlockWithOperationType:ScrollViewDidScroll offSetY:contentOffsetY];
    
    if (contentOffsetY<0&&!_refreshView.isLoading)
    {
        //下拉更新
        [_refreshView setRefreshViewStatusWithScrollView:scrollView];
    }
    else if(contentOffsetY>0&&_isNeedLoadMore)
    {
        //上拉加载更多
        
        //此时加载的数据的总高度
        CGFloat contentSizeHeight=scrollView.contentSize.height;
        if (contentOffsetY<_lastOffsetY
            ||_refreshView.isLoading
            ||_loadMoreView.isLoading
            ||_triggerLoadMoreOffsetY==contentSizeHeight)
        {
            _lastOffsetY=contentOffsetY;
            return;
        }
        //tableView的高度
        CGFloat tableViewHeight=CGRectGetHeight(self.frame);
        //content的顶部与tableView底部的距离
        CGFloat distanceFromContentTopToTableViewBottom=contentOffsetY+tableViewHeight;
        //offset＋tableView的高度与content的底部的距离(可能是正数也可能是负数)
        CGFloat distanceFromTableViewBottomToContentBottom=contentSizeHeight-distanceFromContentTopToTableViewBottom;
        
        BOOL isCanLoadMore=NO;
        
        if (distanceFromTableViewBottomToContentBottom>=tableViewHeight&&
            distanceFromTableViewBottomToContentBottom<2*tableViewHeight)
        {
            //如果content的高度-(上拉的偏移量＋tableView的高)>=tableview高度的一半且小于2倍的tableview的高度
            //(contentHeight>tableViewHeight)
            isCanLoadMore=YES;
        }
        else if(distanceFromContentTopToTableViewBottom>=contentSizeHeight)
        {
            //1.0 < content的高度-(上拉的偏移量＋tableView的高)<tableview高度的一半
            //2.content的高度-(上拉的偏移量＋tableView的高)<=0
            //3.content的高度<tableView的高
            //这几种情况会执行这个判断，此时必须滚动到最底部才能触发加载更多
            isCanLoadMore=YES;
        }
        if (isCanLoadMore)
        {
            //NSLog(@"加载更多");
            _triggerLoadMoreOffsetY=contentSizeHeight;
            [_loadMoreView isStartLoadMore:YES ifStopLoadMoreThenIsDestroy:NO currentStatus:@"加载中..."];
            [self executeTableViewBlockWithOperationType:ICEPullTableViewLoadMore];
        }
    }
    _lastOffsetY=contentOffsetY;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (CGPointEqualToPoint(velocity, CGPointZero))
    {
        _triggerLoadMoreOffsetY=0;
    }
}

-(void)scrollViewWillBeginDecelerating: (UIScrollView *)scrollView
{
    CGFloat contentOffsetY=scrollView.contentOffset.y;
    if (contentOffsetY<=-defaultRefreshViewHeight
        &&!_refreshView.isLoading
        &&!_loadMoreView.isLoading)
    {
        // NSLog(@"更新");
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        [_refreshView isStartRefresh:YES ifStopRefreshThenIsDestroy:NO scrollView:self];
        [self executeTableViewBlockWithOperationType:ICEPullTableViewRefresh];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _triggerLoadMoreOffsetY=0;
}

@end
