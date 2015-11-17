//
//  TTHttpRequest.h
//  评论测试
//
//  Created by 邴天宇 on 15/11/9.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTDownLoader.h"
@interface TTDownLoaderManager : NSObject
/**
 * 单例方法
 */
+ (id)shared;

/**
 * 下载文件
 */
- (void)downloadFileURL:(NSString *)aUrl fileName:(NSString *)aFileName progress:(void (^)(float progress))down_progress success:(void (^)(NSString * path))down_success failed:(void (^)(NSError * error))down_failed;
/**
 * 根据名字获得当前下载器
 */
- (TTDownLoader *)objectForFileName:(NSString *)fileName;
/**
 * 根据名字结束当前下载器
 */
- (void)stopDownLoaderWithFileName:(NSString *)fileName;
/**
 * 结束当前下载
 */
- (void)stopWithDownLoader:(TTDownLoader *)loader;
// 取消全部下载
- (void)cancle;

/**
 * 下载文件
 *
 * @param string aUrl 请求文件地址
 * @param string aSavePath 保存地址
 * @param string aFileName 文件名
 */
- (void)downloadFileURL:(NSString *)aUrl savePath:(NSString *)aSavePath fileName:(NSString *)aFileName block:(void (^)(float progress))down_progress block:(void (^)())success block:(void (^)(NSError *))failed;


@end
