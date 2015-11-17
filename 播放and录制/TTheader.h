//
//  TTheader.h
//  CaptureVideo
//
//  Created by 邴天宇 on 15/10/15.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#ifndef TTheader_h
#define TTheader_h
#import "TTProgress.h"
#import "TTFileManager.h"
#import "TTVideoRecorder.h"
#import "TTVideoRecorderController.h"
#import "VideoPlayController.h"
#import "AVplayerView.h"
#import "TTVideoRecorder.h"

#import "NSString+Hash.h"
#import "UIView+Extension.h"
#import "UITextField+LimitLength.h"
#import "UIButton+Extension.h"
#import "UIImage+Extension.h"
#import "UIImage+Common.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD+MJ.h"

#import <Masonry.h>

#define   WIDTH   [[UIScreen mainScreen] bounds].size.width
#define  HEIGHT  [[UIScreen mainScreen] bounds].size.height

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define BGCOLOR RGB(25, 96, 203)
#define LABELCOLOR RGBColor(73, 73, 73)
#endif /* TTheader_h */
