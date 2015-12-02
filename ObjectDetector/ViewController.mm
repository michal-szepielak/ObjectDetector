//
//  ViewController.m
//  ObjectDetector
//
//  Created by Michał Szepielak on 20.05.2015.
//  Copyright (c) 2015 Michał Szepielak. All rights reserved.
//

#import "ViewController.h"
#import "Marker.h"
#import <CoreGraphics/CoreGraphics.h>

int const frameWidth = 640;
int const frameHeight = 480;
int const markerWidth = 443;
int const markerHeight = 332;

float const scaleXFactor = markerWidth / (float)frameWidth;
float const scaleYFactor = markerHeight / (float)frameHeight;

@interface ViewController () {
    ImageProcessor *imageProcessor;
    Marker *markerView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Create marker view dimensions as processing Preview
    markerView = [[Marker alloc] initWithFrame:CGRectMake(5, 5, markerWidth, markerHeight)];
    markerView.color = [UIColor colorWithRed:0.0 green:0.8 blue:0.8 alpha:1.0];
    
    // Add subviews and reorder
    [self.view addSubview: self.cameraPreview];
    [self.view addSubview: self.processingPreview];
    [self.view addSubview:markerView];
    [self.view bringSubviewToFront:markerView];
    
    // Initialize image processor
    imageProcessor = [[ImageProcessor alloc] init];
    imageProcessor.delegate = self;

    // Initilize video capturer
    self.videoCap = [[VideoCapturer alloc] init];
    self.videoCap.delegate = self;
    [self.videoCap startCapturing]; // Autostart
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) captureFrameReady:(VideoCaptureFrame)frame {
    UIImage *cameraImage;
    UIImage *processingImage;
    cv::Mat imageMat;
    
    // Get raw camera input
    cameraImage = [imageProcessor imageFromVideoCaptureFrame:frame];

    // Start processing image
    if ([self.videoCap.preferedDevicePosition isEqualToString:@"FRONT"]) {
        processingImage = [imageProcessor processImageFromFrame:frame withRotatedImage: NO];
    } else {
        processingImage = [imageProcessor processImageFromFrame:frame withRotatedImage: YES];
        // Change orientation of image to display it on portrait
        cameraImage = [UIImage imageWithCGImage:[cameraImage CGImage] scale:1.0 orientation:UIImageOrientationDown];
    }

    // Display images
    dispatch_sync(dispatch_get_main_queue(),
                  ^{
                      [self.cameraPreview setImage: cameraImage];
                      [self.processingPreview setImage: processingImage];
                      // Draw markers
                      [markerView setNeedsDisplay];
                  });
}

- (void)drawFoundMarkers:(NSArray *)markersRects {
    NSMutableArray *resizedMarkers;
    
    resizedMarkers = [[NSMutableArray alloc] init];
    if ([markersRects count] > 0) {
        for (NSValue *valueRect in markersRects) {
            CGRect tmp = [valueRect CGRectValue];
            CGAffineTransform t = CGAffineTransformMakeScale(scaleXFactor, scaleYFactor);
            tmp = CGRectApplyAffineTransform(tmp, t);
            [resizedMarkers addObject:[NSValue valueWithCGRect:tmp]];
        }
        markerView.markers = resizedMarkers;
    } else {
        markerView.markers = @[];
    }
}

- (IBAction)stopCapturing:(id)sender {
    [self.videoCap stopCapturing];
}

- (IBAction)startCapturing:(id)sender {
    [self.videoCap startCapturing];
}

- (IBAction)changeCamera:(id)sender {
    if ([self.videoCap.preferedDevicePosition isEqualToString:@"FRONT"]) {
        self.videoCap.preferedDevicePosition = @"BACK";
    } else {
      self.videoCap.preferedDevicePosition = @"FRONT";
    }
    [self.videoCap stopCapturing];
    self.videoCap = [self.videoCap init];
    [self.videoCap startCapturing];
}

@end
