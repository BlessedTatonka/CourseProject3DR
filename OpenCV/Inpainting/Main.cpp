#include <iostream>
#include "PixMix.h"
#include <string>
#include <filesystem>
#include "FastDigitalImageInpainting.hpp"
#include "opencv2/highgui/highgui.hpp"
#import <opencv2/imgcodecs/ios.h>
#import "cmath"

float alpha = 0.2;

cv::Mat_<cv::Vec3b> foo(cv::Mat src, cv::Mat mask) {
    
    cv::Mat_<cv::Vec3b> dst(src.size());
    
    alpha = 450.0 / src.cols;
    
    cv::resize(src, src, cv::Size(src.cols * alpha, src.rows * alpha), 0, 0, CV_INTER_LINEAR);
    cv::resize(mask, mask, cv::Size(mask.cols * alpha, mask.rows * alpha), 0, 0, CV_INTER_LINEAR);
    
    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
    
    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
    mask = ~mask;
    
    cv::Mat newMask = mask.clone();
    
    float k = 10.0;
    
    for(int i=0; i < mask.rows; i++) {
        for(int j=0; j < mask.cols; j++) {
//            std::cout << int(mask.at<uchar>(i,j)) << std::endl;
            if (int(mask.at<uchar>(i,j)) != 255) {
                for (int a = -k; a < k; ++a) {
                    for (int b = - k; b <= k; ++b) {
                        if (i + a >= 0 && i + a < mask.rows
                            && j + b >= 0 && j + b < mask.cols
                            && (pow(sin(a / k), 2) + pow(cos(b / k), 2)) <= 1) {
                            newMask.at<uchar>(i + a, j + b) = 0;
                        }
                    }
                }
            }
        }
    }
    mask = newMask;
    
    std::cout << src.size() << " " << mask.size() << "\n";
    
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
    std::cout << "pixMixWhite" << "\n";
    cv::Mat_<cv::Vec3b> dst(src.size());
    
    alpha = 300.0 / src.cols;
    
    cv::resize(src, src, cv::Size(src.cols * alpha, src.rows * alpha), 0, 0, CV_INTER_LINEAR);
    
    cv::Mat mask = src.clone();
    
    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
//    mask = ~mask;
    
    cv::Mat newMask = mask.clone();

    float k = 10.0;

    for(int i=0; i < mask.rows; i++) {
        std::cout << i << "\n";
        for(int j=0; j < mask.cols; j++) {
            std::cout << int(mask.at<uchar>(i,j)) << std::endl;
            if (int(mask.at<uchar>(i,j)) == 255) {
                newMask.at<uchar>(i,j) = 0;
            } else {
                newMask.at<uchar>(i,j) = 255;
            
//                for (int a = -k; a < k; ++a) {
//                    for (int b = - k; b <= k; ++b) {
//                        if (i + a >= 0 && i + a < mask.rows
//                            && j + b >= 0 && j + b < mask.cols
//                            && (pow(sin(a / k), 2) + pow(cos(b / k), 2)) <= 1) {
//                            newMask.at<uchar>(i + a, j + b) = 0;
//                        }
//                    }
//                }
            }
        }
    }
    mask = newMask;
    
    std::cout << src.size() << " " << mask.size() << "\n";
    
    PixMix pm;
    pm.init(src, mask);
    pm.execute(dst, 0.05f);
    
    //TODO
    
//    cv::Mat mask_2 = cv::cvtColor(mask, mask, cv::COLOR_GRAY2BGR);
//    cv::Mat mask_out = cv::subtract(mask_2, dst);
//    mask_out=cv::subtract(src1_mask, mask);
//    dst = mask_out;
    
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
