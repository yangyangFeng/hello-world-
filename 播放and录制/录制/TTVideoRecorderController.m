//
//  TTVideoRecorderController.m
//  CaptureVideo
//
//  Created by 邴天宇 on 15/10/10.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#import "TTheader.h"

#define MAX_VIDEO_TIME 10
static TTVideoRecorderController* recorderController = nil;
@interface TTVideoRecorderController () <TTVideoRecorderDelegate>
@property (nonatomic, strong) UIButton* recordButton;
@property (nonatomic, strong) UIToolbar* toolBar;
@property (nonatomic, strong) UIView* previewLayer; //预览图层
@property (nonatomic, strong) TTVideoRecorder* recorder;
@property (nonatomic, strong) AVplayerView* playView; //播放视频
@property (nonatomic, strong) UIImageView* focuscursor; //聚焦光标
@property (nonatomic, strong) VideoPlayController* videoPlay;
@property (nonatomic, assign) BOOL isRecording; //录制状态
@property (nonatomic, assign) BOOL isFocusing; //对焦状态
@property (nonatomic, assign) BOOL isControllerMiss; //控制器是否消失
@property (nonatomic, strong) TTProgress* progress; //进度条
@property (nonatomic, strong) UIBarButtonItem* finishButton;
@property (nonatomic, strong) NSURL* videoPath;
@end

@implementation TTVideoRecorderController
+ (id)shareRecorderController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorderController = [[TTVideoRecorderController alloc]init];
    });
    return recorderController;
}
#pragma mark ==============Lazy loading==============
- (UIButton*)recordButton
{
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        _recordButton.frame = CGRectMake(0, 0, 100, 100);
        _recordButton.center = CGPointMake(
            self.view.center.x,
            self.view.frame.size.height - (self.view.frame.size.height - self.previewLayer.frame.origin.y - self.previewLayer.frame.size.height) / 2.0);
        [_recordButton setImage:[UIImage imageNamed:@"按住拍.png"]
                       forState:UIControlStateNormal];
        [_recordButton addTarget:self
                          action:@selector(tapDidButton:)
                forControlEvents:(UIControlEventTouchUpInside)];
                
        UILongPressGestureRecognizer* longPress =
            [[UILongPressGestureRecognizer alloc]
                initWithTarget:self
                        action:@selector(longDidButton:)];
        longPress.minimumPressDuration = 0.3;
        [_recordButton addGestureRecognizer:longPress];
    }
    return _recordButton;
}

- (UIToolbar*)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc]
            initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _toolBar.barTintColor = [UIColor colorWithRed:16 / 255.0
                                                green:88 / 255.0
                                                 blue:207 / 255.0
                                                alpha:1.0];
        UIBarButtonItem* backItem =
            [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(backDidClick:)];
        UIBarButtonItem* placeholder = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _toolBar.tintColor = [UIColor whiteColor];
        _toolBar.items = @[ backItem, placeholder, self.finishButton ];
    }
    return _toolBar;
}
- (UIBarButtonItem*)finishButton
{
    if (!_finishButton) {
        _finishButton = [[UIBarButtonItem alloc] initWithTitle:@"使用此视频" style:UIBarButtonItemStylePlain target:self action:@selector(finishButtonDidClick:)];
        _finishButton.enabled = NO;
    }
    return _finishButton;
}
- (UIView*)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [[UIView alloc]
            initWithFrame:CGRectMake(0, self.toolBar.frame.origin.y + self.toolBar.frame.size.height,
                              self.view.frame.size.width,
                              self.view.frame.size.width)];
        [_previewLayer setBackgroundColor:[UIColor blackColor]];
    }
    return _previewLayer;
}

- (AVplayerView*)playView
{
    if (!_playView) {
        _playView = [[AVplayerView alloc]
            initWithFrame:CGRectMake(0, self.toolBar.frame.origin.y + self.toolBar.frame.size.height,
                              self.view.frame.size.width,
                              self.view.frame.size.width)];
    }
    return _playView;
}
- (UIImageView*)focuscursor
{
    if (!_focuscursor) {
        _focuscursor = [[UIImageView alloc]
            initWithImage:[UIImage imageNamed:@"touch_focus_x.png"]];
        _focuscursor.alpha = 0;
    }
    return _focuscursor;
}

- (TTProgress*)progress
{
    if (!_progress) {
        _progress = [[TTProgress alloc] initWithFrame:CGRectMake(0, self.playView.y + self.playView.height, WIDTH, 4)];
        _progress.backgroundColor = [UIColor whiteColor];
        [_progress setProgressViewColor:[UIColor blueColor]];
    }
    return _progress;
}
// 隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]
        setStatusBarHidden:YES
             withAnimation:UIStatusBarAnimationSlide];
    [self clear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.recorder closeAutofocus];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRecorder];
    [self setSubviews];
    // Do any additional setup after loading the view.
}
#pragma mark ==============Private methods==============
- (void)setSubviews
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.toolBar];
    
    [self.view addSubview:self.previewLayer];
    
    [self.view addSubview:self.recordButton];
    
    [self.view addSubview:self.progress];
    
    [self.previewLayer addSubview:self.focuscursor];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(tapDidFocusing:)];
    [self.previewLayer addGestureRecognizer:tap];
}

- (void)initRecorder
{
    self.recorder = [TTVideoRecorder shareRecorder];
    
    _recorder.delegate = self;
    
    _recorder.preViewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    
    [self.previewLayer.layer addSublayer:_recorder.preViewLayer];
}
// 重新录制
- (void)resetRecording
{
    if (self.playView) {
        [self.playView removePlay];
    }
}
/**
 *  清楚痕迹
 *
 */
