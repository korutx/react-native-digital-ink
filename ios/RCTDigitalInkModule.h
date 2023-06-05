//
//  RTCDigitalInkModule.h
//  ExampleDigitalInk
//
//  Created by Michel David on 23-05-23.
//

#ifndef RCTDigitalInkModule_h
#define RCTDigitalInkModule_h

#import "StrokeManager.h"
#import <React/RCTBridgeModule.h>
#import <UIKit/UIKit.h>
@interface RCTDigitalInkModule : NSObject <RCTBridgeModule>

  @property(nonatomic) StrokeManager *strokeManager;
  @property(strong, nonatomic) IBOutlet UIImageView *drawnImage;

- (UIImageView *)allocDrawnImage;
@end

#endif /* RTCDigitalInkModule_h */
