//
//  VideoCapturer.m
//  ObjectDetector
//
//  Created by Michał Szepielak on 21.05.2015.
//  Copyright (c) 2015 Michał Szepielak. All rights reserved.
//

#import "VideoCapturer.h"

static char * const kFrameBufferQueueName = "com.szepielak.ObjectDetector.FrameBuffer";

@implementation VideoCapturer

@synthesize delegate;

-(id) init {
    if (self = [super init]) {
        AVCaptureSession *captureSession;
        AVCaptureDevice *captureDevice;
        AVCaptureDeviceInput *deviceInput;
        AVCaptureVideoDataOutput *videoOutput;

        
        captureSession = [self createCaptureSession];
        captureDevice = [self getCaptureDevice];
        deviceInput = [self createSessionCaptureDeviceInput:captureSession withDevice:captureDevice];
        videoOutput = [self createVideoOutputForSession:captureSession];
        
        // Assign local vars to properties
        self.session = captureSession;
        self.device = captureDevice;
        self.videoIn = deviceInput;
        self.videoOut = videoOutput;
    }
    
    return self;
}

-(void) startCapturing {
    NSLog(@"Starting running capture session");
    [self.session startRunning];
}

-(void) stopCapturing {
    NSLog(@"Stopping capture session");
    [self.session stopRunning];
}

-(AVCaptureSession *) createCaptureSession {
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [captureSession setSessionPreset:AVCaptureSessionPreset640x480];
        NSLog(@"Capture Session Preset set to 640 x 480");
    } else if ([captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
        [captureSession setSessionPreset:AVCaptureSessionPresetLow];
        NSLog(@"Capture Session Preset set to LOW");
    } else {
        NSLog(@"Can't set Capture Session Preset!");
    }
    
    return captureSession;
    
}

-(AVCaptureDevice *) getCaptureDevice {
    NSArray *availableDevices = [AVCaptureDevice devices];
    AVCaptureDevice *device;
    
    // Search for device
    for (AVCaptureDevice *tmpDevice in availableDevices) {
        NSLog(@"Available device name %@", [device localizedName]);
        
        if ([tmpDevice hasMediaType:AVMediaTypeVideo]) {
            if ([_preferedDevicePosition isEqualToString:@"BACK"] && [tmpDevice position] == AVCaptureDevicePositionBack) {
                NSLog(@"Capture device set to BACK camera");
                device = tmpDevice;
            }
            
            if ([_preferedDevicePosition isEqualToString:@"FRONT"] && [tmpDevice position] == AVCaptureDevicePositionFront) {
                NSLog(@"Capture device set to FRONT camera");
                device = tmpDevice;
            }
        }
    }
    
    if (!device) {
        NSLog(@"Capture device set to Default");
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return device;
}

-(AVCaptureDeviceInput *) createSessionCaptureDeviceInput: (AVCaptureSession *)captureSession withDevice: (AVCaptureDevice *)captureDevice {
    
    NSError *error;
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (error) {
        NSLog(@"I can't create capture device input!");
    } else {
        if ([captureSession canAddInput:inputDevice]) {
            [captureSession addInput:inputDevice];
        } else {
            NSLog(@"Can't add input device to session!");
        }
    }
    
    return inputDevice;
}

-(AVCaptureVideoDataOutput *) createVideoOutputForSession: (AVCaptureSession *) captureSession {
    
    AVCaptureVideoDataOutput *videoOutput;
    dispatch_queue_t bufferQueue = dispatch_queue_create(kFrameBufferQueueName, NULL);
    NSNumber *pixelFormat = [NSNumber numberWithUnsignedInt: kCVPixelFormatType_32BGRA];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObject: pixelFormat forKey: (id)kCVPixelBufferPixelFormatTypeKey];

    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setSampleBufferDelegate: self queue: bufferQueue];
    [videoOutput setVideoSettings: videoSettings];
    // Drop late frames
    videoOutput.alwaysDiscardsLateVideoFrames = YES;
    
    if ([captureSession canAddOutput:videoOutput]) {
        [captureSession addOutput:videoOutput];
        NSLog(@"Video output created");
    } else {
        NSLog(@"Can't add and configure video output for session");
    }
    
    return videoOutput;
}

// Delegate from AVCaptureVideoOutput
-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //NSLog(@"capture output");
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    // Getting information about frame
    VideoCaptureFrame frame = {
        .width = CVPixelBufferGetWidth(imageBuffer),
        .height = CVPixelBufferGetHeight(imageBuffer),
        .bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer),
        .bitsPerComponent = 8,
        .data = CVPixelBufferGetBaseAddress(imageBuffer)
    };
    
    //NSLog(@"Calling delegate");
    [delegate captureFrameReady: frame];
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);    
}

@end
