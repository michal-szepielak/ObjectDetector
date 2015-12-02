//
//  VideoCapturer.h
//  ObjectDetector
//
//  Created by Michał Szepielak on 21.05.2015.
//  Copyright (c) 2015 Michał Szepielak. All rights reserved.
//

#import "VideoCaptureFrame.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>


@protocol VideoCapturerDelegate <NSObject>

-(void) captureFrameReady:(VideoCaptureFrame) frame;

@end

@interface VideoCapturer : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

@property AVCaptureSession *session;
@property AVCaptureDevice *device;
@property AVCaptureDeviceInput *videoIn;
@property AVCaptureVideoDataOutput *videoOut;
@property (nonatomic, assign) id delegate;
@property NSString *preferedDevicePosition;


-(AVCaptureSession *) createCaptureSession;
-(void) startCapturing;
-(void) stopCapturing;

@end
