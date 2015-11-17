//
//  TTDownLoader.m
//  评论测试
//
//  Created by 邴天宇 on 15/11/10.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#import "TTDownLoader.h"
#import "TTFileManager.h"
#import <AFNetworking.h>

@interface TTDownLoader ()
{
    AFHTTPRequestOperation *operation;
}
@end
@implementation TTDownLoader
/**
 * 下载文件
 */
- (void)downloadFileURL:(NSString *)aUrl fileName:(NSString *)aFileName block:(void (^)(float progress))down_progress block:(void (^)(NSString * path))success block:(void (^)(NSError *))failed{

    
    NSString * filePath = [NSString stringWithFormat:@"%@/video/%@.mp4",[[TTFileManager defaultManager] getFileBasePath],aFileName];
    //检查本地文件是否已存在
//    NSString *fileName = [NSString stringWithFormat:@"%@/%@", aSavePath, aFileName];
    if ([[TTFileManager defaultManager] fileExistsWithName:aFileName file:^(NSData *data, BOOL isExist) {
        if (isExist) {
            if (down_progress) {
                down_progress(1.0);
            }
            success(filePath);
        }
    }]) return;
        //下载附件
        NSURL *url = [[NSURL alloc] initWithString:aUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.inputStream   = [NSInputStream inputStreamWithURL:url];
        operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//            NSLog(@"is download：%f -- %@", (float)totalBytesRead/totalBytesExpectedToRead, [NSThread currentThread]);
            if (down_progress) {
            down_progress((float)totalBytesRead/totalBytesExpectedToRead);
            }

        }];
        
        
        //已完成下载
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
//            NSData *audioData = [NSData dataWithContentsOfFile:filePath];
            if (success) {
                success(filePath);
            }
            //设置下载数据到res字典对象中并用代理返回下载数据NSData
            //            [self requestFinished:[NSDictionary dictionaryWithObject:audioData forKey:@"res"] tag:aTag];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failed) {
                failed(error);
            }
            //下载失败
            //            [self requestFailed:aTag];
        }];
        
        [operation start];
    
}

- (void)stop
{
    [operation cancel];
}

- (void)start
{
    [operation start];
}
- (void)pause
{
    [operation pause];
}
@end
