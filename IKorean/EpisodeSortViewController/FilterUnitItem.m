//
//  FilterUnitItem.m
//  ICinema
//
//  Created by wangyunlong on 16/8/6.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "FilterUnitItem.h"
@implementation FilterUnitItemModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _is_complete = @"99";
        _year_id = @"0";
        _cate_id = @"0";
        _sort_type = @"1";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    FilterUnitItemModel * model=[[self class] allocWithZone:zone];
    model.title=_title;
    model.cate_id=_cate_id;
    model.sort_type=_sort_type;
    model.year_id=_year_id;
    model.img=_img;
    model.is_complete = _is_complete;
    return model;
}
@end

@interface FilterUnitItem ()
{
    ICEButton * m_button;
}

@property (nonatomic,strong,readwrite) FilterUnitItemModel * model;

@end

@implementation FilterUnitItem

-(id)initWithFrame:(CGRect)frame
      cornerRadius:(CGFloat)cornerRadius
{
    if (self=[super initWithFrame:frame])
    {
        CGFloat widthOfItem=CGRectGetWidth(frame);
        CGFloat heightOfItem=CGRectGetHeight(frame);
        UIView * defaultView=[[ICEAppHelper shareInstance]viewWithPlaceholderImageName:@"publicPlaceholder@2x"
                                                                             viewWidth:widthOfItem
                                                                            viewHeight:heightOfItem
                                                                          cornerRadius:cornerRadius];
        [defaultView setFrame:self.bounds];
        
        m_button=[ICEButton buttonWithType:UIButtonTypeCustom];
        [m_button addTarget:self action:@selector(selectItem) forControlEvents:UIControlEventTouchUpInside];
        [m_button setFrame:defaultView.bounds];
        [defaultView addSubview:m_button];
        
        [self addSubview:defaultView];
    }
    return self;
}

-(void)setItemModel:(FilterUnitItemModel *)model
{
    self.model=model;
    if (_model)
    {
        [m_button sd_setImageWithURL:[NSURL URLWithString:model.img] forState:UIControlStateNormal];
    }
}

-(void)selectItem
{
    if (_selectItemBlock) {
        _selectItemBlock(_model);
    }
}
@end
