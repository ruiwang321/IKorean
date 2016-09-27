//
//  TestViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/26.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "TestViewController.h"
#import <AVKit/AVKit.h>
#import "JsPlayer.h"

@interface TestViewController () <PlayVideoDelegate>

@end

@implementation TestViewController
- (IBAction)action:(id)sender {
    
    JsPlayer *player = [JsPlayer sharedInstance];
    player.delegate = self;
    
    [MYNetworking GET:@"http://hj.api.29pai.com/video/detail" parameters:@{@"vid":_vid} progress:nil success:^(NSURLSessionDataTask *tesk, id responseObject) {
        NSString *linkUrl = [[responseObject[@"episode"] firstObject][@"data"] firstObject][@"link"];
        
        player.vid = _vid;
        player.url = linkUrl;
        [player getVideoUrl];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    
    
    
}

- (void)play:(NSString *)url {

    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:url]];
    playerVC.player = player;
    [player play];
    [self presentViewController:playerVC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
