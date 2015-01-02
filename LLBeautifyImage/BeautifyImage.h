//
//  BeautifyImage.h
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BeautifyImage : NSObject

@property (retain, nonatomic) UIImage * image;

-(instancetype)initWithImage:(UIImage *) image;
-(void)imageProcessing;
-(UInt32 *) imageBitMapRGBA8:(CGImageRef) imageRef;

@end
