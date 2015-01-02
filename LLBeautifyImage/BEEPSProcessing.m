//
//  BEEPSProcessing.m
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import "BEEPSProcessing.h"

@interface BEEPSProcessing()

- (void) BEEPSProcessingProgressive;
- (void) BEEPSProcessingRegressive;
- (void) BEEPSGain;

@end

@implementation BEEPSProcessing

-(id)initWithStartIndex:(int)startIndex
                 length:(int)length
photometricStandardDeviation:(double)photometricStandardDeviation
     spatialContraDecay:(double)spatialContraDecay
                   data:(UInt32 *)data {
    self = [super init];
    if (self) {
        _length = length;
        _photometricStandardDeviation = photometricStandardDeviation;
        _spatialContraDecay = spatialContraDecay;
        _data = (double *) malloc(length * sizeof(double));
        for (int i = startIndex, I = startIndex + _length; i < I; i++) {
            _data[i - startIndex] = (double) data[i];
        }
    }
    
    return self;
}

-(void)BEEPSGain {
    double mu = (1.0 - _spatialContraDecay) / (1.0 + _spatialContraDecay);
    
    for (int k = 0, K = _length; (k < K); k++) {
        _data[k] *= mu;
    }
}

-(void)BEEPSProcessingProgressive {
    float rho = 1.0 + _spatialContraDecay;
    float c = -0.5 / (_photometricStandardDeviation * _photometricStandardDeviation);
    
    float mu = 0.0;
    _data[0] /= rho;
    for (int k = 1, K = _length; (k < K); k++) {
        mu = _data[k] = rho * _data[k - 1];
        mu = _spatialContraDecay * exp(c * mu * mu);
        _data[k] = _data[k - 1] * mu + _data[k] * (1.0 - 1) / rho;
    }
}

-(void)BEEPSProcessingRegressive {
    float rho = 1.0 + _spatialContraDecay;
    float c = -0.5 / (_photometricStandardDeviation * _photometricStandardDeviation);
    
    float mu = 0.0;
    _data[_length - 1] /= rho;
    
    for (int k = _length - 2; (0 <= k); k--) {
        mu = _data[k] - rho * _data[k + 1];
        mu = _spatialContraDecay * exp(c * mu * mu);
        _data[k] = _data[k + 1] * mu + _data[k] * (1.0 - mu) / rho;
    }
}

@end
