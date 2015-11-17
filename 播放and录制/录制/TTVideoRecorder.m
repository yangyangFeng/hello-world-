//
//  TTVideoRecorder.m
//  CaptureVideo
//
//  Created by 邴天宇 on 15/9/22.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//


#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#define SWITCH_SAVE_THE_PHOTO_ALBUM 0

#define TIMER_INTERVAL 0.05
#define KVideoRecorderSec 10
#define KVideoRecorderMinSec 0.3

static TTVideoRecorder * recorder = nil;
typedef void (^propertychangeblock)(AVCaptureDevice* capturedevice);
@interface TTVideoRecorder ()
@property (nonatomic, copy) void (^finishRecording)(BOOL success, NSString* fileUrl);

@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign, readwrite) CGFloat timeLength;
@property (nonatomic, strong, readwrite) NSString* fileName;
@property (nonatomic, strong) NSURL* url;

@property (nonatomic, assign) BOOL isCancle;

@property (strong, nonatomic) AVCaptureDeviceInput* videoDeviceInput;

@property (strong, nonatomic) AVCaptureDeviceInput* audioDeviceInput;

@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

@end

@implementation TTVideoRecorder
+ (id)shareRecorder
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            recorder = [[TTVideoRecorder alloc]init];
        });
        return recorder;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initCapture];
        //在viewwillapper 时开启, disapper 时关闭
//        [self openAutofocus];
    }
    return self;
}

- (void)initCapture
{
    self.isCancle = NO;
    //session---------------------------------
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //input
    AVCaptureDevice* backCamera = [self getCameraWithPosition:AVCaptureDevicePositionBack];
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [backCamera unlockForConfiguration];
    //    AVCaptureDevicePositionBack
    NSError * error;
    self.videoDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:backCamera error:&error];

    _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    [_captureSession addInput:_audioDeviceInput];
    [_captureSession addInput:_videoDeviceInput];
    
    //output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [_captureSession addOutput:_movieFileOutput];
    
    //preset
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //preview layer------------------
    self.preViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; //全屏预览
    
    // 视频截图
    _stillImageOutput = [AVCaptureStillImageOutput new];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    NSDictionary* outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    if ([_captureSession canAddOutput:_stillImageOutput])
        [_captureSession addOutput:_stillImageOutput];
        
    [_captureSession startRunning];
}


- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSString*, id>*)change context:(void*)context
{
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        if (adjustingFocus) {
      
            if ([_delegate respondsToSelector:@selector(captureDeviceAutofocus)]) {
                [_delegate captureDeviceAutofocus];
            }
        }
    }
}
//获取视频缩略图
- (UIImage*)getVideoThumbnail
{
    AVCaptureConnection* stillImageConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = AVCaptureVideoOrientationPortrait;
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:1];
    [_stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
                                                                     forKey:AVVideoCodecKey]];
                                                                     
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError* error) {
                                                       if (error) {
                                                           //                                                          [self displayErrorOnMainQueue:error withMessage:@"拍摄失败"];
                                                       }
                                                       else {
                                                           NSData* jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                               UIImage * image1 = [UIImage imageWithData:jpegData];
                                                           UIImageWriteToSavedPhotosAlbum(image1, nil, nil, nil);
                                                           if ([_delegate respondsToSelector:@selector(videoCaptureImage:)]) {
                                                               UIImage * image = [UIImage imageWithData:jpegData];
                                                               [_delegate videoCaptureImage:image];
                                                           }
                                                           CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                                                                       imageDataSampleBuffer,
                                                                                                                       kCMAttachmentMode_ShouldPropagate);
#if SWITCH_SAVE_THE_PHOTO_ALBUM
//                                                           保存到相册
                                                                                                                     ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                                                                                                                     [library writeImageDataToSavedPhotosAlbum:jpegData
                                                                                                                                                      metadata:(__bridge id)attachments
                                                                                                                                               completionBlock:^(NSURL* assetURL, NSError* error) {
                                                                                                                                                   if (error) {
                                                           //                                                                                            [self displayErrorOnMainQueue:error withMessage:@"保存失败"];
                                                                                                                                                   }
                                                                                                                                               }];
#endif
                                                           if (attachments)
                                                               CFRelease(attachments);
                                                       }
                                                   }];
    return nil;
}

#pragma mark ==============设置聚焦==============
- (void)adjustFocalLength:(CGPoint)point
{
    //    CGPoint point= [tapgesture locationInView:self.viewcontainer];
    //将ui坐标转化为摄像头坐标
    CGPoint camerapoint = [self.preViewLayer captureDevicePointOfInterestForPoint:point];
    
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:camerapoint monitorSubjectAreaChange:NO];
}

/*
 *  初始化timer并开始计时
 */
- (void)initTimer
{
    _timeLength = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTime:) userInfo:nil repeats:YES];
}
/*
 *  停止timer 并结束录制
 */
- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)onTime:(NSTimer*)timer
{
    _timeLength += TIMER_INTERVAL;
    
    if ([_delegate respondsToSelector:@selector(videoRecorderIsRecordingToOutPutFileAtURL:duration:)]) {
        [_delegate videoRecorderIsRecordingToOutPutFileAtURL:_url duration:_timeLength];
    }
    
    if (_timeLength / KVideoRecorderSec >= 1) {
        [self stopRecording];
    }
}

