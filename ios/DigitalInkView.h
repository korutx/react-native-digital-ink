//
//  DigitalInkView.h
//  ExampleDigitalInk
//
//  Created by Michel David on 29-05-23.
//

#ifndef DigitalInkView_h
#define DigitalInkView_h

#import <UIKit/UIKit.h>
#import "StrokeManager.h"
#import <React/RCTComponent.h>
#import "RCTDigitalInkModule.h"

@interface DigitalInkView : UIView

- (instancetype)initWithModule:(RCTDigitalInkModule *)digitalInkModule;

@property(nonatomic) RCTDigitalInkModule *digitalInkModule;

/** Coordinates of the previous touch point as the user is drawing ink. */
@property(nonatomic) CGPoint lastPoint;

/** This view displays all the ink that has been sent for recognition, and recognition results. */
@property(weak, nonatomic) IBOutlet UIImageView *recognizedImage;

@property (nonatomic, copy) RCTBubblingEventBlock onDrawStart;

@property (nonatomic, copy) RCTBubblingEventBlock onDrawEnd;

@end

#endif /* DigitalInkView_h */
