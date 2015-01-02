//
//  BeautifyImage.m
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import "BeautifyImage.h"
#import "BEEPSProcessing.h"

@implementation BeautifyImage

@synthesize image = _image;

-(instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

-(void)imageProcessing {
    CGImageRef imageRef = [_image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    UInt32 * data = [self imageBitMapRGBA8:imageRef];
    
    for (int i = 0; i < height; i++) {
        
    }
    
}

-(UInt32 *)imageBitMapRGBA8:(CGImageRef)imageRef {
    
    // First get the image into your data buffer
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    UInt32 *rawData = (UInt32*) calloc(height * width, sizeof(UInt32));
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

@end
