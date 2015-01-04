//
//  BEEPSProcessing.h
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BEEPSProcessDirection) {
    kBEEPSProcessDirectionFromUpToDown,
    kBEEPSProcessDirectionFromLeftToRight,
};

@interface BEEPSProcessor : NSObject

@property int length;
@property double photometricStandardDeviation;
@property double spatialContraDecay;
@property double * data;

- (instancetype)initWithStartIndex:(int) startIndex
                             width:(int) width
                            height:(int) height
      photometricStandardDeviation:(double) photometricStandardDeviation
                spatialContraDecay:(double) spatialContraDecay
                        UInt32Data:(char *) data
                         direction:(BEEPSProcessDirection) direction;

- (instancetype)initWithStartIndex:(int) startIndex
                             width:(int) width
                            height:(int) height
      photometricStandardDeviation:(double) photometricStandardDeviation
                spatialContraDecay:(double) spatialContraDecay
                        doubleData:(double **) data
                         direction:(BEEPSProcessDirection) direction;
-(double *) calculcate;

@end
