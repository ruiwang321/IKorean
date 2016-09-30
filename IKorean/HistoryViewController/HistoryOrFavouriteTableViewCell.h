//
//  HistoryOrFavouriteTableViewCell.h
//  IKorean
//
//  Created by ruiwang on 16/9/21.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryOrFavouriteDataModel : NSObject

@property (nonatomic, copy) NSNumber *grade;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSNumber *vid;
@property (nonatomic, copy) NSString *updateinfo;
@property (nonatomic, copy) NSNumber *timeStamp;
@property (nonatomic, copy) NSNumber *episodeNumber;
@property (nonatomic, copy) NSNumber *lastPlaySecond;
@property (nonatomic, copy) NSNumber *totleSecond;

@end

@interface HistoryOrFavouriteTableViewCell : UITableViewCell

@property (nonatomic, strong) HistoryOrFavouriteDataModel *model;

- (void)setEdit:(BOOL)edit;
- (void)setIsSelect:(BOOL)selected;
@end
