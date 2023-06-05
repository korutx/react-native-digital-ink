//
//  DigitalInkManager.h
//  ExampleDigitalInk
//
//  Created by Michel David on 26-05-23.
//

#ifndef RCTDigitalInkManager_h
#define RCTDigitalInkManager_h
#import "StrokeManager.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCTDigitalInkManager : RCTViewManager<StrokeManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@end
#endif /* DigitalInkManager_h */


//
