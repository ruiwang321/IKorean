//
//  ISearchBar.h
//  ICinema
//
//  Created by yunlongwang on 16/8/20.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ISearchBarStyle) {
    ISearchBarDefaultStyle,
    ISearchBarShadowStyle,
    ISearchBarColorTranslucentStyle,
    ISearchBarBlurStyle
};

@interface ISearchBar : UIView

@property (nonatomic,copy) void (^selectSearchBlock)();
@property (nonatomic,copy) void (^selectHistoryBlock)();
@property (nonatomic,copy) void (^selectSettingBlock)();

-(id)initWithFrame:(CGRect)frame isNeedSpecialEfficacy:(BOOL)isNeedSpecialEfficacy;

-(void)updateSearchBarWithSearchBarStyle:(ISearchBarStyle)searchBarStyle alpha:(CGFloat)alpha;

-(void)isShowSearchBar:(BOOL)isShow;
@end
