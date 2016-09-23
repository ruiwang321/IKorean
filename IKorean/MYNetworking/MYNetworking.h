//
//  MYNetworking.h
//  IKorean
//
//  Created by ruiwang on 16/9/12.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface MYNetworking : NSObject
+ (void)GET:(NSString *)URLString
 parameters:(id)parameters
   progress:(void (^)(NSProgress * downloadProgress))downloadProgress
    success:(void (^)(NSURLSessionDataTask * tesk, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

+ (void)POST:(NSString *)URLString
  parameters:(id)parameters
    progress:(void (^)(NSProgress * downloadProgress))downloadProgress
     success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;
@end
