//
//  SearchResultsView.h
//  ICinema
//
//  Created by wangyunlong on 16/8/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsView : UIView
-(id)initWithFrame:(CGRect)frame
selectHotSearchCellBlock:(void (^)(NSInteger ,NSString * ))selectBlock
  startScrollBlock:(void (^)())startScrollBlock;

-(void)reloadWithKeyWord:(NSString *)keyWord;
@end
