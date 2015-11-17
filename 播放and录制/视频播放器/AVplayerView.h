//
//  AVplayerView.h
//  播放测试
//
//  Created by 邴天宇 on 15/9/7.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayView : UIView

@property (nonatomic ,strong) AVPlayer *player;

@end

@interface AVplayerView : UIView

@property (nonatomic, strong) PlayView* contentPlayView;
/*!
 *  设置 url
 */
- (AVplayerView * (^)(NSURL *url))playWithUrl;
/*!
 *  设置消失位置
 */
- (AVplayerView * (^)(CGPoint point))returnPoint;
/*!
 *  讲画面输出在view中
 */
- (AVplayerView * (^)())showInView;
/*!
 *  隐藏所有控件
 */
- (AVplayerView * (^)())hindenToolBar;
/*!
 *  显示 in window
 */
- (void)show;
/*!
 *  隐藏
 */
- (void)hiden;
/**
 *  停止播放
 */
- (void)removePlay;
/**
 *  视图消失
 *
 *  @param block 视图消失block
 */
- (void)viewDidHidenBlock:(void(^)())block;
@end
