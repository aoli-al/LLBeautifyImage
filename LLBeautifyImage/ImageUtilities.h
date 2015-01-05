//
//  ImageUtilities.h
//  LLBeautifyImage
//
//  Created by leo on 1/5/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageUtilities : NSObject

+(char *)imageRefToBitmap:(CGImageRef)imageRef;
+(UIImage *)bitmapToImage:(char *) data width:(int) width height:(int) height;
+ (UIImage *)imageWithImage:(UIImage *)image scaleToSize:(CGSize) newSize;


@end
