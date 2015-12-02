//
//  ImageProcessor.m
//  ObjectDetector
//
//  Created by Michał Szepielak on 23.05.2015.
//  Copyright (c) 2015 Michał Szepielak. All rights reserved.
//
#import "ImageProcessor.h"
#import "VideoCaptureFrame.h"
using namespace cv;

@implementation ImageProcessor  {
    ContoursVector contoursVector;
    cv::CascadeClassifier objCascade;
}

@synthesize delegate;

-(id) init {
    
    if (self = [super init]) {
        NSLog(@"Loading cascade");
        objCascade = [self loadCascadeClassifier:@"cascade-trening2"];
    }
    
    return self;
}


- (UIImage *) processImageFromFrame:(VideoCaptureFrame)frame withRotatedImage:(BOOL)isImageRotated {
    UIImage *image;
    cv::Mat imageMat;
    cv::Mat treshMat;
    
    // Create OpenCV Mat from captured frame
    imageMat = [self matFromCaptureFrame:frame];
    imageMat = [self createTresholdMat:imageMat];
    
    // Convert to UIImage
    image = [self imageFromMat:imageMat];
    
    return image;
}

- (cv::Mat)rotateFrameByRightAngle:(cv::Mat)frame {
    cv::Mat rotatedFrame;

    cv::Point center = cv::Point(320, 240);
    double angle = 180.0;
    
    /// Get the rotation matrix with the specifications above
    cv::Mat rotationMat = cv::getRotationMatrix2D(center, angle, 1.0);
    cv::warpAffine(frame, rotatedFrame, rotationMat, cv::Point(640, 480) );
    
    return rotatedFrame;
}

- (cv::Mat) cascadeClasifier:(cv::Mat)inputMat {
    NSMutableArray *objects = [[NSMutableArray alloc ] init];
    cv::Mat outputMat;
    std::vector<cv::Rect> foundObjects;
    std::vector<int> rejectLevels;
    std::vector<double> levelWeights;
    CGRect tmpRect;
    
    equalizeHist(inputMat, outputMat);
    //outputMat = inputMat;

    objCascade.detectMultiScale(outputMat, foundObjects, 1.1f, 4, 0, cv::Size(5,5), cv::Size(60,60));
    NSLog(@"Found objects: %lu", foundObjects.size());
    for( size_t i = 0; i < foundObjects.size(); i++ ) {
        tmpRect = CGRectMake(foundObjects[i].x, foundObjects[i].y, foundObjects[i].width, foundObjects[i].height);
        [objects addObject: [NSValue valueWithCGRect:tmpRect]];
    }

    // Draw markers
    [delegate drawFoundMarkers:objects];
    return outputMat;
}

- (cv::CascadeClassifier) loadCascadeClassifier:(NSString *)filename {
    NSString *filePath;
    
    
    filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
    cv::CascadeClassifier classifier([filePath UTF8String]);
    if (!classifier.empty()) {
        NSLog(@"Loaded cascade classifier: %@", filename);
    } else {
        NSLog(@"Can't load cascade classifier: %@", filename);
    }
    
    return classifier;
}

- (cv::Mat) createTresholdMat:(cv::Mat)inputMat {
    cv::Mat treshMat;
    
    cv::adaptiveThreshold(inputMat,   // Input image
                          treshMat,// Result binary image
                          255,         //
                          cv::ADAPTIVE_THRESH_GAUSSIAN_C, //
                          cv::THRESH_BINARY_INV, //
                          7, //
                          7  //
                          );

    return treshMat;
}

- (void) detectContours:(cv::Mat)imageMat {
    std::vector< std::vector<cv::Point> > allContours;
    
    cv::findContours(imageMat, allContours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);

    contoursVector.clear();
    for (size_t i=0; i<allContours.size(); i++)
    {
        int contourSize = (int)allContours[i].size();
        // 640 szerokość przez 5 punktów = 128
        if (contourSize > 128) {
            contoursVector.push_back(allContours[i]);
        }
    }

    NSLog(@"Znaleziono kontur %lu, z czego zakwalifikowano %lu", allContours.size(), contoursVector.size());
}

- (UIImage *) imageFromVideoCaptureFrame:(VideoCaptureFrame)frame {
    UIImage *image;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(frame.data, frame.width, frame.height, frame.bitsPerComponent, frame.bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    

    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    image = [UIImage imageWithCGImage:quartzImage];
    
    // Clean up
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    
    return image;
}

- (UIImage *) imageFromMat:(cv::Mat)mat {
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize()*mat.total()];
    CGColorSpaceRef colorSpace;
    
    if (mat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(mat.cols,                                 //width
                                        mat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * mat.elemSize(),                       //bits per pixel
                                        mat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
    
}

- (cv::Mat) matFromCaptureFrame:(VideoCaptureFrame)frame {
    cv::Mat bgraMat((unsigned int)frame.height, (unsigned int)frame.width, CV_8UC4, frame.data);
    return bgraMat;
}

@end
