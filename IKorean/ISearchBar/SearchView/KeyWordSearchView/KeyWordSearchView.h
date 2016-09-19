//
//  KeyWordSearchView.h
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
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
