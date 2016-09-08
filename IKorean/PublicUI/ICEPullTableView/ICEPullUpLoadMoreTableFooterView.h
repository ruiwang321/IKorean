//
//  ICEPullUpLoadMoreTableFooterView.h
//  GameCircle
//
//  Created by wangyunlong on 15/8/4.
//  Copyright (c) 2015年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ICEPullUpLoadMoreTableFooterView : UIView

@property (nonatomic,assign,readonly) BOOL isLoading;

-(void)isStartLoadMore:(BOOL)isStart ifStopLoadMoreThenIsDestroy:(BOOL)isDestroy currentStatus:(NSString *)status;
@end
