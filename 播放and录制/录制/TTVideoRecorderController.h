//
//  TTVideoRecorderController.h
//  CaptureVideo
//
//  Created by 邴天宇 on 15/10/10.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTVideoRecorderControllerDelegate <NSObject>

- (void)videoAcquisitionFinished:(NSURL *)videoPath;

@end

@interface TTVideoRecorderController : UIViewController
@property (nonatomic, assign) id <TTVideoRecorderControllerDelegate> delegate;
+(id)shareRecorderController;
@end

