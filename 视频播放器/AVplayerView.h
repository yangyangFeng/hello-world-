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

@interface AVplayerView : UIViewController

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
- (AVplayerView * (^)(UIView * view))showInView;
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
@end
