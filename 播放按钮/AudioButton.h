//
//  AudioButton.h
//  音悦台1.0
//
//  Created by 邴天宇 on 15/3/27.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *playImage, *stopImage;

@interface AudioButton : UIButton {
    
    CGFloat _r;
    CGFloat _g;
    CGFloat _b;
    CGFloat _a;
    
    CGFloat _progress;
    
    CGRect _outerCircleRect;
    CGRect _innerCircleRect;
    
    UIImage *image;
    UIImageView *loadingView;
}

@property (nonatomic, retain) UIImage *image;

- (id)initWithFrame:(CGRect)frame;
- (void)startSpin;
- (void)stopSpin;
- (CGFloat)progress;
- (void)setProgress:(CGFloat)newProgress;
- (void)setColourR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a;

@end
