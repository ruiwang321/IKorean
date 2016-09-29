//
//  SearchViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/29.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchView.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) wself = self;
    SearchView * searchView=[[SearchView alloc] initWithFrame:self.view.bounds
                                             selectMovieBlock:^(NSInteger movieID, NSString * title) {
                                                 [wself goMovieDetailViewWithID:movieID];
                                                 [wself.view endEditing:YES];
                                             } backAction:^{
                                                 [wself.navigationController popViewControllerAnimated:YES];
                                             }];
    [self.view addSubview:searchView];
}

- (void)goMovieDetailViewWithID:(NSInteger)movieID
{
    MovieDetailViewController * tv=[[MovieDetailViewController alloc]initWithMovieID:movieID];
    [self.navigationController pushViewController:tv animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