#pragma mark - 视频名以当前日期为名
- (NSString*)getVideoSaveFilePathString
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString* nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    return nowTimeStr;
}

#pragma mark   ==============Public methods==============
- (void)startRecording
{
    if (!_captureSession.isRunning) {
        [_captureSession startRunning];
    }
    _url = [[TTFileManager defaultManager] filePathUrlWithUrl:[self getVideoSaveFilePathString]];
    
    [_movieFileOutput startRecordingToOutputFileURL:_url recordingDelegate:self];
}

- (void)stopRecording
{
    [self stopTimer];
    if (_movieFileOutput.isRecording) {
        [_movieFileOutput stopRecording];
    }
}

- (void)cancleRecording
{
    _isCancle = YES;
    [self stopTimer];
    if (_movieFileOutput.isRecording) {
        [_movieFileOutput stopRecording];
    }
    if (_finishRecording) {
        _finishRecording(NO, NULL);
    }
}

- (void)openAutofocus{
    //监听自动对焦
    [[self getCameraWithPosition:AVCaptureDevicePositionBack] addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
}
// 关闭自动对焦
- (void)closeAutofocus{
    [[self getCameraWithPosition:AVCaptureDevicePositionBack] removeObserver:self forKeyPath:@"adjustingFocus"];
}
#pragma mark - 移除所有输入和输出
- (void)removeAllPut
{
//    if (_captureSession.running) {
//        [_captureSession stopRunning];
//    }
    [_captureSession removeInput:_videoDeviceInput];
    [_captureSession removeInput:_audioDeviceInput];
    [_captureSession removeOutput:_movieFileOutput];
}

#pragma mark - 视频输出代理
- (void)captureOutput:(AVCaptureFileOutput*)captureOutput didStartRecordingToOutputFileAtURL:(NSURL*)fileURL fromConnections:(NSArray*)connections
{
  
    //获取视频截图
    
    [self initTimer];
    if ([_delegate respondsToSelector:@selector(videoRecorderStartRecordingToOutPutFileAtURL:)]) {
        [_delegate videoRecorderStartRecordingToOutPutFileAtURL:fileURL];
    }
}

- (void)captureOutput:(AVCaptureFileOutput*)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL*)outputFileURL fromConnections:(NSArray*)connections error:(NSError*)error
{
    __weak typeof(self) weakself = self;
    NSLog(@"%s-- url = %@ ,recode = %f , int %lld kb", __func__, outputFileURL, CMTimeGetSeconds(captureOutput.recordedDuration), captureOutput.recordedFileSize / 1024);
    
    if (_timeLength < KVideoRecorderMinSec || _isCancle) {
        _timeLength = 0;
        
        [[TTFileManager defaultManager] removeFileWithUrl:outputFileURL block:nil];
        if (_isCancle) {
            _isCancle = NO;
        }
        
        return;
    }
    //转换格式
    [[TTFileManager defaultManager] conversionFormatMp4WithUrl:outputFileURL videoUrl:[self getVideoSaveFilePathString] videoblock:^(BOOL success, NSString* filePath) {
        if (success) {
            if ([weakself.delegate respondsToSelector:@selector(videoRecorderFinishConversionFormatToOutPutFileAtURL:duration:fileSize:)]) {
                [weakself.delegate videoRecorderFinishConversionFormatToOutPutFileAtURL:[NSURL fileURLWithPath:filePath] duration:CMTimeGetSeconds(captureOutput.recordedDuration) fileSize:captureOutput.recordedFileSize/ 1024];
            }
            
        }
    }];
    
    if ([weakself.delegate respondsToSelector:@selector(videoRecorderFinishRecordingToOutPutFileAtURL:duration:fileSize:)]) {
        [weakself.delegate videoRecorderFinishRecordingToOutPutFileAtURL:outputFileURL duration:CMTimeGetSeconds(captureOutput.recordedDuration) fileSize:captureOutput.recordedFileSize / 1024];
    }
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _preViewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer* videoPreviewLayer = self.preViewLayer; //需要按照项目实际情况修改
    
    if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    }
    else {
        CGRect cleanAperture;
        
        for (AVCaptureInputPort* port in [self.videoDeviceInput ports]) { //需要按照项目实际情况修改，必须是正在使用的videoInput
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    }
                    else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                }
                else if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    }
                    else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
- (AVCaptureDevice*)getCameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice* device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    //    NSLog(@"focus point: %f %f", point.x, point.y);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    AVCaptureDevice* device = [_videoDeviceInput device];
    NSError* error = nil;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported]) {
            [device setFocusPointOfInterest:point];
        }
        
        if ([device isFocusModeSupported:focusMode]) {
            [device setFocusMode:focusMode];
        }
        
        if ([device isExposurePointOfInterestSupported]) {
            [device setExposurePointOfInterest:point];
            }
            
            if ([device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            NSLog(@"对焦错误:%@", error);
        }
    });
}

@end
