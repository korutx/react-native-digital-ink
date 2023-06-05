//
//  RCTDigitalInkManager.m
//  ExampleDigitalInk
//
//  Created by Michel David on 25-05-23.
//
#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>
#import "StrokeManager.h"
#import "RCTDigitalInkManager.h"
#import "DigitalInkView.h"
#import "RCTDigitalInkModule.h"


#import <GoogleMLKit/MLKit.h>

/** Constant defining how to render strokes. */
static const CGFloat kBrushWidth = 2.0;

@interface RCTDigitalInkManager ()

/** Languager selected by default based on the system locale settings. */
@property(nonatomic) NSString *defaultLanguage;

/** All possible language tags supported by the digital ink recognition API, ordered as they are
 * shown in the UI. */
@property(nonatomic) NSArray<NSString *> *allLanguageTags;

/** Mapping between the language tag and the display name of the language. */
@property(nonatomic) NSMutableDictionary<NSString *, NSString *> *languageTagDisplayNames;

/**
 * Object that takes care of the logic of saving the ink, sending ink to the recognizer after a
 * long enough pause, and storing the recognition results.
 */
//@property(nonatomic) StrokeManager *strokeManager;

/** Coordinates of the previous touch point as the user is drawing ink. */
@property(nonatomic) CGPoint lastPoint;

@property(nonatomic) DigitalInkView* view;

/** This view displays all the ink that has been sent for recognition, and recognition results. */
@property(weak, nonatomic) IBOutlet UIImageView *recognizedImage;

/** This view shows only the ink that is currently being drawn, before sending for recognition. */
@property(weak, nonatomic) IBOutlet UIImageView *drawnImage;

/**
 * Input field showing the currently selected language; when tapped brings up the `languagePicker`.
 */
@property(weak, nonatomic) IBOutlet UITextField *selectedLanguageField;

/** Text region used to display status messages to the user about the results of their actions. */
@property(weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation RCTDigitalInkManager

RCT_EXPORT_MODULE(RCTDigitalInkView)
RCT_EXPORT_VIEW_PROPERTY(onDrawStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDrawEnd, RCTDirectEventBlock)
RCT_EXPORT_METHOD(clear: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
  @try {
    RCTDigitalInkModule* module = [self.bridge moduleForClass:[RCTDigitalInkModule class]];
    
    _view.recognizedImage.image = nil;
    module.drawnImage.image = nil;
    [module.strokeManager clear];
    resolve(nil);
  } @catch(NSException *exception) {
    NSString *errorMessage = [NSString stringWithFormat:@"Something went wrong: %@", exception.reason];
    NSError *error = [NSError errorWithDomain:@"DigitalInkOS"
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    reject(@"error", @"Something went wrong", error);
  }
}


- (UIView *)view
{
  RCTDigitalInkModule* module = [self.bridge moduleForClass:[RCTDigitalInkModule class]];
    
    if(!module.strokeManager){
      module.strokeManager = [[StrokeManager alloc] initWithDelegate:self];
    }
    DigitalInkView *view = [[DigitalInkView alloc] initWithModule: module];
    _view = view;
    return view;
}

#pragma mark - UIViewController



/** Handle start of stroke: Draw the point, and pass it along to the `StrokeManager`. */
- (void)touchesBegan:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    RCTDigitalInkModule* module = [self.bridge moduleForClass:[RCTDigitalInkModule class]];
    UITouch *touch = [touches anyObject];
    // Since this is a new stroke, make last point the same as the current point.
    self.lastPoint = [touch locationInView:self.drawnImage];
    NSTimeInterval time = [touch timestamp];
    [self drawLineSegment:touch];
    [module.strokeManager startStrokeAtPoint:self.lastPoint time:time];
}

/** Handle continuing a stroke: Draw the line segment, and pass along to the `StrokeManager`. */
- (void)touchesMoved:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    RCTDigitalInkModule* module = [self.bridge moduleForClass:[RCTDigitalInkModule class]];
    UITouch *touch = [touches anyObject];
    [self drawLineSegment:touch];
    NSTimeInterval time = [touch timestamp];
    [module.strokeManager continueStrokeAtPoint:self.lastPoint time:time];
}

/** Handle end of stroke: Draw the line segment, and pass along to the `StrokeManager`. */
- (void)touchesEnded:(NSSet *)touches withEvent:(nullable UIEvent *)event {
  RCTDigitalInkModule* module = [self.bridge moduleForClass:[RCTDigitalInkModule class]];
    UITouch *touch = [touches anyObject];
    [self drawLineSegment:touch];
    NSTimeInterval time = [touch timestamp];
    [module.strokeManager endStrokeAtPoint:self.lastPoint time:time];
}

#pragma mark - StrokeManagerDelegate

