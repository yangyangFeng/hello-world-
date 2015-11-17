//
//  NSObject+TTAnimation.m
//  CATransition
//
//  Created by 邴天宇 on 15/9/11.
//  Copyright (c) 2015年 李泽鲁. All rights reserved.
//

#import "NSObject+TTAnimation.h"

@interface NSObject ()
{
    CGFloat _duration;
}
@end

@implementation NSObject (TTAnimation)

- (void)addTTAnimationType:(TTAnimationType)type OnView:(UIView *)view
{
    _duration = DURATION;
    
    NSString *subtypeString;
    
    switch (0) {
        case 0:
            subtypeString = kCATransitionFromLeft;
            break;
        case 1:
            subtypeString = kCATransitionFromBottom;
            break;
        case 2:
            subtypeString = kCATransitionFromRight;
            break;
        case 3:
            subtypeString = kCATransitionFromTop;
            break;
        default:
            break;
    }
    
    switch (type) {
        case TTFade:
            [self transitionWithType:kCATransitionFade WithSubtype:subtypeString ForView:view];
            break;
            
        case TTPush:
            [self transitionWithType:kCATransitionPush WithSubtype:subtypeString ForView:view];
            break;
            
        case TTReveal:
            [self transitionWithType:kCATransitionReveal WithSubtype:subtypeString ForView:view];
            break;
            
        case TTMoveIn:
            [self transitionWithType:kCATransitionMoveIn WithSubtype:subtypeString ForView:view];
            break;
            
        case TTCube:
            [self transitionWithType:@"cube" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTSuckEffect:
            [self transitionWithType:@"suckEffect" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTOglFlip:
            [self transitionWithType:@"oglFlip" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTRippleEffect:
            [self transitionWithType:@"rippleEffect" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTPageCurl:
            [self transitionWithType:@"pageCurl" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTPageUnCurl:
            [self transitionWithType:@"pageUnCurl" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTCameraIrisHollowOpen:
            [self transitionWithType:@"cameraIrisHollowOpen" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTCameraIrisHollowClose:
            [self transitionWithType:@"cameraIrisHollowClose" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTCurlDown:
            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionCurlDown];
            break;
            
        case TTCurlUp:
            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionCurlUp];
            break;
            
        case TTFlipFromLeft:
            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];
            break;
            
        case TTFlipFromRight:
            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionFlipFromRight];
            break;
            
        default:
            break;
    }
}


- (void)addTTAnimationType:(TTAnimationType)type OnView:(UIView *)view duration:(CGFloat)duration direction:(TTAnimationDirection)direction
{
    _duration = duration;
    
    NSString *subtypeString;
    
    switch (direction) {
        case TTDirectionFromLeft:
            subtypeString = kCATransitionFromLeft;
            break;
        case TTDirectionFromBottom:
            subtypeString = kCATransitionFromBottom;
            break;
        case TTDirectionFromRight:
            subtypeString = kCATransitionFromRight;
            break;
        case TTDirectionFromTop:
            subtypeString = kCATransitionFromTop;
            break;
        default:
            break;
    }
    
    switch (type) {
        case TTFade:
            [self transitionWithType:kCATransitionFade WithSubtype:subtypeString ForView:view];
            break;
            
        case TTPush:
            [self transitionWithType:kCATransitionPush WithSubtype:subtypeString ForView:view];
            break;
            
        case TTReveal:
            [self transitionWithType:kCATransitionReveal WithSubtype:subtypeString ForView:view];
            break;
            
        case TTMoveIn:
            [self transitionWithType:kCATransitionMoveIn WithSubtype:subtypeString ForView:view];
            break;
            
        case TTCube:
            [self transitionWithType:@"cube" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTSuckEffect:
            [self transitionWithType:@"suckEffect" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTOglFlip:
            [self transitionWithType:@"oglFlip" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTRippleEffect:
            [self transitionWithType:@"rippleEffect" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTPageCurl:
            [self transitionWithType:@"pageCurl" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTPageUnCurl:
            [self transitionWithType:@"pageUnCurl" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTCameraIrisHollowOpen:
            [self transitionWithType:@"cameraIrisHollowOpen" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTCameraIrisHollowClose:
            [self transitionWithType:@"cameraIrisHollowClose" WithSubtype:subtypeString ForView:view];
            break;
            
        case TTCurlDown:
            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionCurlDown];
            break;
            
        case TTCurlUp:
            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionCurlUp];
            break;
            
        case TTFlipFromLeft:
            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];
            break;
            
        case TTFlipFromRight:
            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionFlipFromRight];
            break;
            
        default:
            break;
    }
}

#pragma CATransition动画实现
- (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view
{
    //创建CATransition对象
    CATransition *animation = [CATransition animation];
    
    //设置运动时间
    animation.duration = _duration;
    
    //设置运动type
    animation.type = type;
    if (subtype != nil) {
        
        //设置子类
        animation.subtype = subtype;
    }
    
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    
    [view.layer addAnimation:animation forKey:@"animation"];
}


#pragma UIView实现动画
- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition
{
    [UIView animateWithDuration:_duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}


@end
