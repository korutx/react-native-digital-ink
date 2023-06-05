//
//  DigitalInkView.m
//  ExampleDigitalInk
//
//  Created by Michel David on 29-05-23.
//

#import <Foundation/Foundation.h>

#import <React/RCTEventDispatcher.h>
#import "DigitalInkView.h"

static const CGFloat kBrushWidth = 2.0;

@implementation DigitalInkView

- (instancetype)initWithModule:(RCTDigitalInkModule *) digitalInkModule {
  self = [super init];
  if (self) {
    self.userInteractionEnabled = YES;
    _digitalInkModule = digitalInkModule;
    [digitalInkModule allocDrawnImage];
    [self addSubview: digitalInkModule.drawnImage];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _digitalInkModule.drawnImage.frame = self.bounds;
    // Layout your subviews if needed
}

// Your touch handling methods...
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    UITouch *touch = [touches anyObject];
    // Since this is a new stroke, make last point the same as the current point.
    self.lastPoint = [touch locationInView:self.digitalInkModule.drawnImage];
    NSTimeInterval time = [touch timestamp];
    [self drawLineSegment:touch];
    [self.digitalInkModule.strokeManager startStrokeAtPoint:self.lastPoint time:time];
    
    if (!_onDrawStart) {
      return;
    }
    
    CGPoint location = [touch locationInView:self];
    _onDrawStart(@{
      @"x": @(location.x),
      @"y": @(location.y),
      @"event": @"touchBegan"
    });
  
  
//  UITouch *touch = [touches anyObject];
//  // Since this is a new stroke, make last point the same as the current point.
//  self.lastPoint = [touch locationInView:self.drawnImage];
//  NSTimeInterval time = [touch timestamp];
//  [self drawLineSegment:touch];
//  [self.strokeManager startStrokeAtPoint:self.lastPoint time:time];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  [self drawLineSegment:touch];
  NSTimeInterval time = [touch timestamp];
  [self.digitalInkModule.strokeManager continueStrokeAtPoint:self.lastPoint time:time];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  UITouch *touch = [touches anyObject];
  [self drawLineSegment:touch];
  NSTimeInterval time = [touch timestamp];
  [self.digitalInkModule.strokeManager endStrokeAtPoint:self.lastPoint time:time];
  
  if (!_onDrawEnd) {
    return;
  }
  
  CGPoint location = [touch locationInView:self];
  _onDrawEnd(@{
    @"x": @(location.x),
    @"y": @(location.y),
    @"event": @"tuochEnd"
  });
}

// Additional methods for StrokeManager and drawing...
// ...

// Add your custom methods here

#pragma mark - Private

/**
 * Draws a line segment from `self.lastPoint` to the current touch point given in the argument
 * to the temporary ink canvas.
 */
- (void)drawLineSegment:(UITouch *)touch {
  CGPoint currentPoint = [touch locationInView:self.digitalInkModule.drawnImage];

  UIGraphicsBeginImageContext(self.digitalInkModule.drawnImage.frame.size);
  [self.digitalInkModule.drawnImage.image drawInRect:CGRectMake(0, 0, self.digitalInkModule.drawnImage.frame.size.width,
                                               self.digitalInkModule.drawnImage.frame.size.height)];
  CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
  CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
  CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
  CGContextSetLineWidth(UIGraphicsGetCurrentContext(), kBrushWidth);
  // Unrecognized strokes are drawn in blue.
  CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 0, 1, 1);
  CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
  CGContextStrokePath(UIGraphicsGetCurrentContext());
  CGContextFlush(UIGraphicsGetCurrentContext());
  self.digitalInkModule.drawnImage.image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  self.lastPoint = currentPoint;
}

@end
