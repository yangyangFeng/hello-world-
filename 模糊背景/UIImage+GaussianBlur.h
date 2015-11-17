//
//  UIImage+GaussianBlur.h
//  图像模糊
//
//  Created by liuchang on 15/1/4.
//  Copyright (c) 2015年 liuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImage (GaussianBlur)
+ (UIImage *)imageWithBlurImageNamed:(UIImage *)theImage intputRadius:(CGFloat)radius;
+ (UIImage *)imageWithBlurImage:(NSURL *)url intputRadius:(CGFloat)radius;
@end