/** Displays a status message from the `StrokeManager` to the user. */
- (void)displayMessage:(NSString *)message {
  self.messageLabel.text = message;
}

/**
 * Clear temporary ink in progress. This is invoked by the `StrokeManager` when the temporary ink is
 * sent to the recognizer.
 */
- (void)clearInk {
  self.drawnImage.image = nil;
}

/**
 * Iterate through all the saved ink/recognition results in the `StrokeManager` and render them.
 * This is invoked by the `StrokeManager` when an ink is sent to the recognizer, and when a
 * recognition result is returned.
 */
- (void)redraw {
//    RCTDigitalInkModule* module = [self.bridge moduleForClass:[RCTDigitalInkModule class]];
//    self.recognizedImage.image = nil;
//    NSArray<RecognizedInk *> *recognizedInks = [module.strokeManager recognizedInks];
//    for (NSUInteger i = 0; i < [recognizedInks count]; i++) {
//      [self drawInk:recognizedInks[i].ink];
//      if (recognizedInks[i].text != nil) {
//        [self drawText:recognizedInks[i]];
//      }
//    }
}

#pragma mark - UIPickerViewDelegate

/**
 * Invoked by the language picker when the user scrolls to a particular position in either
 * component. In the left component, the language subtag is selected, so the right component needs
 * to be updated with corresponding list of full language codes and the first one is selected by
 * default; also the `StrokeManager` is informed.
 */
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    RCTDigitalInkModule* module = [self.bridge moduleForClass:[RCTDigitalInkModule class]];
    if (component == 0) {
      self.selectedLanguageField.text = self.languageTagDisplayNames[self.allLanguageTags[row]];
      [module.strokeManager selectLanguage:self.allLanguageTags[row]];
    }
}

/**
 * Invoked by the language picker to get the contents of each row. If the model for the language
 * is already downloaded, prepend the title with the string "[D]".
 */
- (nullable NSString *)pickerView:(UIPickerView *)pickerView
                      titleForRow:(NSInteger)row
                     forComponent:(NSInteger)component {
  NSString *tag = self.allLanguageTags[row];
  NSString *title = self.languageTagDisplayNames[tag];
  RCTDigitalInkModule* module = [self.bridge moduleForClass:[RCTDigitalInkModule class]];
    if ([module.strokeManager isLanguageDownloaded:tag]) {
      return [@"[D] " stringByAppendingString:title];
    }
  
  return title;
}

#pragma mark - UIPickerViewDataSource

/** Invoked by the language picker to find out how many entries are in each component. */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.allLanguageTags.count;
}

/** Invoked by the language picker to get the number of components. */
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
  return 1;
}

#pragma mark - Private

/**
 * Draws a line segment from `self.lastPoint` to the current touch point given in the argument
 * to the temporary ink canvas.
 */
- (void)drawLineSegment:(UITouch *)touch {
  CGPoint currentPoint = [touch locationInView:self.drawnImage];
  
  UIGraphicsBeginImageContext(self.drawnImage.frame.size);
  [self.drawnImage.image drawInRect:CGRectMake(0, 0, self.drawnImage.frame.size.width,
                                               self.drawnImage.frame.size.height)];
  CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
  CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
  CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
  CGContextSetLineWidth(UIGraphicsGetCurrentContext(), kBrushWidth);
  // Unrecognized strokes are drawn in blue.
  CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 1, 1);
  CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
  CGContextStrokePath(UIGraphicsGetCurrentContext());
  CGContextFlush(UIGraphicsGetCurrentContext());
  self.drawnImage.image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  self.lastPoint = currentPoint;
}

/**
 * Goes through all language tags supported by the library, and attempt to create human readable
 * names for each of them (although the library supports more languages than iOS's NSLocale library
 * knows about). Ordered the languages alphabetically by their display names, but places the default
 * language and the non-text recognizers (emoji, autodraw, and shapes) at the top of the list.
 */
