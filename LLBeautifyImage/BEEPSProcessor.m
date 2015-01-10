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
                       UInt32Data:(char *)data
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
                for (int i = startIndex, I = startIndex + _length * width * 4; i < I; i += width * 4) {
                    _data[count ++] = (double) data[i];
                }
                break;
            case kBEEPSProcessDirectionFromLeftToRight:
                _length = width;
                startIndex = startIndex % 4 + (startIndex / 4) * 4 * width;
                _data = (double *) malloc(_length * sizeof(double));
                count = 0;
                for (int i = startIndex, I = startIndex + _length * 4; i < I; i += 4) {
                    _data[count ++] = (double) data[i];
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
                int count = 0;
                for (int i = 0, I = _length * 4; i < I; i += 4) {
                    _data[count ++] = data[i + startIndex % 4][startIndex / 4];
                }
                break;
            case kBEEPSProcessDirectionFromLeftToRight:
                _length = width;
                count = 0;
                _data = (double *) malloc(_length * sizeof(double));
                for (int i = 0, I = _length * 4; i < I; i += 4) {
                    _data[count ++] = data[i + startIndex % 4][startIndex / 4];
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
    double * data = (double *) malloc(_length * sizeof(double));
    memcpy(data, _data, _length * sizeof(double));
    
    
    double mu = 0.0;
    data[0] /= rho;
    for (int k = 1, K = _length; (k < K); k++) {
        mu = data[k] - rho * data[k - 1];
        mu = _spatialContraDecay * exp(c * mu * mu);
        data[k] = data[k - 1] * mu + data[k] * (1.0 - mu) / rho;
    }
    return data;
}

-(double *)BEEPSProcessingRegressive {
    double rho = 1.0 + _spatialContraDecay;
    double c = -0.5 / (_photometricStandardDeviation * _photometricStandardDeviation);
    double * data = (double *) malloc(_length * sizeof(double));
    memcpy(data, _data, _length * sizeof(double));
    
    
    double mu = 0.0;
    data[_length - 1] /= rho;
    
    for (int k = _length - 2; (0 <= k); k--) {
        mu = data[k] - rho * data[k + 1];
        mu = _spatialContraDecay * exp(c * mu * mu);
        data[k] = data[k + 1] * mu + data[k] * (1.0 - mu) / rho;
    }
    return data;
}

-(double *)calculcate {
    
    dispatch_group_t BEEPGroup = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block double * r;
    __block double * p;
    __block double * g;
    
    dispatch_group_async(BEEPGroup, queue, ^{
        dispatch_group_enter(BEEPGroup);
        r = [self BEEPSProcessingRegressive];
        dispatch_group_leave(BEEPGroup);
    });
    
    dispatch_group_async(BEEPGroup, queue, ^{
        dispatch_group_enter(BEEPGroup);
        p = [self BEEPSProcessingProgressive];
        dispatch_group_leave(BEEPGroup);
    });
    
    dispatch_group_async(BEEPGroup, queue, ^{
        dispatch_group_enter(BEEPGroup);
        g = [self BEEPSGain];
        dispatch_group_leave(BEEPGroup);
    });
    
    
    dispatch_group_wait(BEEPGroup, DISPATCH_TIME_FOREVER);
    
    dispatch_apply(_length, queue, ^(size_t i) {
        r[i] += p[i] - g[i];
    });
    free(p);
    free(g);
    
    return r;
}

@end
