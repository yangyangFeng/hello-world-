//
//  UIImage+GaussianBlur.m
//  图像模糊
//
//  Created by liuchang on 15/1/4.
//  Copyright (c) 2015年 liuchang. All rights reserved.
//

#import "UIImage+GaussianBlur.h"
#import "UIImageView+WebCache.h"
@implementation UIImage (GaussianBlur)

+ (UIImage *)imageWithBlurImageNamed:(UIImage *)theImage intputRadius:(CGFloat)radius
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    CIFilter *blurFilter1 = [CIFilter filterWithName:@"CIGaussianBlur"];
    // filter是按照名字来创建的CIGaussianBlur不能更改
    [blurFilter1 setValue:inputImage forKey:kCIInputImageKey];
    [blurFilter1 setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    // 修改radius可以更改模糊程度
    CIImage *result = [blurFilter1 valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    // 即使使用ARC也要加上这个release，因为ARC不管理CGImageRef，不释放会内存泄露
    return returnImage;
}
/*-------------------------------------------------------------*/
+ (UIImage *)imageWithBlurImage:(NSURL *)url intputRadius:(CGFloat)radius
{
    UIImageView *imgView = [[UIImageView alloc] init];
//    [imgView setImageWithURL:url];
    imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:imgView.image.CGImage];
    CIFilter *blurFilter1 = [CIFilter filterWithName:@"CIGaussianBlur"];
    // filter是按照名字来创建的CIGaussianBlur不能更改
    [blurFilter1 setValue:inputImage forKey:kCIInputImageKey];
    [blurFilter1 setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    // 修改radius可以更改模糊程度
    CIImage *result = [blurFilter1 valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    // 即使使用ARC也要加上这个release，因为ARC不管理CGImageRef，不释放会内存泄露
    return returnImage;
}
/*-----------------------------------------------------------------*/

@end
