//
//  EpisodePlanTableViewCell.h
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpisodePlanModel : NSObject

@property (nonatomic, copy) NSString *actors;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *update_date;
@property (nonatomic, assign) NSInteger episode_count;
@property (nonatomic, assign) NSInteger episode_update;
@property (nonatomic, assign) NSInteger is_completed;
@property (nonatomic, assign) NSInteger vid;

@end

@interface EpisodePlanTableViewCell : UITableViewCell

@property (nonatomic, strong) EpisodePlanModel *episodePlanModel;

@end
