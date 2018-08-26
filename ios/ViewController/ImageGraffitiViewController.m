//
//  ImageGraffitiViewController.m
//  RNImageGraffiti
//
//  Created by 张国忠 on 2018/8/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "ImageGraffitiViewController.h"
#import "GraffitiView.h"
#import <Photos/Photos.h>

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

@interface ImageGraffitiViewController ()

@property (nonatomic,strong) GraffitiView *graffitiView;
@property (nonatomic,strong) UIButton *saveButton;
@property (nonatomic,strong) UIButton *cancelButton;

@end

@implementation ImageGraffitiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.graffitiView = [[GraffitiView alloc] initWithFrame:self.view.bounds];
    UIImage *surfaceImage = [UIImage imageWithData:_surfaceImageData scale:[UIScreen mainScreen].scale];
    _graffitiView.surfaceImage = surfaceImage;
    _graffitiView.image = [self transToMosaicImage:surfaceImage blockLevel:10];
    [self.view addSubview:_graffitiView];
    
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.cancelButton];
}
- (UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        _saveButton.backgroundColor = [UIColor grayColor];
        [_saveButton addTarget:self action:@selector(saveToPhoto) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setFrame:CGRectMake(self.view.bounds.size.width-100-20, self.view.bounds.size.height-64-40, 100, 40)];
    }
    return _saveButton;
}
- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor grayColor];
        [_cancelButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setFrame:CGRectMake(20, self.view.bounds.size.height-64-40, 100, 40)];
    }
    return _cancelButton;
}
- (void)clickBack
{
    [self dismissViewControllerAndCallback:nil];
}
- (void)saveToPhoto
{
    [self loadImageFinished:[self captureCurrentView:self.graffitiView]];
}

/*
 *转换成马赛克,level代表一个点转为多少level*level的正方形
 */
- (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              kCGBitmapByteOrderDefault,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    return resultImage;
}

//获取图片
- (UIImage *)captureCurrentView:(UIView *)view
{
    CGRect frame = view.frame;
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//调用系统方法保存到相册
- (void)loadImageFinished:(UIImage *)image
{
    [self checkPhotosPermissions:^(BOOL granted) {
        if (!granted) {
            [self dismissViewControllerAndCallback:nil];
            return;
        }
        
        NSMutableArray *storageIdentifier = [NSMutableArray array];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //写入相册
            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            //保存本地标识，用于保存成功后获取图片信息
            [storageIdentifier addObject:request.placeholderForCreatedAsset.localIdentifier];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                //获取成功后的图片对象
                __block PHAsset *selectedImageAsset = nil;
                PHFetchResult *fetchObjects = [PHAsset fetchAssetsWithLocalIdentifiers:storageIdentifier options:nil];
                [fetchObjects enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull objAsset, NSUInteger idx, BOOL * _Nonnull stop) {
                    selectedImageAsset = objAsset;
                    *stop = YES;
                }];
                
                if (selectedImageAsset) {
                    //加载图片数据
                    [[PHImageManager defaultManager] requestImageDataForAsset:selectedImageAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
                     {
                         [self dismissViewControllerAndCallback:imageData];
                     }];
                }else
                {
                    [self dismissViewControllerAndCallback:nil];
                }
            }else
            {
                [self dismissViewControllerAndCallback:nil];
            }
        }];
    }];
}

- (void)dismissViewControllerAndCallback:(NSData *)imageData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.dismissCompletionBlock)
            {
                self.dismissCompletionBlock(imageData?imageData:[NSNull null]);
            }
        }];
    });
}
- (void)checkPhotosPermissions:(void(^)(BOOL granted))callback
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        callback(YES);
        return;
    }else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                callback(YES);
                return;
            }else
            {
                callback(NO);
                return;
            }
        }];
    }else
    {
        callback(NO);
    }
}

@end
