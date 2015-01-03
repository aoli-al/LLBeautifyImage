//
//  BEEPSProcessing.m
//  LLBeautifyImage
//
//  Created by leo on 1/2/15.
//  Copyright (c) 2015 leo. All rights reserved.
//

#import "BEEPSProcessor.h"

@interface BEEPSProcessor()

- (double *) BEEPSProcessingProgressive;
- (double *) BEEPSProcessingRegressive;
- (double *) BEEPSGain;

@end

@implementation BEEPSProcessor

-(instancetype)initWithStartIndex:(int)startIndex
                            width:(int)width
                           height:(int)height
     photometricStandardDeviation:(double)photometricStandardDeviation
               spatialContraDecay:(double)spatialContraDecay
                       UInt32Data:(UInt32 *)data
                        direction:(BEEPSProcessDirection)direction{
    self = [super init];
    if (self) {
        _photometricStandardDeviation = photometricStandardDeviation;
        _spatialContraDecay = spatialContraDecay;
        switch (direction) {
            case kBEEPSProcessDirectionFromUpToDown:
                _length = height;
                _data = (double *)malloc(_length * sizeof(double));
                int count = 0;
                for (int i = startIndex, I = startIndex + _length * width; i < I; i += width) {
                    _data[count ++] = (double) data[i];
                }
                break;
            case kBEEPSProcessDirectionFromLeftToRight:
                _length = width;
                _data = (double *) malloc(_length * sizeof(double));
                for (int i = startIndex, I = startIndex + _length; i < I; i++) {
                    _data[i - startIndex] = (double) data[i];
                }
            default:
                break;
        }
    }
    
    return self;
}


- (instancetype)initWithStartIndex:(int) startIndex
                             width:(int) width
                            height:(int) height
      photometricStandardDeviation:(double) photometricStandardDeviation
                spatialContraDecay:(double) spatialContraDecay
                        doubleData:(double **) data
                         direction:(BEEPSProcessDirection) direction {
    self = [super init];
    if (self) {
        _photometricStandardDeviation = photometricStandardDeviation;
        _spatialContraDecay = spatialContraDecay;
        switch (direction) {
            case kBEEPSProcessDirectionFromUpToDown:
                _length = height;
                _data = (double *)malloc(_length * sizeof(double));
                for (int i = 0, I = _length; i < I; i ++) {
                    _data[i] = data[i][startIndex];
                }
                break;
            case kBEEPSProcessDirectionFromLeftToRight:
                _length = width;
                _data = (double *) malloc(_length * sizeof(double));
                for (int i = 0, I = _length; i < I; i ++) {
                    _data[i] = data[i][startIndex];
                }
            default:
                break;
        }
    }
    
    return self;
}

-(void)dealloc {
    free(_data);
}

-(double *)BEEPSGain {
    double mu = (1.0 - _spatialContraDecay) / (1.0 + _spatialContraDecay);
    double * data = (double *) malloc(_length * sizeof(double));
    memcpy(data, _data, _length * sizeof(double));
    
    for (int k = 0, K = _length; (k < K); k++) {
        data[k] *= mu;
    }
    return data;
}

-(double *)BEEPSProcessingProgressive {
    double rho = 1.0 + _spatialContraDecay;
    double c = -0.5 / (_photometricStandardDeviation * _photometricStandardDeviation);
//    double c = M_PI / (2.0 * _photometricStandardDeviation);
    double * data = (double *) malloc(_length * sizeof(double));
    memcpy(data, _data, _length * sizeof(double));
    
    
    double mu = 0.0;
    data[0] /= rho;
    for (int k = 1, K = _length; (k < K); k++) {
        mu = data[k] - rho * data[k - 1];
        mu = _spatialContraDecay * exp(c * mu * mu);
        data[k] = data[k - 1] * mu + data[k] * (1.0 - mu) / rho;
//        mu = _spatialContraDecay / cosh(c * (data[k] - rho * data[k-1]));
    }
    return data;
}

-(double *)BEEPSProcessingRegressive {
    double rho = 1.0 + _spatialContraDecay;
    double c = -0.5 / (_photometricStandardDeviation * _photometricStandardDeviation);
//    double c = M_PI / (2.0 * _photometricStandardDeviation);
    double * data = (double *) malloc(_length * sizeof(double));
    memcpy(data, _data, _length * sizeof(double));
    
    
    double mu = 0.0;
    data[_length - 1] /= rho;
    
    for (int k = _length - 2; (0 <= k); k--) {
        mu = data[k] - rho * data[k + 1];
        mu = _spatialContraDecay * exp(c * mu * mu);
//        mu = _spatialContraDecay / cosh(c * (data[k] - rho * data[k + 1]));
        data[k] = data[k + 1] * mu + data[k] * (1.0 - mu) / rho;
    }
    return data;
}

-(double *)calculcate {
    double * r = [self BEEPSProcessingRegressive];
    double * p = [self BEEPSProcessingProgressive];
    double * g = [self BEEPSGain];
    
    
    for (int i = 0; i < _length; i++) {
        r[i] += p[i] - g[i];
    }
    free(p);
    free(g);
    
    return r;
}

@end
