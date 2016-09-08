//
//  ICEPullDownRefreshTableHeaderView.h
//  GameCircle
//
//  Created by wangyunlong on 15/8/4.
//  Copyright (c) 2015年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, RefreshViewStatus) {
    RefreshViewStatus_DragDownToUpdate,
    RefreshViewStatus_ReleaseHandWillUpdate,
    RefreshViewStatus_Loading,
};

@interface ICEPullDownRefreshTableHeaderView : UIView

@property (nonatomic,assign,readonly) BOOL isLoading;

-(id)initWithFrame:(CGRect)frame
     tableViewName:(NSString *)tableViewName
refreshTimeInterval:(NSTimeInterval)refreshTimeInterval;

-(BOOL)isShouldRefresh;

-(void)updateLastRefreshDateLabel;

-(void)setRefreshViewStatusWithScrollView:(UIScrollView *)scrollView;

-(void)isStartRefresh:(BOOL)isStart ifStopRefreshThenIsDestroy:(BOOL)isDestroy scrollView:(UIScrollView *)scrollView;
@end
