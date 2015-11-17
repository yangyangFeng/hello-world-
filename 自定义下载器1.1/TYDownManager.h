//
//  TYDownManager.h
//  史上时尚时尚最时尚的闹钟
//
//  Created by 邴天宇 on 15/4/15.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYDownManager : NSObject

//  @pragma 监听下载进度
@property (nonatomic, copy) void(^progressHandler) (double progress);

+ (TYDownManager *)managerDownLoader;


- (void)beginDownLoaderWithUrl:(NSString *) url
                      fileName:(NSString *)name
                      complete:(void(^)(BOOL finish))block;
@end
