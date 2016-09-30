//
//  FavouriteViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/22.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "FavouriteViewController.h"
#import "HistoryOrFavouriteTableViewCell.h"

@interface FavouriteViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *delHistoryArray;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIButton *backOrAllSelBtn;
@property (nonatomic, strong) UIButton *delBtn;
@property (nonatomic, strong) NSMutableArray *favouriteDataArray;

@end

@implementation FavouriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的收藏";
    _favouriteDataArray = [NSMutableArray array];
    // 获取sql数据
    NSArray *sqlArr = [[TVDataHelper shareInstance] getMyFavorites];
    for (NSDictionary *arrDic in sqlArr) {
        HistoryOrFavouriteDataModel *model = [[HistoryOrFavouriteDataModel alloc] init];
        [model setValuesForKeysWithDictionary:arrDic];
        [_favouriteDataArray addObject:model];
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
    //    _mainTableView.editing = YES;
    [self.view addSubview:_mainTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableViewDelegate Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    _editBtn.hidden = !self.favouriteDataArray.count;  // 根据数据有无判断编辑按钮显隐
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _favouriteDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryOrFavouriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    
    cell.model = _favouriteDataArray[indexPath.row];
    [cell setEdit:_editBtn.selected];
    [cell setIsSelect:[self.delHistoryArray containsObject:_favouriteDataArray[indexPath.row]]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_editBtn.selected) {
        if ([self.delHistoryArray containsObject:_favouriteDataArray[indexPath.row]]) {
            [self.delHistoryArray removeObject:_favouriteDataArray[indexPath.row]];
        }else {
            [self.delHistoryArray addObject:_favouriteDataArray[indexPath.row]];
        }
        [self updateDelBtnTitleAndTBView];
    }else {
        
        // 跳转视频播放VC
        HistoryOrFavouriteDataModel *model = self.favouriteDataArray[indexPath.row];
        [self goMovieDetailViewWithID:model.vid.integerValue];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !_editBtn.selected;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HistoryOrFavouriteDataModel *model = self.favouriteDataArray[indexPath.row];
    [[TVDataHelper shareInstance] cancelFavoriteVideoWithVideoID:model.vid];
    [self.favouriteDataArray removeObject:model];
    [tableView reloadData];
}

#pragma mark 响应事件
- (void)goMovieDetailViewWithID:(NSInteger)movieID
{
    MovieDetailViewController * tv=[[MovieDetailViewController alloc]initWithMovieID:movieID];
    [self.navigationController pushViewController:tv animated:YES];
}


- (void)delBtnAction {
    if (self.delHistoryArray.count == 0) {
        
    }else {
        for (HistoryOrFavouriteDataModel *model in self.delHistoryArray) {
            [[TVDataHelper shareInstance] cancelFavoriteVideoWithVideoID:model.vid];
        }
        [self.favouriteDataArray removeObjectsInArray:self.delHistoryArray];
        
        [self editAction:_editBtn];
        [_mainTableView reloadData];
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
        
        if (self.delHistoryArray.count < _favouriteDataArray.count) {
            [self.delHistoryArray removeAllObjects];
            [self.delHistoryArray addObjectsFromArray:_favouriteDataArray];
        }else {
            [self.delHistoryArray removeAllObjects];
        }
        [self updateDelBtnTitleAndTBView];
    }else {
        // 返回事件
        [self.navigationController popViewControllerAnimated:YES];
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
