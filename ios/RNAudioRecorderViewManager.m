//
//  RNAudioRecorderViewManager.m
//  RNAudioRecorder
//
//  Created by Dev on 2019/2/1.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNAudioRecorderViewManager.h"
#import "RNAudioRecorderView.h"
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>

@implementation RNAudioRecorderViewManager


RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[RNAudioRecorderView alloc] initWithBridge:self.bridge];
}

RCT_CUSTOM_VIEW_PROPERTY(pixelsPerSecond, NSInteger, RNAudioRecorderView)
{
    NSInteger pixelsPerSecond = [RCTConvert NSInteger:json];
    [view setPixelsPerSecond:pixelsPerSecond];
}

RCT_CUSTOM_VIEW_PROPERTY(plotLineColor, UIColor, RNAudioRecorderView)
{
    UIColor *plotLineColor = [RCTConvert UIColor:json];
    [view setPlotLineColor:plotLineColor];
}

RCT_CUSTOM_VIEW_PROPERTY(timeTextColor, UIColor, RNAudioRecorderView)
{
    UIColor *timeTextColor = [RCTConvert UIColor:json];
    [view setTimeTextColor:timeTextColor];
}

RCT_CUSTOM_VIEW_PROPERTY(timeTextSize, NSInteger, RNAudioRecorderView)
{
    NSInteger timeTextSize = [RCTConvert NSInteger:json];
    [view setTimeTextSize:timeTextSize];
}

RCT_CUSTOM_VIEW_PROPERTY(onScroll, BOOL, RNAudioRecorderView)
{
    BOOL onScroll = [RCTConvert BOOL:json];
    [view setOnScroll:onScroll];
}

RCT_EXPORT_METHOD(initialize:(nonnull NSNumber *)reactTag filename:(NSString *)filename offset:(NSInteger)offset)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNAudioRecorderView *> *viewRegistry) {
        RNAudioRecorderView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNAudioRecorderView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNCamera, got: %@", view);
        } else {
            [view initialize:filename offset:offset];
        }
    }];
}

RCT_EXPORT_METHOD(renderByFile:(nonnull NSNumber *)reactTag
                  filename:(NSString *)filename
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNAudioRecorderView *> *viewRegistry) {
        RNAudioRecorderView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNAudioRecorderView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNCamera, got: %@", view);
            reject(@"ViewNotFound", @"Cannot Find View", nil);
        } else {
            NSString* retPath = [view renderByFile:filename];
            if (retPath) {
                resolve(retPath);
            } else {
                reject(@"InvalidFile", @"Invalid file path", nil);
            }
        }
    }];
}

RCT_EXPORT_METHOD(cut:(nonnull NSNumber *)reactTag
                  filename:(NSString *)filename
                  fromTime:(NSInteger)fromTime
                  toTime:(NSInteger)toTime
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNAudioRecorderView *> *viewRegistry) {
        RNAudioRecorderView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNAudioRecorderView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNCamera, got: %@", view);
            reject(@"ViewNotFound", @"Cannot Find View", nil);
        } else {
            NSString* filePath = [view cut:filename fromTimeInMs:fromTime toTimeInMs:toTime];
            if (filePath) {
                long duration = [view getDuration];
                resolve(@{
                          @"filepath": filePath,
                          @"duration": [NSNumber numberWithLong:duration]
                          }
                        );
            }else{
                reject(@"CutError", @"Invalid File Path", nil);
            }
        }
    }];
}

RCT_EXPORT_METHOD(destroy:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNAudioRecorderView *> *viewRegistry) {
        RNAudioRecorderView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNAudioRecorderView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNCamera, got: %@", view);
            reject(@"ViewNotFound", @"Cannot Find View", nil);
        } else {
            [view destroy];
            resolve(@"success");
        }
    }];
}

RCT_EXPORT_METHOD(startRecording:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNAudioRecorderView *> *viewRegistry) {
        RNAudioRecorderView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNAudioRecorderView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNCamera, got: %@", view);
        } else {
            [view startRecording];
        }
    }];
}

RCT_EXPORT_METHOD(stopRecording:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNAudioRecorderView *> *viewRegistry) {
        RNAudioRecorderView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNAudioRecorderView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNCamera, got: %@", view);
            reject(@"ViewNotFound", @"Cannot Find View", nil);
        } else {
            NSString *filePath = [view stopRecording];
            if (filePath) {
                long duration = [view getDuration];
                resolve(@{
                          @"filepath": filePath,
                          @"duration": [NSNumber numberWithLong:duration]
                          }
                        );
            }else{
                reject(@"SaveError", @"Cannot Save File to Media Library", nil);
            }
        }
    }];
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNAudioRecorderView *> *viewRegistry) {
        RNAudioRecorderView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNAudioRecorderView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNCamera, got: %@", view);
        } else {
            [view play];
        }
    }];
}

@end
