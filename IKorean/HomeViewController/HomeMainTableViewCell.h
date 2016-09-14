//
//  HomeMainTableViewCell.h
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeMainTableViewCellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger filter_cate_id;
@property (nonatomic, assign) NSInteger filter_is_completed;
@property (nonatomic, assign) NSInteger filter_sort_type;
@property (nonatomic, assign) NSInteger filter_year_id;
@property (nonatomic, strong) NSArray *videos;

@end

@interface HomeMainTableViewCell : UITableViewCell

@property (nonatomic, strong) HomeMainTableViewCellModel *cellModel;

+ (CGFloat)cellHeight;

@end
