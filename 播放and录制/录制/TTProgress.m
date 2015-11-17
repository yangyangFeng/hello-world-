//
//  TTProgress.m
//  testpregress
//
//  Created by 邴天宇 on 15/10/15.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#import "TTheader.h"

@interface TTProgress () {
    UIView* _leftProgressView;
    UIView* _leftProgressContentView;
    UIView* _rightprogressView;
    UIView* _rightProgressContentView;
    CGFloat _width; //leftView.width == rightView.width
}

@end

@implementation TTProgress
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _width = frame.size.width / 2.0;
        
        _leftProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        _leftProgressContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _width, frame.size.height)];
        _rightprogressView = [[UIView alloc] initWithFrame:CGRectMake(_width, 0, _width, frame.size.height)];
        _rightProgressContentView = [[UIView alloc] initWithFrame:CGRectMake(_width, 0, _width, frame.size.height)];
        _rightprogressView.transform = CGAffineTransformMakeRotation(M_PI);
        [self addSubview:_leftProgressContentView];
        [self addSubview:_leftProgressView];
        [self addSubview:_rightProgressContentView];
        [self addSubview:_rightprogressView];
    }
    return self;
}
#pragma mark ==============Private methods==============
- (void)setBackgroundColor:(UIColor*)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _rightProgressContentView.backgroundColor = backgroundColor;
    _leftProgressView.backgroundColor = backgroundColor;
}

#pragma mark ==============Public methods==============
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [UIView animateWithDuration:0.1 animations:^{
        _leftProgressView.frame = CGRectMake(0, 0, _width * progress, self.frame.size.height);
        _rightprogressView.frame = CGRectMake(_width, 0,_width - _width * progress, self.frame.size.height);
    }];
}

- (void)setProgressViewColor:(UIColor*)color
{
    _leftProgressContentView.backgroundColor = color;
    _rightprogressView.backgroundColor = color;
}
- (void)finished
{
    [UIView animateWithDuration:0.25 animations:^{
       
                    [self setProgress:1];
        [UIView animateWithDuration:0.1 animations:^{
            _leftProgressContentView.alpha = 0;
            _rightprogressView.alpha = 0;
        }];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            _leftProgressContentView.alpha = 1.0;
            _rightprogressView.alpha = 1.0;
                        [self setProgress:0];
        } completion:^(BOOL finished) {
            _leftProgressContentView.alpha = 0;
            _rightprogressView.alpha = 0;
        }];
    }];
}
- (void)show
{
    [self setProgress:0];
    [UIView animateWithDuration:0.25 animations:^{
    _leftProgressContentView.alpha = 1.0;
    _rightprogressView.alpha = 1.0;
    }];
}
@end
