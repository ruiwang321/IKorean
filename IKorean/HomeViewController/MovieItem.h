//
//  MovieItem.h
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieItemModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger episode_count;
@property (nonatomic, assign) NSInteger episode_update;
@property (nonatomic, assign) NSInteger is_completed;
@property (nonatomic, assign) NSInteger vid;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, assign) NSInteger flag_hot;
@property (nonatomic, assign) NSInteger flag_new;
@property (nonatomic, assign) NSInteger flag_update;
@property (nonatomic, assign) CGFloat score;

@end

typedef void(^MovieItemAction)(MovieItemModel *);

@interface MovieItem : UIView

@property (nonatomic, strong) MovieItemModel *itemModel;
@property (nonatomic, copy) MovieItemAction movieItemAction;

@end
