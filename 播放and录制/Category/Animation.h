//
//  Animation.h
//  Wedding
//
//  Created by Lovetong on 15/3/24.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CATransitionAnimationType) {
    kCATransitionFadeType = 1,
    kCATransitionPushType,
    kCATransitionRevealType,
    kCATransitionMoveInType,
    kCATransitionCubeType,
    kCATransitionSuckEffect,
    kCATransitionOglFlip,
    kCATransitionRippleEffect,
    kCATransitionPageCurl,
    kCATransitionPageUnCurl,
    kCATransitionCameraIrisHollowOpen,
    kCATransitionCameraIrisHollowClose
};

@interface Animation : NSObject

+(CATransition *)getAnimation:(CATransitionAnimationType)mytag;

@end