- (void)clear
{
    [self.recorder openAutofocus];
    _isControllerMiss = NO;
    self.finishButton.enabled = NO;
    [self.progress show];
}
/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
- (void)setFocuscursorwithpoint:(CGPoint)point
{
    _isFocusing = YES;
    self.focuscursor.center = point;
    self.focuscursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focuscursor.alpha = 1.0;
    [UIView animateWithDuration:0.25
        animations:^{
        self.focuscursor.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }
        completion:^(BOOL finished) {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
            animation.values = @[@0.5f, @1.0f, @0.5f, @1.0f, @0.5f, @1.0f];
            animation.duration = 0.5f;
            [self.focuscursor.layer addAnimation:animation forKey:@"opacity"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3f animations:^{
                    self.focuscursor.alpha = 0;
                }];
            });
        _isFocusing = NO;
        }];
}
// 放大录制按钮
- (void)amplificationRecordButton
{
    [UIView animateWithDuration:0.25
        animations:^{
        _recordButton.transform = CGAffineTransformMakeScale(2.5, 2.5);
        _recordButton.alpha = 0;
        }
        completion:^(BOOL finished){
        
        }];
}
// 还原录制按钮
- (void)reductionRecordButton
{
    [UIView animateWithDuration:0.25
        animations:^{
        _recordButton.transform = CGAffineTransformMakeScale(1, 1);
        _recordButton.alpha = 1;
        }
        completion:^(BOOL finished){
        
        }];
}
#pragma mark ==============Triggering method==============
- (void)tapDidButton:(id)sender
{
    // 清除播放信息
    [self resetRecording];
    //使用此视频 button 设置为不可编辑状态
    self.finishButton.enabled = NO;
    [self amplificationRecordButton];
    __weak typeof(self) weakself = self;
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
        if (!_isRecording) {
          [weakself reductionRecordButton];
        }
        });
}

- (void)longDidButton:(UILongPressGestureRecognizer*)gesture
{

    if (gesture.state == UIGestureRecognizerStateBegan) {
    
        // 清除播放信息
        [self resetRecording];
        //使用此视频 button 设置为不可编辑状态
        self.finishButton.enabled = NO;
        [self amplificationRecordButton];
        // 开始录制
        _isRecording = YES;
        if (!self.recorder.captureSession.running) {
            [self.recorder.captureSession startRunning];
        }
        
        [self.recorder startRecording];
        self.progress.progress = 0;
        [self.progress show];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        //        NSLog(@"change");
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
    
        // 结束录制
        _isRecording = NO;
        [self reductionRecordButton];
        
        [self.recorder stopRecording];
    }
}

- (void)backDidClick:(id)sender
{
    _isControllerMiss = YES;
    // 清楚播放信息
    [self resetRecording];
    __weak typeof(self) weakself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakself resetRecording];
    }];
}
// 使用此视频
- (void)finishButtonDidClick:(id)sender
{
    if ([_delegate respondsToSelector:@selector(videoAcquisitionFinished:)]) {
        [_delegate videoAcquisitionFinished:_videoPath];
    }
}

- (void)tapDidFocusing:(UITapGestureRecognizer*)tap
{
    if (_isFocusing) {
        return;
    }
    
    CGPoint point = [tap locationInView:self.previewLayer];
    //对焦图片添加
    [self setFocuscursorwithpoint:point];
    //对焦点设置
    [_recorder adjustFocalLength:point];
}

#pragma mark ==============Delegate methods==============
// 开始录制
- (void)videoRecorderStartRecordingToOutPutFileAtURL:(NSURL*)fileURL
{

    [self.view addSubview:self.progress];
}

// 录制完成
- (void)videoRecorderFinishRecordingToOutPutFileAtURL:(NSURL*)outputFileURL
                                             duration:(CGFloat)videoDuration
                                             fileSize:(CGFloat)size
{
    // 结束录制
    _isRecording = NO;
    [self reductionRecordButton];
}
// 格式转换完成
- (void)videoRecorderFinishConversionFormatToOutPutFileAtURL:
            (NSURL*)outputFileURL duration:(CGFloat)videoDuration
                                                    fileSize:(CGFloat)size
{
    _videoPath = outputFileURL;
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isControllerMiss) {
            return ;
        }
            [weakself.recorder.captureSession stopRunning];
        [weakself.progress finished];
        //使用此视频 button 设置为 可编辑状态
        weakself.finishButton.enabled = YES;
        weakself.playView = [[AVplayerView alloc] initWithFrame:CGRectMake(0, 44,weakself.view.frame.size.width, weakself.view.frame.size.width)];
        [weakself.view addSubview:self.playView];
        
        [weakself.playView viewDidHidenBlock:^{
            [weakself.recorder.captureSession startRunning];
            [weakself.progress setProgress:0];
        }];
        
        weakself.playView.playWithUrl(outputFileURL).returnPoint(weakself.recordButton.center).hindenToolBar().showInView();
    });
}

// recorder正在录制的过程中
- (void)videoRecorderIsRecordingToOutPutFileAtURL:(NSURL*)outputFileURL
                                         duration:(CGFloat)videoDuration
{


    self.progress.progress =videoDuration / MAX_VIDEO_TIME ;
}
//自动对焦
-(void)captureDeviceAutofocus
{
    if (_isFocusing) {
        return;
    }
    [self setFocuscursorwithpoint:self.previewLayer.center];
}

// 视频截图
- (void)videoCaptureImage:(UIImage *)image
{

}

@end


