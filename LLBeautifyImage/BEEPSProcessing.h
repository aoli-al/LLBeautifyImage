//
//  BEEPSProcessing.h
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BEEPSProcessing : NSObject

@property int length;
@property double photometricStandardDeviation;
@property double spatialContraDecay;
@property double * data;

- (instancetype)initWithStartIndex:(int) startIndex
              length:(int) length
photometricStandardDeviation:(double) photometricStandardDeviation
  spatialContraDecay:(double) spatialContraDecay
                data:(UInt32 *) data;

-(double *) calculcate;

@end
