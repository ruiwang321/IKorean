//
//  HomeMainTableViewCell.m
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "HomeMainTableViewCell.h"
#import "MovieItem.h"
#import "AppDelegate.h"
#import "EpisodeSortViewController.h"

@implementation HomeMainTableViewCellModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end

static CGFloat const cellHeight = 400;
static CGFloat const moreButtonPadding = 8;

@interface HomeMainTableViewCell ()
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HomeMainTableViewCell
+ (CGFloat)cellHeight {
    return cellHeight * SCREEN_SCALE;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)createSubView {
    UIColor * appPublicColor=[ICEAppHelper shareInstance].appPublicColor;
    //更多按钮
    UIImage *moreButtonImage = [UIImage imageNamed:@"homeMoreBtn"];
    CGFloat moreButtonWidth = moreButtonImage.size.width;
    CGFloat moreButtonHeight = moreButtonWidth * 44 / 94.0f;
    CGRect  moreButtonFrame=CGRectMake(SCREEN_WIDTH-10-moreButtonWidth, moreButtonPadding, moreButtonWidth, moreButtonHeight);
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setFrame:moreButtonFrame];
    [_moreButton setBackgroundImage:moreButtonImage forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreButton];
    
    //颜色条
    CGRect colorViewFrame=CGRectMake(0, 5, 3, CGRectGetMaxY(moreButtonFrame)+moreButtonPadding-10);
    UIView * colorView=[[UIView alloc] initWithFrame:colorViewFrame];
    [colorView setBackgroundColor:appPublicColor];
    [self addSubview:colorView];
    
    //标题
    CGRect titleLabelFrame=CGRectMake(CGRectGetMaxX(colorViewFrame)+10, moreButtonPadding, 100, CGRectGetHeight(colorViewFrame));
    self.titleLabel=[[UILabel alloc] initWithFrame:titleLabelFrame];
    [_titleLabel setText:@""];
    [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:15]];
    [_titleLabel setNumberOfLines:1];
    [_titleLabel setTextColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1]];
    [_titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_titleLabel];
    
    
    for (NSInteger i = 0; i < 6; i++) {

        CGFloat itemWidth = (SCREEN_WIDTH-10-10-3-3)/3.0f;
        CGFloat itemHeight = (cellHeight-CGRectGetMaxY(titleLabelFrame)-5)*SCREEN_SCALE/2.0f;
        
        CGFloat itemX = 10+(itemWidth+3)*(i%3);
        CGFloat itemY = CGRectGetMaxY(titleLabelFrame)+5+itemHeight*(i/3);
        CGRect itemFrame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
        MovieItem *item = [[MovieItem alloc] initWithFrame:itemFrame];
        item.tag = 100 + i;
        [self addSubview:item];
    }
}

- (void)setCellModel:(HomeMainTableViewCellModel *)cellModel {
    _cellModel = cellModel;
    _titleLabel.text = cellModel.title;
    for (NSInteger i = 0; i < (cellModel.videos.count<6?cellModel.videos.count:6); i++) {
        MovieItem *item = [self viewWithTag:100+i];
        MovieItemModel *itemModel = [[MovieItemModel alloc] init];
        [itemModel setValuesForKeysWithDictionary:cellModel.videos[i]];
        item.itemModel = itemModel;
    }
}

- (void)moreAction {
    NSLog(@"更多541231");
    UINavigationController *nvc = (UINavigationController *)[[(AppDelegate *)[UIApplication sharedApplication].delegate window] rootViewController];
    EpisodeSortViewController *episodeSortVC = [[EpisodeSortViewController alloc] init];
    episodeSortVC.imageItemModel.title = _cellModel.title;
    episodeSortVC.imageItemModel.cate_id = _cellModel.filter_cate_id;
    episodeSortVC.imageItemModel.year_id = _cellModel.filter_year_id;
    episodeSortVC.imageItemModel.sort_type = _cellModel.filter_sort_type;
    episodeSortVC.imageItemModel.is_complete = _cellModel.filter_is_completed;
    [nvc pushViewController:episodeSortVC animated:YES];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
