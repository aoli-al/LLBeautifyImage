//
//  BeautifyImage.m
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import "BeautifyImage.h"
#import "BEEPSProcessor.h"
#import "ImageUtilities.h"


@implementation BeautifyImage

+(void)imageProcessing:(UIImage *)image diviation:(double)diviation spatial:(double)spatial callback:(void (^)(UIImage *))callback {
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    __block char * data = [ImageUtilities imageRefToBitmap:imageRef];
    __block double ** horizontalResult1 = (double **) malloc(height * sizeof(double*) * 4);
    __block double ** verticalResult1 = (double **) malloc(width * sizeof(double *) * 4);
    __block double ** verticalResult2 = (double **)malloc(width * sizeof(double *) * 4);
    __block double ** horizontalResult2 = (double **)malloc(height * sizeof(double *) * 4);
    
    __block dispatch_group_t processingGroup = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_group_async(processingGroup, queue, ^{
        dispatch_group_enter(processingGroup);
        
        NSLog(@"enter1");
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_apply(height * 4, globalQueue, ^(size_t i) {
            BEEPSProcessor * processor = [[BEEPSProcessor alloc] initWithStartIndex:(int) i width:(int) width height:(int) height photometricStandardDeviation:diviation spatialContraDecay:spatial UInt32Data:data direction:kBEEPSProcessDirectionFromLeftToRight];
            horizontalResult1[i] = processor.calculcate;
        });
        
        dispatch_apply(width * 4, globalQueue, ^(size_t i) {
            BEEPSProcessor * processor = [[BEEPSProcessor alloc] initWithStartIndex:(int) i width:(int) width height:(int) height photometricStandardDeviation:diviation spatialContraDecay:spatial doubleData:horizontalResult1 direction:kBEEPSProcessDirectionFromUpToDown];
            verticalResult1[i] = processor.calculcate;
        });
        
        NSLog(@"donw");
        dispatch_group_leave(processingGroup);
    });
    
    dispatch_group_async(processingGroup, queue, ^{
        dispatch_group_enter(processingGroup);
        
        NSLog(@"enter2");
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_apply(width * 4, globalQueue, ^(size_t i) {
            BEEPSProcessor * processor = [[BEEPSProcessor alloc] initWithStartIndex:(int) i width:(int) width height:(int) height photometricStandardDeviation:diviation spatialContraDecay:spatial UInt32Data:data direction:kBEEPSProcessDirectionFromUpToDown];
            verticalResult2[i] = processor.calculcate;
        });
        
        dispatch_apply(height * 4, globalQueue, ^(size_t i) {
            BEEPSProcessor * processor = [[BEEPSProcessor alloc] initWithStartIndex:(int) i width:(int) width height:(int) height photometricStandardDeviation:diviation spatialContraDecay:spatial doubleData:verticalResult2 direction:kBEEPSProcessDirectionFromLeftToRight];
            horizontalResult2[i] = processor.calculcate;
        });
        
        NSLog(@"done");
        dispatch_group_leave(processingGroup);
    });
    
    dispatch_group_notify(processingGroup, queue, ^{
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_apply(height * width * 4, globalQueue, ^(size_t count) {
            size_t j = count % (width * 4);
            size_t i = count / (width * 4);
            data[count] = (char) ((verticalResult1[j][i]/2 + horizontalResult2[i * 4 + j % 4][j / 4]/2));
        });
        
        UIImage * processedImage = [ImageUtilities bitmapToImage:data width:(int) width height:(int) height];
        callback(processedImage);
        
        dispatch_async(globalQueue, ^{
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
        });
        
    });
}


@end
