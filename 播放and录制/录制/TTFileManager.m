//
//  TTFileManager.m
//  CaptureVideo
//
//  Created by 邴天宇 on 15/9/22.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//
#import "TTheader.h"

#define PHONENUMBER @"15590284058"

@implementation TTFileManager
+ (id)defaultManager
{
    TTFileManager* manager = [[TTFileManager alloc] init];
    NSFileManager* filemanager = [NSFileManager defaultManager];
    
    NSString* path = [manager getFileBasePath];
    NSLog(@"path = %@", path);
    NSURL* urlPath = [NSURL fileURLWithPath:path];
    BOOL falg;
    falg = [filemanager createDirectoryAtURL:urlPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSLog(@"falg = %d", falg);
    
    return manager;
}

- (void)removeFileWithUrl:(NSURL*)url block:(void (^)(BOOL success))callblock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:url.path]) {
            NSError *error;
            [fileManager removeItemAtPath:url.path error:&error];
            NSLog(@"删除成功---->%@",url);
            if (callblock) {
                if (error) {
                    callblock(NO);
                }
                else{
                    callblock(YES);
                }
            }
        }
    });
}

- (void)conversionFormatMp4WithUrl:(NSURL*)videoUrl videoUrl:(NSString*)url videoblock:(void (^)(BOOL, NSString*))callblock
{
    AVURLAsset* avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    NSArray* compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
  
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession* exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        //        NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.mp4", [formater stringFromDate:[NSDate date]]];
        
        exportSession.outputURL = [self filePathUrlWithUrl:url]; //转换输出地址
        exportSession.outputFileType = AVFileTypeMPEG4; //转换格式 支持安卓设备播放格式
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                NSLog(@"%@",exportSession.error);
                if (callblock) {
                    callblock(NO,[NSString stringWithFormat:@"%@",exportSession.error]);
                }
                break;
                case AVAssetExportSessionStatusCancelled:
                break;
                case AVAssetExportSessionStatusCompleted:{
                    NSLog(@"转换完成");
//                    NSLog(@"---文件大小:---->%f----地址-----> %@",[self getFileSizeWithUrl:[self filePathUrlWithUrl:url]],[self filePathUrlWithUrl:url]);
                    if (callblock) {
                        callblock(YES,[self filePathWithUrl:url]);
                    }
                    break;
                }
                default:
                break;
            }
        }];
    }
}

- (CGFloat)getFileSizeWithPath:(NSString*)path
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:[self filePathWithUrl:path]]) {
        NSDictionary* fileDic = [fileManager attributesOfItemAtPath:[self filePathWithUrl:path] error:nil]; //获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0 * size / 1024;
    }
    return filesize;
}

- (CGFloat)getFileSizeWithUrl:(NSURL*)url
{
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:url.path]) {
        NSDictionary* fileDic = [fileManager attributesOfItemAtPath:url.path error:nil]; //获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0 * size / 1024;
    }
    return filesize;
}

- (NSString*)filePathWithUrl:(NSString*)url
{
    NSString* fileName = [url md5String];
    return [NSString stringWithFormat:@"%@/%@.mp4", [self getFileBasePath], fileName];
}

- (NSURL*)filePathUrlWithUrl:(NSString*)url
{
    return [NSURL fileURLWithPath:[self filePathWithUrl:url]];
}

/*
 *   获得根路径
 */
- (NSString*)getFileBasePath
{
    NSString* basePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString* path = [basePath stringByAppendingPathComponent:PHONENUMBER];
    
    return path;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}


@end
