//
//  Animation.m
//  Wedding
//
//  Created by Lovetong on 15/3/24.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "Animation.h"

@implementation Animation

+(CATransition *)getAnimation:(CATransitionAnimationType)mytag
{
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.7;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    
    switch (mytag) {
        case 1:
            animation.type = kCATransitionFade;
            break;
        case 2:
            animation.type = kCATransitionPush;
            break;
        case 3:
            animation.type = kCATransitionReveal;
            break;
        case 4:
            animation.type = kCATransitionMoveIn;
            break;
        case 5:
            animation.type = @"cube";
            break;
        case 6:
            animation.type = @"suckEffect";
            break;
        case 7:
            animation.type = @"oglFlip";
            break;
        case 8:
            animation.type = @"rippleEffect";
            break;
        case 9:
            animation.type = @"pageCurl";
            break;
        case 10:
            animation.type = @"pageUnCurl";
            break;
        case 11:
            animation.type = @"cameraIrisHollowOpen";
            break;
        case 12:
            animation.type = @"cameraIrisHollowClose";
            break;
        default:
            break;
    }
    
    
    int i = (int)rand()%4;
    switch (i) {
            
        case 0:
            animation.subtype = kCATransitionFromLeft;
            break;
        case 1:
            animation.subtype = kCATransitionFromBottom;
            break;
        case 2:
            animation.subtype = kCATransitionFromRight;
            break;
        case 3:
            animation.subtype = kCATransitionFromTop;
            break;
        default:
            break;
    }
    return animation;
}

@end
