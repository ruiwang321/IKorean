//
//  HistoryOrFavouriteTableViewCell.m
//  IKorean
//
//  Created by ruiwang on 16/9/21.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "HistoryOrFavouriteTableViewCell.h"


@implementation HistoryOrFavouriteDataModel
@end

@interface HistoryOrFavouriteTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectImageWidth;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;


@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (weak, nonatomic) IBOutlet UIView *falseView;

@end

@implementation HistoryOrFavouriteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _falseView.backgroundColor = APPColor;
    _delBtn.backgroundColor = APPColor;
    
    _delBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -20, -40, 0);
    _delBtn.imageEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, -35);
}

- (void)setEdit:(BOOL)edit {
    if (edit) {

        self.selectImageWidth.constant = 44;
        self.selectImageView.hidden = NO;
    } else{
        self.selectImageWidth.constant = 0;
        self.selectImageView.hidden = YES;
    }
}

- (void)setIsSelect:(BOOL)selected {
    if (selected) {
        _selectImageView.highlighted = YES;
    }else {
        _selectImageView.highlighted = NO;
    }
}

- (void)setModel:(HistoryOrFavouriteDataModel *)model {
    _model = model;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
