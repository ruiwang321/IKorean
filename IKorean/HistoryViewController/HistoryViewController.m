//
//  HistoryViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryOrFavouriteTableViewCell.h"


static NSInteger const oneDay = 86400;
@interface HistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *delHistoryArray;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIButton *backOrAllSelBtn;
@property (nonatomic, strong) UIButton *delBtn;
@property (nonatomic, strong) NSMutableArray *historyDataArray;

@property (nonatomic, strong) NSMutableDictionary *historyDataDic;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史记录";
    
    NSArray *sqlArr = [[TVDataHelper shareInstance] getAllPlayHistory];
    // 测试数据
    _historyDataArray = [NSMutableArray array];
    
    _historyDataDic = [NSMutableDictionary dictionary];
    for (NSDictionary *arrDic in sqlArr) {
        HistoryOrFavouriteDataModel *model = [[HistoryOrFavouriteDataModel alloc] init];
        [model setValuesForKeysWithDictionary:arrDic];
        
//        double passTime = [[NSDate date] timeIntervalSince1970]-model.timeStamp.integerValue;
//        if (passTime/oneDay>0) {
//            
//        }else if (1<passTime/oneDay && passTime/oneDay<7) {
//            
//        }else {
//            
//        }
        model.title = [NSString stringWithFormat:@"%@ 第%ld集",arrDic[@"title"],[arrDic[@"episodeNumber"] integerValue]];
        [_historyDataArray addObject:model];
    }
    
    
    
    _backOrAllSelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backOrAllSelBtn setImage:IMAGENAME(@"back@2x", @"png") forState:UIControlStateNormal];
    _backOrAllSelBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    _backOrAllSelBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    _backOrAllSelBtn.frame = CGRectMake(0, 25, 50, 40);
    [_backOrAllSelBtn addTarget:self action:@selector(backOrAllselAction) forControlEvents:UIControlEventTouchUpInside];
    [self.myNavigationBar addSubview:_backOrAllSelBtn];
    
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_editBtn setTitle:@"取消" forState:UIControlStateSelected];
    _editBtn.frame = CGRectMake(SCREEN_WIDTH-50, 25, 50, 40);
    [_editBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.myNavigationBar addSubview:_editBtn];
    [self createMainTableView];
}

- (void)createMainTableView {
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-self.navigationBarHeight) style:UITableViewStylePlain];
    [_mainTableView registerNib:[UINib nibWithNibName:@"HistoryOrFavouriteTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.rowHeight = 120;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableViewDelegate Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    _editBtn.hidden = !_historyDataArray.count;  // 根据数据有无判断编辑按钮显隐
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryOrFavouriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.model = _historyDataArray[indexPath.row];
    [cell setEdit:_editBtn.selected];
    [cell setIsSelect:[self.delHistoryArray containsObject:_historyDataArray[indexPath.row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_editBtn.selected) {
        if ([self.delHistoryArray containsObject:_historyDataArray[indexPath.row]]) {
            [self.delHistoryArray removeObject:_historyDataArray[indexPath.row]];
        }else {
            [self.delHistoryArray addObject:_historyDataArray[indexPath.row]];
        }
        [self updateDelBtnTitleAndTBView];
    }else {
        HistoryOrFavouriteDataModel *model = _historyDataArray[indexPath.row];
    
        [self goMovieDetailViewWithID:model.vid.integerValue];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !_editBtn.selected;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryOrFavouriteDataModel *model = _historyDataArray[indexPath.row];
    [[TVDataHelper shareInstance] delatePlayHistoryWithVideoID:model.vid];
    [_historyDataArray removeObjectAtIndex:indexPath.row];
    [tableView reloadData];
}

#pragma mark 响应事件
- (void)goMovieDetailViewWithID:(NSInteger)movieID
{
    if ([[ICEAppHelper shareInstance] isPassAudit]) {
        MovieDetailViewController * tv=[[MovieDetailViewController alloc]initWithMovieID:movieID];
        [self.navigationController pushViewController:tv animated:YES];
    }else {
        TVDetailViewController *tvDetailVC = [[TVDetailViewController alloc] initWithID:movieID];
        [self.navigationController pushViewController:tvDetailVC animated:YES];
    }
    
}

- (void)editAction:(UIButton *)btn {
    if (btn.selected) {
        // 取消编辑
        [_backOrAllSelBtn setImage:IMAGENAME(@"back@2x", @"png") forState:UIControlStateNormal];
        [_backOrAllSelBtn setTitle:@"" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            _delBtn.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50);
        } completion:^(BOOL finished) {
            [self.delBtn removeFromSuperview];
            self.delBtn = nil;
        }];
        self.delHistoryArray = nil;
        _mainTableView.contentInset = UIEdgeInsetsZero;
    }else {
        // 编辑
        self.delBtn.hidden = NO;
        [_backOrAllSelBtn setImage:nil forState:UIControlStateNormal];
        [_backOrAllSelBtn setTitle:@"全选" forState:UIControlStateNormal];
        _mainTableView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(_delBtn.frame), 0);
    }
    [_mainTableView reloadData];
    btn.selected = !btn.selected;
}

- (void)backOrAllselAction {
    if (_editBtn.isSelected) {
        // 全选事件
        
        if (self.delHistoryArray.count < _historyDataArray.count) {
            [self.delHistoryArray removeAllObjects];
            [self.delHistoryArray addObjectsFromArray:_historyDataArray];
        }else {
            [self.delHistoryArray removeAllObjects];
        }
        [self updateDelBtnTitleAndTBView];
    }else {
        // 返回事件
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)delBtnAction {
    if (_delHistoryArray.count>0 && _delHistoryArray) {
        
        for (HistoryOrFavouriteDataModel *model in _delHistoryArray) {
            [[TVDataHelper shareInstance] delatePlayHistoryWithVideoID:model.vid];
        }
        [_historyDataArray removeObjectsInArray:_delHistoryArray];
        [_mainTableView reloadData];
        [self editAction:_editBtn];
    }
}

- (void)updateDelBtnTitleAndTBView {
    NSString *title = self.delHistoryArray.count?[NSString stringWithFormat:@"删除记录(%ld)", self.delHistoryArray.count]:@"删除记录";
    [self.delBtn setTitle:title forState:UIControlStateNormal];
    [_mainTableView reloadData];
}
#pragma mark getter 
- (NSMutableArray *)delHistoryArray {
    if (_delHistoryArray == nil) {
        _delHistoryArray = [NSMutableArray array];
    }
    return _delHistoryArray;
}

- (UIButton *)delBtn {
    if (_delBtn == nil) {
        _delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delBtn setTitle:@"删除记录" forState:UIControlStateNormal];
        _delBtn.backgroundColor = APPColor;
        _delBtn.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50);
        [UIView animateWithDuration:0.3 animations:^{
            _delBtn.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50);
        }];
        [_delBtn addTarget:self action:@selector(delBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_delBtn];
    }
    return _delBtn;
}

@end
