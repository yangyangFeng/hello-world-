//
//  TTFileManager.h
//  CaptureVideo
//
//  Created by 邴天宇 on 15/9/22.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
@interface TTFileManager : NSObject
/*
 *  获得实例化对象,返回并不是 单例
 */
+(id)defaultManager;
/*
 *  视频url转本地路径  return srting
 */
- (NSString *)filePathWithUrl:(NSString *)url;
/*
 *  视频url转本地路径 return NSURL
 */
- (NSURL *)filePathUrlWithUrl:(NSString *)url;
/*
 *  根据完整路径 删除
 */
-(void)removeFileWithUrl:(NSURL *)url block:(void (^)(BOOL success))callblock;

/*
 *  根据视频url找到视频并转换格式
 */
-(void)conversionFormatMp4WithUrl:(NSURL *)videoUrl videoUrl:(NSString *)url videoblock:(void (^)(BOOL,NSString*))callblock;
/*
 *  根据视频url计算视频文件大小
 */
- (CGFloat)getFileSizeWithPath:(NSString *)path;
/*
 *  根据视频url计算视频文件大小
 */
- (CGFloat)getFileSizeWithUrl:(NSURL *)url;

@end
