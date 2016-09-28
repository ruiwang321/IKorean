//
//  JsPlayer.h
//  video2
//
//  Created by 荆哲 on 16/8/31.
//  Copyright © 2016年 荆哲. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayVideoDelegate

-(void) play:(NSString*) url;

@end

@interface JsPlayer : NSObject //<NSURLConnectionDataDelegate>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSNumber *vid;
@property (nonatomic, weak) id<PlayVideoDelegate> delegate;

- (NSString *)getVideoUrl;
- (void)playVideo:(NSString*)url;
- (void)errorReport;
+ (JsPlayer*)sharedInstance;
- (NSStringEncoding*) gbkEnc;

+ (void)startJPEngine;
+ (void)updateJsFile;

@end
