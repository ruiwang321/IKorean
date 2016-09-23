//
//  HistoryOrFavouriteTableViewCell.h
//  IKorean
//
//  Created by ruiwang on 16/9/21.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryOrFavouriteDataModel : NSObject

@end

@interface HistoryOrFavouriteTableViewCell : UITableViewCell

@property (nonatomic, strong) HistoryOrFavouriteDataModel *model;

- (void)setEdit:(BOOL)edit;
- (void)setIsSelect:(BOOL)selected;
@end
