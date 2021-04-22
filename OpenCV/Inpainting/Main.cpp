#include <iostream>
#include "PixMix.h"
#include <string>
#include <filesystem>
#include "FastDigitalImageInpainting.hpp"
#include "opencv2/highgui/highgui.hpp"
#import <opencv2/imgcodecs/ios.h>
#import "cmath"
#include "inpainter.h"

void increase_mask(cv::Mat& mask, int k = 10);

float alpha = 0.2;

cv::Mat_<cv::Vec3b> foo(cv::Mat src, cv::Mat mask) {
    
    cv::Mat_<cv::Vec3b> dst(src.size());
    
    alpha = 350.0 / src.cols;
    //
    ////    alpha = 0.1;
    //
    cv::resize(src, src, cv::Size(src.cols * alpha, src.rows * alpha), 0, 0, CV_INTER_LINEAR);
    cv::resize(mask, mask, cv::Size(mask.cols * alpha, mask.rows * alpha), 0, 0, CV_INTER_LINEAR);
    
    //    cv::resize(src, src, cv::Size(100, 100), 0, 0, CV_INTER_LINEAR);
    //    cv::resize(mask, mask, cv::Size(100, 100), 0, 0, CV_INTER_LINEAR);
    
    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
    mask = ~mask;
    
    increase_mask(mask, 3);
    
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
    
    for(int i=0; i < mask.rows; i++) {
        std::cout << i << "\n";
        for(int j=0; j < mask.cols; j++) {
            std::cout << int(mask.at<uchar>(i,j)) << std::endl;
            if (int(mask.at<uchar>(i,j)) == 255) {
                newMask.at<uchar>(i,j) = 0;
            } else {
                newMask.at<uchar>(i,j) = 255;
                
                
            }
        }
    }
    mask = newMask;
    mask = ~mask;
    
    std::cout << src.size() << " " << mask.size() << "\n";
    
    PixMix pm;
    pm.init(src, mask);
    pm.execute(dst, 0.05f);
    
    //TODO
    
    int xmin = dst.rows - 1;
    int xmax = 0;
    int ymin = dst.cols - 1;
    int ymax = 0;
    
    for(int i = 0; i < dst.rows; i++) {
        for(int j = 0; j < dst.cols; j++) {
            if (int(mask.at<uchar>(i,j)) == 255) {
                if (i < xmin) {
                    xmin = i;
                }
                if (i > xmax) {
                    xmax = i;
                }
                if (j < ymin) {
                    ymin = j;
                }
                if (j > ymax) {
                    ymax = j;
                }
            }
        }
    }
    
    cv::Rect myROI(10, 10, 200, 200);
    std::cout << "A" << std::endl;
    dst = dst(myROI);
    
    cv::cvtColor(dst, dst, cv::COLOR_BGR2RGB);
    
    return dst;
}

void increase_mask(cv::Mat& mask, int k) {
    cv::Mat new_mask = mask.clone();
    
    for (int i = 0; i < mask.rows; i++) {
        for(int j = 0; j < mask.cols; j++) {
            if (int(mask.at<uchar>(i,j)) != 255) {
                for (int a = -k; a < k; ++a) {
                    for (int b = - k; b <= k; ++b) {
                        if (i + a >= 0 && i + a < mask.rows
                            && j + b >= 0 && j + b < mask.cols
                            && (pow(sin(a / k), 2) + pow(cos(b / k), 2)) <= 1) {
                            new_mask.at<uchar>(i + a, j + b) = 0;
                        }
                    }
                }
            }
        }
    }
    
    mask = new_mask;
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

cv::Mat_<cv::Vec3b> qt_inpainting(cv::Mat src, cv::Mat mask) {
    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
    mask = ~mask;
    
    int halfPatchWidth = 4;
    Inpainter i(src, mask, halfPatchWidth);
    i.inpaint();
    
    cv::Mat dst = i.result;
    cv::cvtColor(dst, dst, cv::COLOR_BGR2RGB);
    
    return dst;
}

cv::Mat_<cv::Vec3b> cv_inpainting(cv::Mat src, cv::Mat mask) {
    alpha = 300.0 / src.cols;
    //
    //    cv::resize(src, src, cv::Size(src.cols * alpha, src.rows * alpha), 0, 0, CV_INTER_LINEAR);
    //    cv::resize(mask, mask, cv::Size(mask.cols * alpha, mask.rows * alpha), 0, 0, CV_INTER_LINEAR);
    
    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
    
    mask = ~mask;
    
    increase_mask(mask, 0);
    
    mask = ~mask;
    
    cv::Mat dst;
    cv::inpaint(src, mask, dst, 3, cv::INPAINT_TELEA);
    
    cv::cvtColor(dst, dst, cv::COLOR_BGR2RGB);
    
    return dst;
}

//void test(cv::Mat src, cv::Mat mask) {
//    
//    for (i = 100; i <= 1000; i += 20) {
//        cv::resize(src, src, cv::Size(i, i), 0, 0, CV_INTER_LINEAR);
//        cv::resize(mask, mask, cv::Size(i, i), 0, 0, CV_INTER_LINEAR);
//    }
//    
//    
//    cv::cvtColor(src, src, cv::COLOR_BGR2RGB);
//    cv::cvtColor(mask, mask, cv::COLOR_BGR2GRAY);
//    
//    mask = ~mask;
//        
//    increase_mask(mask, 3);
//    
//    std::cout << src.size() << " " << mask.size() << "\n";
//    
//    PixMix pm;
//    pm.init(src, mask);
//    pm.execute(dst, 0.05f);
//    
//    cv::cvtColor(dst, dst, cv::COLOR_BGR2RGB);
//}
