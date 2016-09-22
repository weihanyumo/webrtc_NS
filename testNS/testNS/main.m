//
//  main.m
//  testNS
//
//  Created by duhaodong on 16/9/20.
//  Copyright © 2016年 duhaodong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PBNoiseReduction.h"

void get_audio_frame(int16_t *samples, int frame_size, int nb_channels, int sample)
{
    int j, i, v;
    int16_t *q;
    
    float t     = 0;
    float tincr = 2 * M_PI * 5.0 / sample;
    float tincr2 = 2 * M_PI * 5.0 / sample / sample;
    q = samples;
    
    for (j = 0; j < frame_size; j++)
    {
        v = (int)(sin(t) * 10000);
        for (i = 0; i < nb_channels; i++)
        {
            *q++ = v;
        }
        t     += tincr;
        tincr += tincr2;
    }
}

void testDenoise()
{
    int sample = 32000;
    int channel = 2;
    int bufLen = sample * channel * 16/2;
    int frameSize = sample;
    
    PBNoiseReduction *denoise = [[PBNoiseReduction alloc]init];
    [denoise setSample:sample Channel:channel];
    
    char *buf = (char*)malloc(bufLen);
    char *outBuf = (char*)malloc(bufLen + 1024);
    
    get_audio_frame((int16_t*)buf,frameSize , channel, sample);
    
    int outBufLen = [denoise DenoiseData:buf DataLen:bufLen OutData:outBuf];
    
    memset(buf, 0, sizeof(buf));
    
    free(buf); buf = NULL;
    free(outBuf); outBuf = NULL;

}
int main(int argc, char * argv[]) {
    @autoreleasepool {
        testDenoise();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
