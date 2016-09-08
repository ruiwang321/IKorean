//
//  ICEPullTableView.h
//  GameCircle
//
//  Created by wangyunlong on 15/8/4.
//  Copyright (c) 2015年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ICEPullTableViewOperationResultOptions) {
    ICEPullTableViewOperationSuccess,
    ICEPullTableViewOperationFailed,
    ICEPullTableViewOperationNoMore
};

typedef NS_ENUM(NSInteger, ICEPullTableViewOperationTypeOptions) {
    ICEPullTableViewRefresh,
    ICEPullTableViewLoadMore
};

typedef NS_ENUM(NSInteger, ScrollViewOperationTypeOptions) {
    ScrollViewWillBeginDragging,
    ScrollViewDidScroll
};

typedef void (^TableViewOperationStartBlock)(ICEPullTableViewOperationTypeOptions operationType);

typedef void (^ScrollViewOperationStartBlock)(ScrollViewOperationTypeOptions operationType,CGFloat offsetY);

@interface ICEPullTableView : UITableView

@property (nonatomic,copy) TableViewOperationStartBlock  tableViewOperationStartBlock;

@property (nonatomic,copy) ScrollViewOperationStartBlock scrollViewOperationStartBlock;

+(CGFloat)refreshViewHeight;

+(CGFloat)loadMoreViewHeight;

-(id)initWithFrame:(CGRect)frame
    isNeedLoadMore:(BOOL)isNeedLoadMore
     tableViewName:(NSString *)tableViewName
refreshTimeInterval:(NSTimeInterval)refreshTimeInterval;

-(BOOL)isShouldRefresh;

-(BOOL)refreshNewDataStart;

-(void)tableOperationCompleteWithOperationType:(ICEPullTableViewOperationTypeOptions)operationType
                            andOperationResult:(ICEPullTableViewOperationResultOptions)operationResult;


@end
