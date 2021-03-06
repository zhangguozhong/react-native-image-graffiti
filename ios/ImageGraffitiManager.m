//
//  ImageGraffitiManager.m
//  RNImageGraffiti
//
//  Created by 张国忠 on 2018/8/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "ImageGraffitiManager.h"
#import "ImageGraffitiViewController.h"
#import <React/RCTUtils.h>

@interface ImageGraffitiManager ()

@property (nonatomic,copy) RCTResponseSenderBlock callback;

@end

@implementation ImageGraffitiManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(showGraffitiImage:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        ImageGraffitiViewController *viewController = [[ImageGraffitiViewController alloc] init];
        viewController.surfaceImageData = options[@"data"];
        viewController.viewSize = CGSizeZero;
        viewController.dismissCompletionBlock = ^(NSDictionary *imageData)
        {
            if (callback) {
                callback(@[imageData]);
            }
        };
        
        [RCTPresentedViewController() presentViewController:viewController animated:YES completion:nil];
    });
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
