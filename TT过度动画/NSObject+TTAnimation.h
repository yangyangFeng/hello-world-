//
//  NSObject+TTAnimation.h
//  CATransition
//
//  Created by 邴天宇 on 15/9/11.
//  Copyright (c) 2015年 李泽鲁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    /*!
     *  淡入淡出
     */
    TTFade = 1,                   //淡入淡出
    /*!
     *  推挤
     */
    TTPush,                       //推挤
    /*!
     *  揭开
     */
    TTReveal,                     //揭开
    /*!
     *  覆盖
     */
    TTMoveIn,                     //覆盖
    /*!
     *  立方体
     */
    TTCube,                       //立方体
    /*!
     *  吮吸
     */
    TTSuckEffect,                 //吮吸
    /*!
     *  翻转
     */
    TTOglFlip,                    //翻转
    /*!
     *  波纹
     */
    TTRippleEffect,               //波纹
    /*!
     *  翻页
     */
    TTPageCurl,                   //翻页
    /*!
     *  反翻页
     */
    TTPageUnCurl,                 //反翻页
    /*!
     *  开镜头
     */
    TTCameraIrisHollowOpen,       //开镜头
    /*!
     *  关镜头
     */
    TTCameraIrisHollowClose,      //关镜头
    /*!
     *  下翻页
     */
    TTCurlDown,                   //下翻页
    /*!
     *  上翻页
     */
    TTCurlUp,                     //上翻页
    /*!
     *  左翻转
     */
    TTFlipFromLeft,               //左翻转
    /*!
     *  右翻转
     */
    TTFlipFromRight,              //右翻转
    
} TTAnimationType;


typedef enum : NSUInteger{
    TTDirectionFromLeft,
    
    TTDirectionFromBottom,

    TTDirectionFromRight,

    TTDirectionFromTop
}TTAnimationDirection;
#define DURATION 0.7f

@interface NSObject (TTAnimation)

- (void)addTTAnimationType:(TTAnimationType)type OnView:(UIView *)view;

- (void)addTTAnimationType:(TTAnimationType)type OnView:(UIView *)view duration:(CGFloat)duration direction:(TTAnimationDirection)direction;

@end
