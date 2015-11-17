//
//  AVplayerView.m
//  播放测试
//
//  Created by 邴天宇 on 15/9/7.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import "AVplayerView.h"
#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height
@interface AVplayerView () {
    AVPlayerLayer* playerLayer;
    AVPlayer* player;
    AVPlayerItem* playerItem;
    BOOL isHidenAll;
    BOOL isplaying;
    BOOL isToolBar;
    NSTimer* isToolTimer;
    id avTimer;
    CGPoint _point;
    NSURL* _url;
}
@property (nonatomic, strong) UISlider* playSlider;
@property (nonatomic, strong) UIProgressView* playProgress;
@property (nonatomic, strong) UIView* playToolBar;
@property (nonatomic, strong) UIButton* videoPlay;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) NSString* totalTime;
@property (nonatomic, strong)     NSString * isSliding;
@end

@implementation AVplayerView

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self setPlayLayer];

//    [self addGestureRecognizers];

//    [self setSubviews];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isToolBar = YES;
}

- (void)setPlayLayer
{
    _contentPlayView = [[PlayView alloc] initWithFrame:self.view.frame];
    AVAsset* movieAsset = [AVURLAsset URLAssetWithURL:_url options:nil];
    playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = _contentPlayView.layer.bounds;

    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    _contentPlayView.backgroundColor = [UIColor blackColor];
    [_contentPlayView.layer addSublayer:playerLayer];
    self.view = _contentPlayView;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidPause:) name:AVPlayerItemPlaybackStalledNotification object:player.currentItem];
    //添加监听
    [self addprogressobserver];

    [self addobservertoplayeritem:player.currentItem];
}

- (void)setSubviews
{
    // 如果设置YES,隐藏所有控件
    if (isHidenAll) {
        return;
    }
    
    [self.view addSubview:self.playToolBar];

    [_playToolBar addSubview:self.playProgress];
    [_playToolBar addSubview:self.playSlider];
    [_playToolBar addSubview:self.videoPlay];
    [_playSlider addSubview:self.timeLabel];

    self.timeLabel.text = @"时长未知";
}

- (void)addGestureRecognizers
{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClick:)];

    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDidChange:)];

    [self.view addGestureRecognizer:tap];

    [self.view addGestureRecognizer:pinch];
}
#pragma mark - show
- (void)show
{
    [self setPlayLayer];
    
    [self addGestureRecognizers];
    
    [self setSubviews];
    
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.view];
    self.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         weakself.view.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (AVplayerView * (^)(UIView *))showInView
{
            __weak typeof(self) weakself = self;
    [weakself setPlayLayer];
    return ^AVplayerView *(UIView * view){
      
        _contentPlayView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
        //    _contentPlayView.layer.bounds = view.bounds;
        //    playerLayer.frame = _contentPlayView.layer.bounds;
        //    [_contentPlayView.layer addSublayer:playerLayer];
        playerLayer.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
        [view addSubview:_contentPlayView];
        weakself.view.transform = CGAffineTransformMakeScale(0.5, 0.5);

        [UIView animateWithDuration:0.3
                              delay:0
             usingSpringWithDamping:0.4
              initialSpringVelocity:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             weakself.view.transform = CGAffineTransformMakeScale(1, 1);
                         }
                         completion:^(BOOL finished){
                             
                         }];
        [weakself addGestureRecognizers];

        [weakself setSubviews];
        [weakself videoPlayDidClick:weakself.videoPlay];
        return self;
    };
}
// 移除
- (void)hiden{
    [UIView animateWithDuration:0.25 animations:^{
        _contentPlayView.alpha = 0;
    } completion:^(BOOL finished) {
        [_contentPlayView removeFromSuperview];
    }];
}

- (AVplayerView * (^)())hindenToolBar{
    return ^(){
        isHidenAll = YES;
        return self;
    };
}

#pragma mark - 播放监听

