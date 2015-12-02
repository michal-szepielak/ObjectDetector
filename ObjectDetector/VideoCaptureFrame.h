//
//  VideoCaptureFrame.h
//  ObjectDetector
//
//  Created by Michał Szepielak on 23.05.2015.
//  Copyright (c) 2015 Michał Szepielak. All rights reserved.
//

#ifndef ObjectDetector_VideoCaptureFrame_h
#define ObjectDetector_VideoCaptureFrame_h

#import <Foundation/Foundation.h>

typedef struct
{
    size_t width;
    size_t height;
    size_t bitsPerComponent;
    size_t bytesPerRow;
    void *data;
    
} VideoCaptureFrame;

#endif
