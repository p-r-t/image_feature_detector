//
//  ImageHelper.m
//  image_feature_detector
//
//  Created by Marco Tschannett on 28.04.19.
//

#import "ImageHelper.h"
#import <opencv2/imgcodecs/ios.h>
using namespace cv;

@implementation ImageHelper
+ (cv::Mat) loadImage:(NSString *) path {
    UIImage *source = [self adjustImageOrientationWithExif:[UIImage imageWithContentsOfFile: path]];
    
    cv::Mat result;
    
    UIImageToMat(source, result);
    
    return result;
//
//    source = [ImageHelper adjustImageOrientationWithExif:source];
//
//    if (source == nil) {
//        NSException *exception = [NSException
//                                  exceptionWithName:@"File Not Found"
//                                  reason: @"Image seems to be empty or not existent"
//                                  userInfo: nil];
//
//        @throw exception;
//    }
//
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(source.CGImage);
//    CGFloat cols = source.size.width;
//    CGFloat rows = source.size.height;
//
//    cv::Mat result(rows, cols, CV_8UC4);
//
//    CGContextRef contextRef = CGBitmapContextCreate(result.data, cols, rows, 8, result.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
//
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), source.CGImage);
//    CGContextRelease(contextRef);
//
//    return result;
}

+ (UIImage *) matToImage:(cv::Mat) source {
    return MatToUIImage(source);
//    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
//    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
//
//    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
//    size_t bitsPerComponent = 8;
//    size_t bytesPerRow = source.step[0];
//    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
//
//    CGImageRef image = CGImageCreate(source.cols
//                                     , source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
//
//    UIImage *result = [UIImage imageWithCGImage:image];
//
//    CGImageRelease(image);
//    CGDataProviderRelease(provider);
//    CGColorSpaceRelease(colorSpace);
//
//    return result;
}

+ (UIImage *) adjustImageOrientationWithExif: (UIImage *) image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
