//
//  TTProgress.h
//  testpregress
//
//  Created by 邴天宇 on 15/10/15.
//  Copyright © 2015年 邴天宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTProgress : UIView
@property (nonatomic, assign) CGFloat progress;
/**
 *  设置进度条颜色
 *
 *  @param color
 */
- (void)setProgressViewColor:(UIColor *)color;
/**
 *  完成
 */
- (void)finished;
/**
 *  显示progress
 */
- (void)show;
@end
