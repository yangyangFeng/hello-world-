//
//  TYDownLoader.h
//  TYDownLoader
//
//  Created by 邴天宇 on 15/3/24.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYDownLoader : NSObject
// @pragma 下载远程url(连接到服务器的路径)
@property (nonatomic, retain) NSString * url;

// @pragma  下载后的存储路径
@property (nonatomic, retain) NSString * destinationPath;

//@pragma file name;
@property (nonatomic, retain) NSString * fileName;

// @pragma  下载 state 监测
@property (nonatomic,readonly,getter=isDownLoading) BOOL Downloading;

//  @pragma 监听下载进度
@property (nonatomic, copy) void(^progressHandler) (double progress);

//  @pragma 监听完成
@property (nonatomic, copy) void (^finishHandler)();

//  @pragma 监听错误
@property (nonatomic, copy) void (^errorHandler)(NSError * error);

//  @pragma 监听下载速度
@property (nonatomic, copy) void (^DownloadSpeed) (long long number);

/**
 *  暂停 下载
 */
- (void)pause;



/**
 *  开始  下载
 */
- (void)start;
/*!
 *  建立下载
 *
 *  @param url  网址
 *  @param name 文件名字
 */
+ (TYDownLoader * )setDownLoaderMessageUrl:(NSString *)url name:(NSString *)name Queue:(NSOperationQueue *)mainQueue;
/*!
 *  获得下载文件路径
 *
 *  @param name 文件名
 *
 *  @return 文件路径
 */
+ (NSString *)getDownLoaderMessage:(NSString *)name;

@end
