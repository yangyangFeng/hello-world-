//
//  TTDownLoader.h
//  评论测试
//
//  Created by 邴天宇 on 15/11/10.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTDownLoader : NSObject
- (void)downloadFileURL:(NSString *)aUrl fileName:(NSString *)aFileName block:(void (^)(float progress))down_progress block:(void (^)(NSString * path))success block:(void (^)(NSError *))failed;
- (void)stop;
- (void)start;
- (void)pause;
@end
