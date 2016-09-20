//
//  HotSearchItem.m
//  IKorean
//
//  Created by ruiwang on 16/9/19.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "HotSearchItem.h"

@implementation HotSearchItemModel
@end

@interface HotSearchItem ()

@property (weak, nonatomic) IBOutlet UIImageView *hotImgView;
@property (weak, nonatomic) IBOutlet UILabel *hotKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *keyTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *NoLabel;
@property (weak, nonatomic) IBOutlet UIView *keyTypeLabelBgView;

@end

@implementation HotSearchItem

- (void)setItemModel:(HotSearchItemModel *)itemModel {
    _itemModel = itemModel;
    _hotKeyLabel.text = itemModel.hotKey;
    _keyTypeLabel.text = itemModel.keyType;
    _NoLabel.text = itemModel.num;
    if (itemModel.keyType == nil) {
        _keyTypeLabelBgView.hidden = YES;
    }else {
        _keyTypeLabelBgView.hidden = NO;
    }
    
    if ([itemModel.num isEqualToString:@"1"]) {
        _hotImgView.image = [UIImage imageNamed:@"hot_1"];
        _NoLabel.textColor = [UIColor whiteColor];
    }else if ([itemModel.num isEqualToString:@"2"]) {
        _hotImgView.image = [UIImage imageNamed:@"hot_2"];
        _NoLabel.textColor = [UIColor whiteColor];
    }else if ([itemModel.num isEqualToString:@"3"]) {
        _hotImgView.image = [UIImage imageNamed:@"hot_3"];
        _NoLabel.textColor = [UIColor whiteColor];
    }else {
        _hotImgView.image = [UIImage imageNamed:@"hot_normal"];
        _NoLabel.textColor = [UIColor colorWithRed:172/255.0f green:172/255.0f blue:172/255.0f alpha:1];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

@end
