//
//  ImageProcessor.h
//  ObjectDetector
//
//  Created by Michał Szepielak on 23.05.2015.
//  Copyright (c) 2015 Michał Szepielak. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/objdetect/objdetect.hpp>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoCaptureFrame.h"


typedef std::vector<cv::Point>    PointsVector;
typedef std::vector<PointsVector> ContoursVector;

@protocol ImageProcessorDelegate <NSObject>
- (void)drawFoundMarkers:(NSArray *)markersRects;
@end;


@interface ImageProcessor : NSObject

@property (nonatomic, assign) id delegate;

- (UIImage *) imageFromVideoCaptureFrame: (VideoCaptureFrame) frame;
- (UIImage *) processImageFromFrame:(VideoCaptureFrame) frame withRotatedImage:(BOOL)isImageRotated;

@end
