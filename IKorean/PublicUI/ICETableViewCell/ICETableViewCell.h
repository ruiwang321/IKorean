//
//  ICETableViewCell.h
//  ICinema
//
//  Created by yunlongwang on 16/6/16.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICETableViewCell : UITableViewCell
@property(nonatomic,assign,readonly) CGFloat cellWidth;
@property(nonatomic,assign,readonly) CGFloat cellHeight;
-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
         cellWidth:(CGFloat)cellWidth
        cellHeight:(CGFloat)cellHeight;
@end
