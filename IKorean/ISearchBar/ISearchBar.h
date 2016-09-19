//
//  ISearchBar.h
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
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
