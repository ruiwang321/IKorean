//
//  SearchResultCell.h
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//
#import "ICETableViewCell.h"

@interface SearchResultCellModel:NSObject

@property (nonatomic,assign) NSInteger vid;
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
