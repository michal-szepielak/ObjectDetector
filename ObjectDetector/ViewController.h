//
//  ViewController.h
//  ObjectDetector
//
//  Created by Michał Szepielak on 20.05.2015.
//  Copyright (c) 2015 Michał Szepielak. All rights reserved.
//

#import "ImageProcessor.h"
#import <UIKit/UIKit.h>
#import "VideoCapturer.h"


@interface ViewController : UIViewController <VideoCapturerDelegate, ImageProcessorDelegate>

@property VideoCapturer *videoCap;
@property (strong, nonatomic) IBOutlet UIImageView *cameraPreview;
@property (strong, nonatomic) IBOutlet UIImageView *processingPreview;

- (IBAction)stopCapturing:(id)sender;
- (IBAction)startCapturing:(id)sender;
- (IBAction)changeCamera:(id)sender;

@end

