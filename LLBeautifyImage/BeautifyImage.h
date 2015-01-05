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

+(void)imageProcessing:(UIImage *) image diviation:(double) diviation spatial:(double) spatial callback:(void (^)(UIImage *))callback;

@end
