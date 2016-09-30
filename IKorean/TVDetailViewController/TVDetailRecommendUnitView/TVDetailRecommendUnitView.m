//
//  TVDetailRecommendUnitView.m
//  ICinema
//
//  Created by yunlongwang on 16/7/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "TVDetailRecommendUnitView.h"
#import "RecommendItem.h"

@interface TVDetailRecommendUnitView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView * recommendCollectionView;
@property (nonatomic,strong) NSMutableArray * recommendModelArray;
@end

@implementation TVDetailRecommendUnitView

-(id)initWithFrame:(CGRect)frame
   recommendVideos:(NSArray *)recommends
selectSomeMovieItemBlock:(MovieItemAction)selectblock
{
    if (self=[super initWithFrame:frame])
    {
        NSInteger recommendCount=[recommends count];
        if (recommendCount)
        {
            [self setBackgroundColor:[UIColor whiteColor]];
            CGFloat selfWidth=CGRectGetWidth(frame);
            
            //灰色条
            CGRect frameOfGrayBar=CGRectMake(0, 0, selfWidth, 5);
            UIView * grayView=[[UIView alloc] initWithFrame:frameOfGrayBar];
            [grayView setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
            [self addSubview:grayView];
            //蓝色竖条
            
            CGRect frameOfBlueView=CGRectMake(0,CGRectGetMaxY(frameOfGrayBar)+10, 2.5, 14);
            UIView * blueView=[[UIView alloc] initWithFrame:frameOfBlueView];
            [blueView setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
            [self addSubview:blueView];
            
            //标题
            CGRect frameOfTitle=CGRectMake(CGRectGetMaxX(frameOfBlueView)+7, CGRectGetMinY(frameOfBlueView), 100, 14);
            UILabel * labelOfTitle=[[UILabel alloc] initWithFrame:frameOfTitle];
            [labelOfTitle setText:@"推荐"];
            [labelOfTitle setFont:[UIFont fontWithName:HYQiHei_65Pound size:14]];
            [labelOfTitle setNumberOfLines:1];
            [labelOfTitle setTextColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1]];
            [labelOfTitle setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:labelOfTitle];
            
            _recommendModelArray = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *arrDic in recommends) {
                MovieItemModel *model = [[MovieItemModel alloc] init];
                [model setValuesForKeysWithDictionary:arrDic];
                [_recommendModelArray addObject:model];
            }
            
            
            
            // 相关视频collectionView
            UICollectionViewFlowLayout *recommendFlowLayout = [[UICollectionViewFlowLayout alloc] init];
            recommendFlowLayout.minimumLineSpacing = 5;
            recommendFlowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
            recommendFlowLayout.itemSize = CGSizeMake(115, 175);
            recommendFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            _recommendCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(frameOfTitle), SCREEN_WIDTH, 185) collectionViewLayout:recommendFlowLayout];
            [_recommendCollectionView registerClass:[RecommendItem class] forCellWithReuseIdentifier:@"recommendItem"];
            _recommendCollectionView.backgroundColor = [UIColor whiteColor];
            _recommendCollectionView.showsVerticalScrollIndicator = NO;
            _recommendCollectionView.showsHorizontalScrollIndicator = NO;
            _recommendCollectionView.delegate = self;
            _recommendCollectionView.dataSource = self;
            [self addSubview:_recommendCollectionView];
            
            CGRect frameOfSelf=self.frame;
            frameOfSelf.size.height=CGRectGetMaxY(_recommendCollectionView.frame);
            self.frame=frameOfSelf;
        }
    }
    return self;
}

#pragma mark - UICollectionViewDataSourceDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger itemsNumber;

    itemsNumber = [_recommendModelArray count];

    return itemsNumber;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *collectionCell;

        
    RecommendItem *cell = (RecommendItem *)[collectionView dequeueReusableCellWithReuseIdentifier:@"recommendItem" forIndexPath:indexPath];
    cell.model = _recommendModelArray[indexPath.row];
    collectionCell = cell;

    
    return collectionCell;
}

@end
