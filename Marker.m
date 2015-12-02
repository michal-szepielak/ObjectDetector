//
//  Marker.m
//  ObjectDetector
//
//  Created by Michał Szepielak on 31.05.2015.
//  Copyright (c) 2015 Michał Szepielak. All rights reserved.
//

#import "Marker.h"

@implementation Marker

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
        // Set empty marker property
        _markers = @[];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIColor *strokeColor = _color;
    CGContextRef currentContext = UIGraphicsGetCurrentContext();

    if (currentContext) {
        CGContextSetStrokeColorWithColor(currentContext, strokeColor.CGColor);
        CGContextSetLineWidth(currentContext, 1.0);
        
        // Draw markers if are found
        if ([_markers count] > 0) {
            for (NSValue *strokeRect in _markers) {
                CGContextStrokeRect(currentContext, [strokeRect CGRectValue]);
            }
        }
    } else {
        NSLog(@"Couldn't get context: %@", [NSValue valueWithCGRect:rect]);
    }
}

@end
