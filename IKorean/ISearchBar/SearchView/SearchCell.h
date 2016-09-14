//
//  SearchCell.h
//  ICinema
//
//  Created by wangyunlong on 16/8/1.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICETableViewCell.h"
@interface SearchCellModel:NSObject
@property (nonatomic,assign) NSInteger movieID;
@property (nonatomic,copy) NSAttributedString * title;
@property (nonatomic,assign) CGFloat cellHeight;
@end

@interface SearchCell : ICETableViewCell

@property (nonatomic,strong,readonly) SearchCellModel * model;

+(CGFloat)titleLabelMinX;

-(void)updateCellWithCellModel:(SearchCellModel *)model;

@end