- (void)addprogressobserver
{
    __weak AVPlayerItem* playeritem = player.currentItem;
    __weak typeof(self) weakself = self;
    //这里设置每秒执行一次
    avTimer = [player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0)
                                                   queue:dispatch_get_main_queue()
                                              usingBlock:^(CMTime time) {
                                                  CGFloat currentSecond = playeritem.currentTime.value / playeritem.currentTime.timescale; // 计算当前在第几秒
                                                  //                                                  NSLog(@"当前已经播放%.2fs.", currentSecond);
                                                  NSString* timeString = [weakself convertTime:currentSecond];
                                                  if (weakself.totalTime) {
                                                      weakself.timeLabel.text = [NSString stringWithFormat:@"%@/%@", timeString, weakself.totalTime];
                                                  }

                                                  if (currentSecond) {
                                                      if (!weakself.isSliding.length) {
                                                          [weakself updateVideoSlider:currentSecond];
                                                      }
                                                  }
                                              }];
}
#pragma mark - 监听播放状态
- (void)addobservertoplayeritem:(AVPlayerItem*)playeritem
{
    //监控状态属性，注意avplayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playeritem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playeritem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
#pragma mark - 移除观察者
- (void)removeobservertoplayeritem:(AVPlayerItem*)playeritem
{
    [playeritem removeObserver:self forKeyPath:@"status" context:nil];
    [playeritem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
}

/**
 *  通过kvo监控播放器状态
 *
 *  @param keypath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    AVPlayerItem* playeritem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];

        if (status == AVPlayerStatusReadyToPlay) {
            CGFloat duration = CMTimeGetSeconds(playeritem.duration);
            [self customVideoSlider:playeritem.duration]; // 自定义UISlider外观
            self.playSlider.maximumValue = duration; // 设置总时长
            _totalTime = [self convertTime:duration]; // 转换成播放时间
            self.timeLabel.text = [NSString stringWithFormat:@"00:00/%@", _totalTime];
            //            NSLog(@"正在播放...，视频总长度:%.2f", duration);
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //        NSArray *array=playeritem.loadedTimeRanges;
        //        CMTimeRange timerange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        //        float startseconds = CMTimeGetSeconds(timerange.start);
        //        float durationseconds = CMTimeGetSeconds(timerange.duration);
        //        NSTimeInterval totalbuffer = startseconds + durationseconds;//缓冲总长度
        //        [self.playProgress setProgress:CMTimeGetSeconds(playerItem.currentTime) / totalbuffer animated:YES]; //设置缓冲长度
        ////        NSLog(@"共缓冲：%.2f",totalbuffer);
        //        NSLog(@"已缓存了%f ",CMTimeGetSeconds(playerItem.currentTime));
        //        [player play];

        NSTimeInterval timeInterval = [self availableDuration]; // 计算缓冲进度
        //        NSLog(@"已缓存:------%.1f-秒----", timeInterval);
        CMTime duration = playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.playProgress setProgress:timeInterval / totalDuration animated:YES];

        //缓存好自动播放
        //        [player play];
    }
}

- (NSTimeInterval)availableDuration
{
    NSArray* loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算缓冲总进度
    return result;
}

- (void)hidenToolBar
{
    if (isToolBar) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _playToolBar.alpha = 0;
                         }];
        isToolBar = !isToolBar;
    }
    else {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _playToolBar.alpha = 1;
                         }];
        isToolBar = !isToolBar;
    }
}

- (void)customVideoSlider:(CMTime)duration
{
    //    self.playSlider.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage* transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self.playSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.playSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

- (void)updateVideoSlider:(CGFloat)currentSecond
{
    [self.playSlider setValue:currentSecond animated:YES];
}

- (void)tapDidClick:(UITapGestureRecognizer*)tap
{
    [self hidenToolBar];
}

- (void)pinchDidChange:(UIPinchGestureRecognizer*)pinch
{
    __weak typeof(self) weakself = self;
    static CGFloat scaleStatic = 1.0;
    static CGFloat scaleStaticIdentifiter = 1.0;
    CGFloat changeValue = pinch.scale - scaleStatic;
    scaleStatic = pinch.scale;
    if (pinch.state == UIGestureRecognizerStateChanged) {
        if (changeValue < 0 && scaleStaticIdentifiter > 0.6) {

            [UIView animateKeyframesWithDuration:0.3
                delay:0
                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                animations:^{
                    _contentPlayView.transform = CGAffineTransformMakeScale(scaleStaticIdentifiter + changeValue, scaleStaticIdentifiter + changeValue);
                }
                completion:^(BOOL finished){

                }];

            scaleStaticIdentifiter += changeValue;
            //            NSLog(@"scaleStaticIdentifiter %f", scaleStaticIdentifiter);
        }
    }
    else if (pinch.state == UIGestureRecognizerStateEnded && scaleStaticIdentifiter < 1) {
        [UIView animateKeyframesWithDuration:0.3
            delay:0
            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
            animations:^{
                _contentPlayView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                _contentPlayView.center = _point;
            }
            completion:^(BOOL finished) {

                [UIView animateWithDuration:0.25
                    animations:^{
                        _contentPlayView.alpha = 0;
                    }
                    completion:^(BOOL finished) {
                        [_contentPlayView removeFromSuperview];
                    }];
                player = nil;
                playerItem = nil;
                playerLayer = nil;
                scaleStaticIdentifiter = 1;
            }];
        [player removeTimeObserver:avTimer];
        [weakself removeobservertoplayeritem:playerItem];
        avTimer = nil;
    }
}

- (void)videoPlayDidClick:(UIButton*)sender
{

    if (!isToolTimer) {
        isToolTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeWithToolBar:) userInfo:nil repeats:YES];
    }

    if (!isplaying) {
        [player play];
        [sender setImage:[UIImage imageNamed:@"pause-button"] forState:(UIControlStateNormal)];
    }
    else {
        [player pause];
        [sender setImage:[UIImage imageNamed:@"play-button"] forState:(UIControlStateNormal)];
    }
    isplaying = !isplaying;
}
#pragma mark - 计时器
- (void)timeWithToolBar:(id)sender
{
    static NSInteger times = 0;
    if (isToolBar) {
        times++;
    }
    if (times > 4) {
        // 隐藏
        if (isToolBar) {
            [self hidenToolBar];
            times = 0;
        }
       
    }
}

#pragma mark - 滑动触发
- (void)videoSlierChangeValue:(id)sender
{
    UISlider* slider = (UISlider*)sender;
    NSLog(@"value end:%f", slider.value);
    isToolBar = NO;
    _isSliding = @"Yes";
}
- (void)videoSlierChangeValued:(id)sender
{
    _isSliding = nil;
        isToolBar = YES;
    UISlider* slider = (UISlider*)sender;
    NSLog(@" cuowu-----:%f", slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    __weak typeof(self) weakself = self;
    if (slider.value == 0.000000) {
        [player seekToTime:kCMTimeZero
            completionHandler:^(BOOL finished) {
                [player play];
            }];
        return;
    }

    [player seekToTime:changedTime
        completionHandler:^(BOOL finished) {
            [player play];
            [weakself.videoPlay setImage:[UIImage imageNamed:@"pause-button"] forState:(UIControlStateNormal)];
        }];
}
#pragma mark - 播放完成
- (void)playDidFinished:(NSNotification*)notification
{
    NSLog(@"播放完成");
    //    AVPlayerItem * p = [notification object];
    //关键代码
    //    [p seekToTime:kCMTimeZero];

    __weak typeof(self) weakSelf = self;
    [player seekToTime:kCMTimeZero
        completionHandler:^(BOOL finished) {
            [weakSelf.playSlider setValue:0.0 animated:YES];
            [weakSelf hidenToolBar];
            [player play];
        }];
}

#pragma mark -
- (void)playDidPause:(NSNotification*)notification
{
    NSLog(@"AVPlayerItemPlaybackStalledNotification");
    isplaying = NO;
    [self.videoPlay setImage:[UIImage imageNamed:@"play-button"] forState:(UIControlStateNormal)];
}

- (NSString*)convertTime:(CGFloat)second
{
    NSDate* d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second / 3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    }
    else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    NSString* showtimeNew = [[self dateFormatter] stringFromDate:d];
    return showtimeNew;
}

#pragma mark - lazy loading
- (UIProgressView*)playProgress
{
    if (!_playProgress) {
        _playProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(50 / WIDTH * _contentPlayView.frame.size.width, 46 / 2, (WIDTH - 150 )/ WIDTH * _contentPlayView.frame.size.width, 2)];
        _playProgress.backgroundColor = [UIColor whiteColor];
    }
    return _playProgress;
}

- (UISlider*)playSlider
{
    if (!_playSlider) {
        _playSlider = [[UISlider alloc] initWithFrame:CGRectMake(50/ WIDTH * _contentPlayView.frame.size.width, 2, (WIDTH - 150) / WIDTH * _contentPlayView.frame.size.width, 40)];
        _playSlider.backgroundColor = [UIColor clearColor];
        //        _playSlider.minimumTrackTintColor = [UIColor clearColor];
        //        _playSlider.maximumTrackTintColor = [UIColor clearColor];
        // 在滑动结束后触发 changed 方法
        //        _playSlider.continuous = NO;
        //        _playSlider.userInteractionEnabled = YES;
        [_playSlider addTarget:self action:@selector(videoSlierChangeValued:) forControlEvents:UIControlEventTouchUpInside];
        [_playSlider addTarget:self action:@selector(videoSlierChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _playSlider;
}

- (UIView*)playToolBar
{
    if (!_playToolBar) {
        _playToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, _contentPlayView.frame.size.height - 44, _contentPlayView.frame.size.width, 44)];
        [_playToolBar setBackgroundColor:[UIColor orangeColor]];
    }
    return _playToolBar;
}

- (UIButton*)videoPlay
{
    if (!_videoPlay) {
        _videoPlay = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _videoPlay.frame = CGRectMake(0, 0, 44, 44);
        [_videoPlay setImage:[UIImage imageNamed:@"play-button"] forState:(UIControlStateNormal)];
        [_videoPlay addTarget:self action:@selector(videoPlayDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _videoPlay;
}

- (UILabel*)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.playProgress.frame.size.width + 10, 12, 80, 20)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}
- (NSDateFormatter*)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (AVplayerView* (^)(CGPoint))returnPoint
{
    return ^AVplayerView*(CGPoint point)
    {
        _point = point;
        return self;
    };
}

- (AVplayerView* (^)(NSURL*))playWithUrl
{
    return ^AVplayerView*(NSURL* url)
    {

        _url = url;
        return self;
    };
}

- (NSUInteger)supportedInterfaceOrientations
{

    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{

    return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
}
@end

@implementation PlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

@end