- (void)computeAllLanguageTags {
  NSSet<MLKDigitalInkRecognitionModelIdentifier *> *allModelIdentifiers =
  [MLKDigitalInkRecognitionModelIdentifier allModelIdentifiers];
  self.languageTagDisplayNames = [NSMutableDictionary<NSString *, NSString *> dictionary];
  NSLocale *locale = [NSLocale currentLocale];
  NSMutableArray<NSString *> *nonText = [NSMutableArray<NSString *> array];
  NSMutableArray<NSString *> *allTags = [NSMutableArray<NSString *> array];
  [allModelIdentifiers enumerateObjectsUsingBlock:^(
                                                    MLKDigitalInkRecognitionModelIdentifier *identifier, BOOL *stop) {
                                                      NSString *tag = identifier.languageTag;
                                                      NSString *displayName;
                                                      if ([tag hasPrefix:@"zxx-"]) {
                                                        [nonText addObject:tag];
                                                        displayName = [[tag componentsSeparatedByString:@"-x-"] lastObject];
                                                      } else {
                                                        displayName = [locale localizedStringForLocaleIdentifier:tag];
                                                      }
                                                      if (displayName == nil) {
                                                        displayName = identifier.languageSubtag;
                                                        if (identifier.regionSubtag != nil) {
                                                          displayName = [displayName stringByAppendingFormat:@" (%@)", identifier.regionSubtag];
                                                        }
                                                        if (identifier.scriptSubtag != nil) {
                                                          displayName = [displayName stringByAppendingFormat:@" %@ Script", identifier.scriptSubtag];
                                                        }
                                                      }
                                                      self.languageTagDisplayNames[tag] = displayName;
                                                      [allTags addObject:tag];
                                                    }];
  self.allLanguageTags = [allTags sortedArrayUsingComparator:^(NSString *a, NSString *b) {
    int priorityA = 2;
    if (a == self.defaultLanguage) {
      priorityA = 0;
    } else if ([nonText indexOfObject:a] != NSNotFound) {
      priorityA = 1;
    }
    int priorityB = 2;
    if (b == self.defaultLanguage) {
      priorityB = 0;
    } else if ([nonText indexOfObject:b] != NSNotFound) {
      priorityB = 1;
    }
    if (priorityA < priorityB) {
      return NSOrderedAscending;
    }
    if (priorityA > priorityB) {
      return NSOrderedDescending;
    }
    return [self.languageTagDisplayNames[a] caseInsensitiveCompare:self.languageTagDisplayNames[b]];
  }];
}

/** Given an `Ink`, draw it into the `recognizedImage` canvas in gray. */
- (void)drawInk:(MLKInk *)ink {
  UIGraphicsBeginImageContext(self.drawnImage.frame.size);
  [self.recognizedImage.image drawInRect:CGRectMake(0, 0, self.drawnImage.frame.size.width,
                                                    self.drawnImage.frame.size.height)];
  for (MLKStroke *stroke in ink.strokes) {
    if (stroke.points.count == 0) {
      continue;
    }
    MLKStrokePoint *point = stroke.points[0];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), point.x, point.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.x, point.y);
    for (MLKStrokePoint *point in stroke.points) {
      CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.x, point.y);
    }
  }
  CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
  CGContextSetLineWidth(UIGraphicsGetCurrentContext(), kBrushWidth);
  // Recognized strokes are drawn in gray.
  CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.7, 0.7, 0.7, 1.0);
  CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
  CGContextStrokePath(UIGraphicsGetCurrentContext());
  CGContextFlush(UIGraphicsGetCurrentContext());
  self.recognizedImage.image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
}

/** Given an `Ink`, returned the bounding box of the ink. */
- (CGRect)getInkRect:(MLKInk *)ink {
  CGRect rect = CGRectNull;
  if ([ink.strokes count] == 0) {
    return rect;
  }
  
  for (MLKStroke *stroke in ink.strokes) {
    for (MLKStrokePoint *point in stroke.points) {
      rect = CGRectUnion(rect, CGRectMake(point.x, point.y, 0, 0));
    }
  }
  // Make the minimum size 10x10 pixels.
  rect = CGRectUnion(rect, CGRectMake(rect.origin.x + rect.size.width / 2 - 5,
                                      rect.origin.y + rect.size.height / 2 - 5, 10, 10));
  return rect;
}

/**
 * Given a `recognizedInk`, compute the bounding box of the ink that it contains, and render the
 * text at roughly the same size as the bounding box.
 */
- (void)drawText:(RecognizedInk *)recognizedInk {
  CGRect rect = [self getInkRect:recognizedInk.ink];
  UIGraphicsBeginImageContext(self.drawnImage.frame.size);
  [self.recognizedImage.image drawInRect:CGRectMake(0, 0, self.drawnImage.frame.size.width,
                                                    self.drawnImage.frame.size.height)];
  CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
  
  CGFloat arbitrarySize = 20;
  UIFont *font = [UIFont systemFontOfSize:arbitrarySize];
  NSDictionary<NSAttributedStringKey, id> *attributes =
  @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor greenColor]};
  CGSize size = [recognizedInk.text sizeWithAttributes:attributes];
  if (size.width <= 0) {
    size.width = 1;
  }
  if (size.height <= 0) {
    size.height = 1;
  }
  CGContextTranslateCTM(UIGraphicsGetCurrentContext(), floor(rect.origin.x), floor(rect.origin.y));
  CGContextScaleCTM(UIGraphicsGetCurrentContext(), ceil(rect.size.width) / size.width,
                    ceil(rect.size.height) / size.height);
  [recognizedInk.text drawAtPoint:CGPointMake(0, 0) withAttributes:attributes];
  
  CGContextFlush(UIGraphicsGetCurrentContext());
  self.recognizedImage.image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
}


@end
