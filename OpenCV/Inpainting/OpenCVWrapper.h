//
//  OpenCVWrapper.h
//  OpenCV
//
//  Created by Борис Малашенко on 10.03.2021.
//  Copyright © 2021 Pharos Production Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+ (UIImage *)pixMix:(UIImage *)source;
+ (UIImage *)pixMix:(UIImage *)source andMask:(UIImage *)mask;

@end
