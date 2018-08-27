//
//  GlobalDefines.h
//  RNImageGraffiti
//
//  Created by 张国忠 on 2018/8/27.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^dismissCompletionBlock)(NSDictionary *imageData);

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

typedef NS_OPTIONS(NSUInteger, StorageCallback) {
    StorageCallbackSuccess = 0,
    StorageCallbackNotPermission = 1,
    StorageCallbackFailed = 2,
    StorageCallbackCanceled = 3
};

@interface GlobalDefines : NSObject

@end
