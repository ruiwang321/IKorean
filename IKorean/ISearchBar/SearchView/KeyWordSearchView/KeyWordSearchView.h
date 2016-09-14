//
//  KeyWordSearchView.h
//  ICinema
//
//  Created by wangyunlong on 16/8/1.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^KeyWordSearchViewReloadFinishBlock)();
@interface KeyWordSearchView : UIView

-(id)initWithFrame:(CGRect)frame
selectHotSearchCellBlock:(void (^)(NSInteger ,NSString * ))selectBlock
  startScrollBlock:(void (^)())startScrollBlock
 reloadFinishBlock:(KeyWordSearchViewReloadFinishBlock)reloadFinishBlock;

-(void)reloadWithKeyWord:(NSString *)keyWord;
@end
