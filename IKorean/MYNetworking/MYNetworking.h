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
   progress:(void (^)(NSProgress * _Nonnull downloadProgress))downloadProgress
    success:(void (^)(NSURLSessionDataTask * _Nonnull tesk, id _Nullable responseObject))success
    failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;
@end
