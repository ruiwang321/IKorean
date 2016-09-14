//
//  SearchResultCell.h
//  ICinema
//
//  Created by wangyunlong on 16/8/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICETableViewCell.h"

@interface SearchResultCellModel:NSObject

@property (nonatomic,assign) NSInteger movieID;
@property (nonatomic,copy) NSAttributedString * titleAttributedString;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * img;

@end

@interface SearchResultCell : ICETableViewCell
@property (nonatomic,strong,readonly)SearchResultCellModel * model;

+(CGFloat)cellHiehgt;
+(CGPoint)titleLabelOrigin;
+(CGFloat)titleLabelPaddingToRight;
-(void)updateCellWithCellModel:(SearchResultCellModel *)model;

@end
