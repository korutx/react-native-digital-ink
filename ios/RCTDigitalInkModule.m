//
//  RTCDigitalInkModule.m
//  ExampleDigitalInk
//
//  Created by Michel David on 23-05-23.
//

#import <Foundation/Foundation.h>

// RCTDigitalInkModule.m
#import "RCTDigitalInkModule.h"
#import <GoogleMLKit/MLKit.h>

@implementation RCTDigitalInkModule


RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(downloadModel:(NSString *) languageTag resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  @try {
    [self.strokeManager selectLanguage: languageTag];
    //      [self.strokeManager selectLanguage: languageTag];
    [self.strokeManager downloadModel];
    resolve(nil);
  } @catch(NSException *exception) {
    NSString *errorMessage = [NSString stringWithFormat:@"Something went wrong: %@", exception.reason];
    NSError *error = [NSError errorWithDomain:@"DigitalInkOS"
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    reject(@"error", @"Something went wrong", error);
  }
  
}

RCT_EXPORT_METHOD(recognize:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  [self.strokeManager recognizeInk: resolve rejecter: reject];
}

RCT_EXPORT_METHOD(clear: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  @try {
    [self.strokeManager clear];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.drawnImage.image = nil;
    });
  
    resolve(nil);
  } @catch(NSException *exception) {
    NSString *errorMessage = [NSString stringWithFormat:@"Something went wrong: %@", exception.reason];
    NSError *error = [NSError errorWithDomain:@"DigitalInkOS"
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    reject(@"error", @"Something went wrong", error);
  }
}

- (UIImageView *)allocDrawnImage
{
  _drawnImage = [[UIImageView alloc] init];
  return _drawnImage;
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

@end

