//
//  EpisodePlanTableViewCell.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "EpisodePlanTableViewCell.h"

@implementation EpisodePlanModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end

@interface EpisodePlanTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *episodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *episodeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *actorInfoLabel;

@end

@implementation EpisodePlanTableViewCell

- (void)setEpisodePlanModel:(EpisodePlanModel *)episodePlanModel {
    _episodePlanModel = episodePlanModel;
    [_episodeImageView sd_setImageWithURL:[NSURL URLWithString:episodePlanModel.img] placeholderImage:[UIImage imageNamed:@"default_v_icon"]];
    _episodeTitleLabel.text = episodePlanModel.title;
    _actorInfoLabel.text = episodePlanModel.actors;
    _updateInfoLabel.text = episodePlanModel.update_date;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
