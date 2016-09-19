//
//  SearchView.h
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SearchView : UIView
-(id)initWithFrame:(CGRect)frame
  selectMovieBlock:(void (^)(NSInteger ,NSString * ))selectBlock;
@end
