//
//  ImageGraffitiViewController.h
//  RNImageGraffiti
//
//  Created by 张国忠 on 2018/8/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalDefines.h"

@interface ImageGraffitiViewController : UIViewController

@property (nonatomic,strong) NSData *surfaceImageData;
@property (nonatomic,assign) CGSize viewSize;
@property (nonatomic,copy) dismissCompletionBlock dismissCompletionBlock;

@end
