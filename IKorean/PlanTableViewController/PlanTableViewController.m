//
//  PlanTableViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "PlanTableViewController.h"
#import "DateListItem.h"
#import "EpisodePlanView.h"

static NSInteger const oneDay = 86400;
@interface PlanTableViewController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSInteger selectIndex;
}

@property (nonatomic, strong) UICollectionView *dateList;
@property (nonatomic, strong) NSMutableArray <NSDate *>*dateArr;
@property (nonatomic, strong) ICESlideBackGestureConflictScrollView *mainScrollView;

@end

@implementation PlanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"影视排期";
    [self setLeftButtonWithImageName:@"back@2x" action:@selector(back)];
    selectIndex = 7;  //默认选中今天
    [self createSubViews];

}

- (void)createSubViews {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH/5.5, 44);
    _dateList = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 44) collectionViewLayout:flowLayout];
    _dateList.delegate = self;
    _dateList.dataSource = self;
    _dateList.showsHorizontalScrollIndicator = NO;
    _dateList.backgroundColor = [UIColor colorWithRed:246/255.0f green:246/255.0f blue:246/255.0f alpha:1];

    [_dateList registerNib:[UINib nibWithNibName:@"DateListItem" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"dateItem"];
    [self.view addSubview:_dateList];
    
    _mainScrollView = [[ICESlideBackGestureConflictScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_dateList.frame), SCREEN_WIDTH, SCREEN_HEIGHT-CGRectGetMaxY(_dateList.frame))];
    _mainScrollView.backgroundColor = [UIColor grayColor];
    _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*15, 0);
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.delegate = self;
    _mainScrollView.bounces = NO;
    
    // 设置偏移量
    _mainScrollView.contentOffset = CGPointMake(SCREEN_WIDTH*selectIndex, 0);
    [_dateList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self.view addSubview:_mainScrollView];
    for (NSInteger i = 0; i < 15; i++) {
        CGRect planViewFrame = CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, _mainScrollView.bounds.size.height);
        EpisodePlanView *planView = [[EpisodePlanView alloc] initWithFrame:planViewFrame];
        planView.tag = 1000+i;
        [_mainScrollView addSubview:planView];
        __weak typeof(self) wself = self;
        planView.episodePlanViewBlock = ^(NSInteger vid) {
            [wself goMovieDetailViewWithID:vid];
        };
    }
    // 刷新今日Plan
    EpisodePlanView *planView = [_mainScrollView viewWithTag:1000+selectIndex];
    [planView loadDataWithDate:self.dateArr[selectIndex]];
}

- (void)goMovieDetailViewWithID:(NSInteger)movieID
{
    MovieDetailViewController * tv=[[MovieDetailViewController alloc]initWithMovieID:movieID];
    [self.navigationController pushViewController:tv animated:YES];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollection代理和数据源方法

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 15;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DateListItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"dateItem" forIndexPath:indexPath];
    
    [item showDate:self.dateArr[indexPath.row] withIsSelected:indexPath.row==selectIndex];
    return item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectIndex = indexPath.row;
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    _mainScrollView.contentOffset = CGPointMake(indexPath.row*SCREEN_WIDTH, 0);
    EpisodePlanView *planView = [_mainScrollView viewWithTag:1000+indexPath.row];
    [planView loadDataWithDate:self.dateArr[indexPath.row]];
    [collectionView reloadData];
}

#pragma mark UIScrollView代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == _mainScrollView) {
        selectIndex = scrollView.contentOffset.x/SCREEN_WIDTH;
        [_dateList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        EpisodePlanView *planView = [_mainScrollView viewWithTag:1000+selectIndex];
        [planView loadDataWithDate:self.dateArr[selectIndex]];
        [_dateList reloadData];
    }
}

#pragma mark getter
- (NSMutableArray *)dateArr {
    if (_dateArr == nil) {
        _dateArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 15; i++) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:oneDay*(i-7)];
            [_dateArr addObject:date];
        }
    }
    return _dateArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
