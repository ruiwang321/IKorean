//
//  DateListItem.h
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateListItem : UICollectionViewCell

- (void)showDate:(NSDate *)date withIsSelected:(BOOL)selected   ;

@end