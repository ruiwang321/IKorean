//
//  EpisodePlanView.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "EpisodePlanView.h"
#import "EpisodePlanTableViewCell.h"

@interface EpisodePlanView () <UITableViewDelegate, UITableViewDataSource> {
    BOOL is_refreshed;
    ICELoadingView *_loadingView;
}

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation EpisodePlanView

- (void)dealloc {
    NSLog(@"dealloc planVIew");
    [_loadingView destroyLoading];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubView];
        self.backgroundColor = [UIColor whiteColor];
        is_refreshed = NO;
    }
    return self;
}

- (void)createSubView {
    if (_listView==nil)
    {

        self.listView=[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        
        [_listView setDelegate:self];
        [_listView setDataSource:self];
        _listView.rowHeight = 170;
        _listView.bounces = NO;
        [_listView setBackgroundColor:[UIColor clearColor]];
        [_listView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_listView registerNib:[UINib nibWithNibName:@"EpisodePlanTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"episodePlan"];
        [self addSubview:_listView];
    }
    
    _loadingView = [[ICELoadingView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _loadingView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-64);
    [self addSubview:_loadingView];
    [_loadingView startLoading];
}

- (void)loadDataWithDate:(NSDate *)date {
    if (!is_refreshed) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMdd";
        NSString *dateStr = [formatter stringFromDate:date];
        __weak typeof(self) wself = self;
        [MYNetworking GET:urlOfGetPlanTable parameters:@{@"date":@(dateStr.integerValue)} progress:nil success:^(NSURLSessionDataTask * _Nonnull tesk, id  _Nullable responseObject) {
            is_refreshed = YES;
            [wself updateSubViewsWithResponseObject:responseObject];
            [_loadingView stopLoading];
            [_loadingView destroyLoading];
            _loadingView = nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [wself updateSubViewsWithResponseObject:nil];
            [_loadingView stopLoading];
            [_loadingView destroyLoading];
        }];
    }
}

- (void)updateSubViewsWithResponseObject:(id)responseObject {
    if (responseObject == nil) {
        //错误处理
        return;
    }
    
    if ([responseObject[@"code"] integerValue] == 1) {
        if (responseObject[@"data"]&&[responseObject[@"data"] count]) {

            for (NSDictionary *dic in responseObject[@"data"]) {
                EpisodePlanModel *model = [[EpisodePlanModel alloc] init];
                [model setValuesForKeysWithDictionary:dic];
                [self.dataArray addObject:model];
            }
        }
        [_listView reloadData];
    }
}

#pragma mark - tableView代理和数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EpisodePlanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"episodePlan"];
    cell.episodePlanModel = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark getter 
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
