//
//  TTVideoRecorder.h
//  CaptureVideo
//
//  Created by 邴天宇 on 15/9/22.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class TTVideoRecorder;
@protocol TTVideoRecorderDelegate <NSObject>

//recorder开始录制一段视频时
- (void)videoRecorderStartRecordingToOutPutFileAtURL:(NSURL *)fileURL;

//recorder正在录制的过程中
- (void)videoRecorderIsRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration;

//recorder完成一段视频的录制时
- (void)videoRecorderFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration fileSize:(CGFloat)size;

//recorder完成一段视频的录制时
- (void)videoRecorderFinishConversionFormatToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration fileSize:(CGFloat)size;

//自动对焦
- (void)captureDeviceAutofocus;

//视频截图
- (void)videoCaptureImage:(UIImage *)image;
@end

@interface TTVideoRecorder : NSObject<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, assign) id<TTVideoRecorderDelegate> delegate;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;


@property (nonatomic, assign, readonly, getter=timeLength) CGFloat  timeLength;
@property (nonatomic, strong, readonly) NSString * fileName;

+ (id)shareRecorder;

- (void)startRecording;
- (void)stopRecording;
- (void)cancleRecording;
- (void)removeAllPut;

- (void)adjustFocalLength:(CGPoint)point;
/**
 *  开启自动对焦
 */
- (void)openAutofocus;
/**
 *  关闭自动对焦(移除对焦监听)
 */
- (void)closeAutofocus;
//- (void)removeVideoWithName:(NSString *)name;
@end
