//
//  TTDownLoaderManager.m
//  评论测试
//
//  Created by 邴天宇 on 15/11/9.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#import "TTDownLoaderManager.h"
#import <AFNetworking.h>
#define kPathImage1 @"http://farm8.staticflickr.com/7085/7383444834_7dd747e70a_o.jpg"
#define kPathImage2 @"http://farm8.staticflickr.com/7099/7383512334_e4b1d03bfb_o.jpg"
static TTDownLoaderManager * manager = nil;
@interface TTDownLoaderManager ()
{
    NSOperationQueue * _queue;
}
@property (nonatomic, strong) NSMutableDictionary * down_dic;
@end

@implementation TTDownLoaderManager
- (instancetype)init
{
    self = [super init];
    if (self) {


        
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 4;
        
 
    }
    return self;
}

+ (id)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTDownLoaderManager alloc]init];
        manager.down_dic = [NSMutableDictionary dictionary];
    });
    return manager;
}
#pragma mark   ==============Public methods==============
/**
 * 下载文件
 */
- (void)downloadFileURL:(NSString *)aUrl fileName:(NSString *)aFileName progress:(void (^)(float progress))down_progress success:(void (^)(NSString * path))down_success failed:(void (^)(NSError *))down_failed
{
    TTDownLoader * down_loader = [[TTDownLoader alloc]init];
    [self.down_dic setObject:down_loader forKey:aFileName];
    [down_loader downloadFileURL:aUrl fileName:aFileName block:^(float progress) {
        if (down_progress) {
            down_progress(progress);
        }
    } block:^(NSString *path) {
        [self.down_dic removeObjectForKey:aFileName];
        if (down_success) {
            down_success(path);
        }
    } block:^(NSError * error) {
        if (down_failed) {
            down_failed(error);
        }
    }];
}
- (void)stopWithDownLoader:(TTDownLoader *)loader
{
    [loader stop];
}
- (void)startWithDownLoader:(TTDownLoader *)loader
{
    [loader start];
}
- (void)pauseWithDownLoader:(TTDownLoader *)loader
{
    [loader pause];
}
- (void)cancle
{
    for (NSString * key in self.down_dic.allKeys) {
        TTDownLoader * loader = self.down_dic[key];
        [self stopWithDownLoader:loader];
    }
}
- (TTDownLoader *)objectForFileName:(NSString *)fileName
{
    if (fileName) {
        TTDownLoader * lodaer = self.down_dic[fileName];
        return lodaer;
    }
    else{
        return nil;
    }

}
- (void)stopDownLoaderWithFileName:(NSString *)fileName
{
    TTDownLoader * loader = [self objectForFileName:fileName];
    [loader stop];
}


//- (void)downloadFileURL:(NSString *)aUrl savePath:(NSString *)aSavePath fileName:(NSString *)aFileName block:(void (^)(float progress))down_progress block:(void (^)())success block:(void (^)(NSError *))failed
//{
//    NSBlockOperation * block = [NSBlockOperation blockOperationWithBlock:^{
//        TTDownLoader * down = [[TTDownLoader alloc]init];
//        [down downloadFileURL:aUrl fileName:aFileName block:^(float progress) {
//            
//        } block:^(NSString *path) {
//            
//        } block:^(NSError * error) {
//            
//        }];
//    }];
//    [_queue addOperation:block];
//}

@end
