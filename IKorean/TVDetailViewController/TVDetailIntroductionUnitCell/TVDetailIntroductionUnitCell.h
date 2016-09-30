//
//  TVDetailIntroductionUnitCell.h
//  ICinema
//
//  Created by yunlongwang on 16/7/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICETableViewCell.h"
#import "TVDetailIntroductionUnitCellModel.h"
typedef void (^ExpandCellBlock)();
@interface TVDetailIntroductionUnitCell : ICETableViewCell

@property (nonatomic,copy)ExpandCellBlock  expandCellBlock;

-(void)updateCellWithModel:(TVDetailIntroductionUnitCellModel *)model;
@end
