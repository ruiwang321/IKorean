//
//  RecommendItem.m
//  IKorean
//
//  Created by ruiwang on 16/9/29.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "RecommendItem.h"

@interface RecommendItem ()

@property (nonatomic, strong) MovieItem *item;

@end

@implementation RecommendItem

- (void)setModel:(MovieItemModel *)model {
    if (_item == nil) {
        _item = [[MovieItem alloc] initWithFrame:self.bounds];
        _item.userInteractionEnabled = NO;
        [self addSubview:_item];
    }
    _item.itemModel = model;
}

@end
