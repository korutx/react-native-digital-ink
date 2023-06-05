//
//  RecognizedInk.m
//  ExampleDigitalInk
//
//  Created by Michel David on 25-05-23.
//

#import "RecognizedInk.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleMLKit/MLKit.h>


NS_ASSUME_NONNULL_BEGIN

@implementation RecognizedInk : NSObject

- (nullable instancetype)initWithInk:(MLKInk *)ink {
  self = [super init];
  if (self != nil) {
    _ink = ink;
  }
  return self;
}

@end

NS_ASSUME_NONNULL_END
