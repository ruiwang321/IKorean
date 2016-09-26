//
//  JsPlayer.m
//  video2
//
//  Created by 荆哲 on 16/8/31.
//  Copyright © 2016年 荆哲. All rights reserved.
//

#import "JsPlayer.h"
#import "AFNetworking.h"
#import "JPEngine.h"
#import "SSZipArchive.h"


static NSString const * jsFilesName = @"jsFiles";
@implementation JsPlayer


- (NSURL *)getVideoUrl {
    NSLog(@"getVideoUrl in objc");
    return nil;
}

// 播放视频
- (void)playVideo:(NSString*) url {
    NSLog(@"playVideo in objc");
    if (self.delegate != nil) {
        NSLog(@"toPlay");
        [self.delegate play:url];
    }
}

// 解析失败时上报服务器
- (void)errorReport {
    // TODO 上报服务器
    NSLog(@"errorReport %@", self.url);
}


+ (JsPlayer*) sharedInstance {
    static JsPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JsPlayer alloc] init];
        
        [sharedInstance updateJsFile];
        
        // 初始化JSPatch
        NSString *sourcePath = [[[NSString alloc] initWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),jsFilesName] stringByAppendingPathComponent:@"index.js"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
            [JPEngine startEngine];
            [JPEngine evaluateScriptWithPath:sourcePath];
        }
    });
    return sharedInstance;
}

- (NSStringEncoding) gbkEnc {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return enc;
}
- (void)updateJsFileWithoutFail {
    [MYNetworking GET:urlOfJsFileInfo parameters:nil progress:nil success:^(NSURLSessionDataTask *tesk, id responseObject) {
        
        if ([responseObject[@"code"] integerValue] == 1) {

                
            [self DownloadAndUnzipFile:responseObject[@"data"][@"link"]
                              fileName:[NSString stringWithFormat:@"%@", jsFilesName]
                         unzipPassword:responseObject[@"data"][@"password"]
                         jsFileVersion:responseObject[@"data"][@"ver"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)updateJsFile {
    [MYNetworking GET:urlOfJsFileInfo parameters:nil progress:nil success:^(NSURLSessionDataTask *tesk, id responseObject) {
        
        if ([responseObject[@"code"] integerValue] == 1) {
            
            
            NSInteger localJsFileVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"loaclJsFileVersion"]==nil?0:[[[NSUserDefaults standardUserDefaults] objectForKey:@"loaclJsFileVersion"] integerValue];
            
            if (localJsFileVersion < [responseObject[@"data"][@"ver"] integerValue]) {
                
                [self DownloadAndUnzipFile:responseObject[@"data"][@"link"]
                                  fileName:[NSString stringWithFormat:@"%@", jsFilesName]
                             unzipPassword:responseObject[@"data"][@"password"]
                             jsFileVersion:responseObject[@"data"][@"ver"]];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}


- (void)DownloadAndUnzipFile:(NSString*)fileUrl fileName:(NSString*)_fileName unzipPassword:(NSString *)password jsFileVersion:(NSNumber *)version
{

    NSString *documentPath = [[NSString alloc] initWithFormat:@"%@/Library/Caches/%@.zip",NSHomeDirectory(),_fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *jsDir = [[NSString alloc] initWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),_fileName];
    BOOL existed = [fileManager fileExistsAtPath:jsDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:jsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }

    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/zip",
                                                         nil];
    [manager GET:fileUrl parameters:nil progress:^(NSProgress *downloadProgress) {
        
    } success:^(NSURLSessionDataTask *tesk, id responseObject) {
        [responseObject writeToFile:documentPath options:NSDataWritingAtomic error:nil];
        if ([SSZipArchive unzipFileAtPath:documentPath toDestination:jsDir overwrite:YES password:password error:nil]) {
            [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"loaclJsFileVersion"];
//             初始化JSPatch
            NSString *sourcePath = [[[NSString alloc] initWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),jsFilesName] stringByAppendingPathComponent:@"index.js"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
                [JPEngine startEngine];
                [JPEngine evaluateScriptWithPath:sourcePath];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

}

@end
