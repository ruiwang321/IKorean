//
//  HistoryViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryOrFavouriteTableViewCell.h"

@interface HistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史记录";
//    [self setLeftButtonWithImageName:@"" action:<#(SEL)#>]
    [self createMainTableView];
}

- (void)createMainTableView {
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-self.navigationBarHeight) style:UITableViewStyleGrouped];
    [_mainTableView registerNib:[UINib nibWithNibName:@"HistoryOrFavouriteTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.rowHeight = 80;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryOrFavouriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.selectImageWidth.constant = 0;
    cell.selectImageView.hidden = YES;
//    [cell sep]
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
