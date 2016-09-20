//
//  HotSearchItem.h
//  IKorean
//
//  Created by ruiwang on 16/9/19.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotSearchItemModel : NSObject

@property (nonatomic, copy) NSString *hotKey;
@property (nonatomic, copy) NSString *keyType;
@property (nonatomic, copy) NSString *num;

@end

@interface HotSearchItem : UICollectionViewCell

@property (nonatomic, strong) HotSearchItemModel *itemModel;

@end
