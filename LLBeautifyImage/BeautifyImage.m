//
//  BeautifyImage.m
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import "BeautifyImage.h"
#import "BEEPSProcessor.h"

@interface BeautifyImage()

-(char *)imageRefToBitmap:(CGImageRef)imageRef;
-(UIImage *)bitmapToImage:(char *) data
                    width:(int) width
                   height:(int) height;

@end

@implementation BeautifyImage

@synthesize image = _image;

-(instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

-(UIImage *)imageProcessingWithDeviation:(double) diviation spatial:(double) spatial {
    CGImageRef imageRef = [_image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    double a = diviation;
    double b = spatial;
    
    char * data = [self imageRefToBitmap:imageRef];
    double ** horizontalResult1 = (double **) malloc(height * sizeof(double*) * 4);
    
    int count = 0;
    for (int i = 0, I = (int) (height * width * 4); i < I; i += width * 4) {
        for (int j = 0; j < 4; j++) {
            BEEPSProcessor * processor = [[BEEPSProcessor alloc] initWithStartIndex:i+j width:(int) width height:(int) height photometricStandardDeviation:a spatialContraDecay:b UInt32Data:data direction:kBEEPSProcessDirectionFromLeftToRight];
            horizontalResult1[count ++] = processor.calculcate;
        }
    }
    
    double ** verticalResult1 = (double **) malloc(width * sizeof(double *) * 4);
    
    for (int i = 0, I = (int) width * 4; i < I; i++) {
            BEEPSProcessor * processor = [[BEEPSProcessor alloc] initWithStartIndex:i width:(int) width height:(int) height photometricStandardDeviation:a spatialContraDecay:b doubleData:horizontalResult1 direction:kBEEPSProcessDirectionFromUpToDown];
            verticalResult1[i] = processor.calculcate;
    }
    
    
    double ** verticalResult2 = (double **)malloc(width * sizeof(double *) * 4);
    for (int i = 0, I = (int) width * 4; i < I; i++) {
        BEEPSProcessor * processor = [[BEEPSProcessor alloc] initWithStartIndex:i width:(int) width height:(int) height photometricStandardDeviation:a spatialContraDecay:b UInt32Data:data direction:kBEEPSProcessDirectionFromUpToDown];
        verticalResult2[i] = processor.calculcate;
    }
    
    double ** horizontalResult2 = (double **)malloc(height * sizeof(double *) * 4);
    
    count = 0;
    for (int i = 0, I = (int) (height * 4); i < I; i ++) {
            BEEPSProcessor * processor = [[BEEPSProcessor alloc] initWithStartIndex:i width:(int) width height:(int) height photometricStandardDeviation:a spatialContraDecay:b doubleData:verticalResult2 direction:kBEEPSProcessDirectionFromLeftToRight];
            horizontalResult2[i] = processor.calculcate;
    }
    
    count = 0;
    
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width * 4; j++) {
            data[count ++] = (char) ((verticalResult1[j][i]/2 + horizontalResult2[i * 4 + j % 4][j / 4]/2));
        }
    }
    
    UIImage * image = [self bitmapToImage:data width:(int) width height:(int) height];
    
    // TODO: ADD DESTRUCTOR
    free(data);
    for (int i = 0; i < height * 4; i++) {
        free(horizontalResult1[i]);
        free(horizontalResult2[i]);
    }
    for (int i = 0; i < width * 4; i++) {
        free(verticalResult1[i]);
        free(verticalResult2[i]);
    }
    free(horizontalResult1);
    free(verticalResult1);
    free(horizontalResult2);
    free(verticalResult2);
    
    return image;
}

-(char *)imageRefToBitmap:(CGImageRef)imageRef {
    
    // First get the image into your data buffer
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    char *rawData = (char *) calloc(height * width * 4, sizeof(char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    return rawData;
}

-(UIImage *)bitmapToImage:(char *) data
                    width:(int) width
                   height:(int) height {
    size_t bufferLength = width * height * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef iref = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
    UInt32 * pixels = (UInt32 *)malloc(bufferLength);
    
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpaceRef, bitmapInfo);
    
    UIImage * image = nil;
    
    if (context) {
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        image = [UIImage imageWithCGImage:imageRef];
        
    }
    
    return image;
}

- (UIImage *)imageWithImage:(UIImage *)image scaleToSize:(CGSize) newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
