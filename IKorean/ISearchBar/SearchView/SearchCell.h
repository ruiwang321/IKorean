//
//  SearchCell.h
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
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
