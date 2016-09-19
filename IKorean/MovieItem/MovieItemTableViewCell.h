//
//  MovieItemTableViewCell.h
//  ICinema
//
//  Created by wangyunlong on 16/8/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICETableViewCell.h"
#import "MovieItem.h"

@interface MovieItemTableViewCell : ICETableViewCell

@property (nonatomic,weak) MovieItemAction selectBlock;

-(void)updateCellWithDicOfData:(NSArray *)arrayOfCellDatas;

@end
