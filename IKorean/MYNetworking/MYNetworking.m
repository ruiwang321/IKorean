//
//  MYNetworking.m
//  IKorean
//
//  Created by ruiwang on 16/9/12.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "MYNetworking.h"
#import "NSString+md5.h"

static NSString *const app_id = @"2";
static NSString *const app_version = @"1";
static NSString *const app_key = @"e9824d31c072f2ca4da33c21b109ff6c";

@implementation MYNetworking
+ (void)GET:(NSString *)URLString
 parameters:(id)parameters
   progress:(void (^)(NSProgress * downloadProgress))downloadProgress
    success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *urlpath = [URLString componentsSeparatedByString:@"http://hj.api.29pai.com/"].lastObject;
    NSString *time = [NSString stringWithFormat:@"%ld",(NSInteger)[[NSDate date] timeIntervalSince1970]];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@%@", app_id, time, urlpath, app_key, app_version].md5.lowercaseString;
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:app_id forHTTPHeaderField:@"a"];
    [manager.requestSerializer setValue:time forHTTPHeaderField:@"t"];
    [manager.requestSerializer setValue:app_version forHTTPHeaderField:@"v"];
    [manager.requestSerializer setValue:sign forHTTPHeaderField:@"s"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:URLString parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

+ (void)POST:(NSString *)URLString
  parameters:(id)parameters
    progress:(void (^)(NSProgress * downloadProgress))downloadProgress
     success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *urlpath = [URLString componentsSeparatedByString:@"http://hj.api.29pai.com/"].lastObject;
    NSString *time = [NSString stringWithFormat:@"%ld",(NSInteger)[[NSDate date] timeIntervalSince1970]];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@%@", app_id, time, urlpath, app_key, app_version].md5.lowercaseString;
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:app_id forHTTPHeaderField:@"a"];
    [manager.requestSerializer setValue:time forHTTPHeaderField:@"t"];
    [manager.requestSerializer setValue:app_version forHTTPHeaderField:@"v"];
    [manager.requestSerializer setValue:sign forHTTPHeaderField:@"s"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager POST:URLString parameters:parameters constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}
@end
