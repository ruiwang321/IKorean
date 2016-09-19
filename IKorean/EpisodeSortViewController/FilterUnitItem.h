//
//  FilterUnitItem.h
//  ICinema
//
//  Created by wangyunlong on 16/8/6.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterUnitItemModel : NSObject
@property (nonatomic,copy) NSString * cate_id;
@property (nonatomic,copy) NSString * year_id;
@property (nonatomic,copy) NSString * is_complete;
@property (nonatomic,copy) NSString * sort_type;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * img;

@end

typedef void (^SelectFilterUnitItemBlock)(FilterUnitItemModel * model);

@interface FilterUnitItem : UIView

@property (nonatomic,copy) SelectFilterUnitItemBlock selectItemBlock;

@property (nonatomic,strong,readonly) FilterUnitItemModel * model;

-(id)initWithFrame:(CGRect)frame
      cornerRadius:(CGFloat)cornerRadius;

-(void)setItemModel:(FilterUnitItemModel *)model;

@end
