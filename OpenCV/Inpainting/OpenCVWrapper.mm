//
//  OpenCVWrapper.m
//  OpenCV
//
//  Created by Борис Малашенко on 10.03.2021.
//  Copyright © 2021 Pharos Production Inc. All rights reserved.
//

#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
//#import "PixMix.h"
#import "Main.cpp"


#pragma clang pop
#endif

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@interface OpenCVWrapper ()

#ifdef __cplusplus

+ (Mat)_grayFrom:(UIImage*)source;
+ (Mat)_grayFrom:(UIImage*)source andMask:(UIImage *)imgMask;
+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;

#endif

@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public

+ (UIImage *)pixMix:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _grayFrom:source]];
}

+ (UIImage *)pixMix:(UIImage *)source andMask:(UIImage *)mask {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _grayFrom:source andMask:mask]];
}

#pragma mark Private

+ (Mat)_grayFrom:(UIImage *)source {
    cv::Mat src;
    UIImageToMat(source, src, true);
    
    cv::Mat_<cv::Vec3b> imageMat = pixMixWhite(src);
        
    return imageMat;
}

+ (Mat)_grayFrom:(UIImage *)source andMask:(UIImage *)imgMask  {
    
    source = source.fixOrientation;
    imgMask = imgMask.fixOrientation;
    
    cv::Mat src;
    UIImageToMat(source, src, true);
    cv::Mat mask;
    UIImageToMat(imgMask, mask, true);
        
    cv::Mat_<cv::Vec3b> imageMat = foo(src, mask);
        
    return imageMat;
}

+ (Mat)_matFrom:(UIImage *)source {
    cout << "matFrom ->";
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

+ (UIImage *)_imageFrom:(Mat)source {
//    cout << "-> imageFrom\n";
//
//    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
//    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
//
//    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
//    size_t bitsPerComponent = 8;
//    size_t bytesPerRow = source.step[0];
//    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
//
//    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
//    UIImage *result = [UIImage imageWithCGImage:image];
//
//    CGImageRelease(image);
//    CGDataProviderRelease(provider);
//    CGColorSpaceRelease(colorSpace);
//
//    return result;
    
    return MatToUIImage(source);
}

@end
