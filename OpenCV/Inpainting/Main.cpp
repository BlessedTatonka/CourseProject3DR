#include <iostream>
#include "PixMix.h"
#include <string>
#include <filesystem>
#include "FastDigitalImageInpainting.hpp"
#include "opencv2/highgui/highgui.hpp"
#import <opencv2/imgcodecs/ios.h>

const float alpha = 0.15;

cv::Mat_<cv::Vec3b> foo(cv::Mat src, cv::Mat mask) {
    cv::Mat_<cv::Vec3b> dst(src.size());
    
    cv::resize(src, src, cv::Size(src.cols * alpha, src.rows * alpha), 0, 0, CV_INTER_LINEAR);
    cv::resize(mask, mask, cv::Size(mask.cols * alpha, mask.rows * alpha), 0, 0, CV_INTER_LINEAR);
    
    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
    mask = ~mask;
    
    PixMix pm;
    pm.init(src, mask);
    pm.execute(dst, 0.05f);
    
    cv::cvtColor(dst, dst, cv::COLOR_BGR2RGB);
    
    return dst;
}

cv::Mat_<cv::Vec3b> pixMixMagenta(cv::Mat src) {
    cv::Mat_<cv::Vec3b> dst(src.size());
    cv::resize(src, src, cv::Size(src.cols * alpha, src.rows * alpha), 0, 0, CV_INTER_LINEAR);
    
    cv::Mat_<uchar> mask = src.clone();
    
    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
    PixMix pm;
    pm.init(src, mask);
    pm.execute(dst, 0.05f);
    
    cv::cvtColor(dst, dst, cv::COLOR_BGR2RGB);
    
    return dst;
}

cv::Mat_<cv::Vec3b> pixMixWhite(cv::Mat src) {
    cv::Mat_<cv::Vec3b> dst(src.size());
    cv::resize(src, src, cv::Size(src.cols * alpha, src.rows * alpha), 0, 0, CV_INTER_LINEAR);
    
//    cv::Mat_<uchar> mask(src.size());
//
////    for (int y = 0; y < mask.rows; ++y) {
////        for (int x = 0; x < mask.cols; ++x) {
////            cv::Vec4b & pixel = mask.at<cv::Vec4b>(y, x);
////            if (!(pixel[0] == 255 && pixel[1] == 255 && pixel[2] == 255)) {
////                pixel[0] = 0;
////                pixel[1] = 0;
////                pixel[2] = 0;
////            }
////        }
////    }
//
//    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
    cv::Mat_<uchar> mask;
    
    Util::createMask(src, cv::Scalar(255, 255, 255), mask);
    
    mask = ~mask;
    
    PixMix pm;
    pm.init(src, mask);
    pm.execute(dst, 0.05f);
    
    cv::cvtColor(dst, dst, cv::COLOR_BGR2RGB);
    
    return dst;
}

cv::Mat_<cv::Vec3b> fast_inpainting(cv::Mat src, cv::Mat mask) {
    cv::Mat_<cv::Vec3b> dst(src.size());
    
    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
    cv::cvtColor(mask, mask, cv::COLOR_BGR2RGB);
    //    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
    mask = ~mask;
    
    inpaint(src, mask, K, dst, 500);
    
    cv::cvtColor(dst, dst, cv::COLOR_BGR2RGB);
    
    return dst;
}
