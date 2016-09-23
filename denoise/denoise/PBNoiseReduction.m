//
//  PBNoiseReduction.m
//  PBNoiseReduction
//
//  Created by duhaodong on 16/9/20.
//  Copyright © 2016年 duhaodong. All rights reserved.
//

#import "PBNoiseReduction.h"

#include "signal_processing_library.h"
#include "noise_suppression_x.h"
#include "noise_suppression.h"
#include "ns_mine/ns/ns_core.h"

#define LEAVE_SIZE 2048
@interface PBNoiseReduction()
{
    NsHandle *handle;
    char leaveData[LEAVE_SIZE];
    int  leaveLen;
    
    int frameSize;
    int NSBufSize;
    short *temp;
    float *pInData;
    float *pOutData;
}

@end


@implementation PBNoiseReduction


-(id)init
{
    self = [super init];
    if (self)
    {
        [self initWithSample:16000 Channel:2];
    }
    return self;
}

-(BOOL)initWithSample:(int)sample Channel:(int)channel
{
    int nMode = 2;
    
    _sample = sample;
    _channel = channel;
    leaveLen = 0;
    memset(leaveData, 0, LEAVE_SIZE);
    
    handle = WebRtcNs_Create();
    if (!handle)
    {
        printf("WebRtcNs_Create Error!!!\n");
        return NO;
    }
    
    if(WebRtcNs_Init(handle,sample) != 0)
    {
        printf("WebRtcNs_Init Error!!!\n");
        return NO;
    }
    
    if( WebRtcNs_set_policy(handle,nMode) != 0)
    {
        printf("WebRtcNs_set_policy Error!!!\n");
        return NO;
    }
    
    frameSize = self.sample / 100 * self.channel; //160;//10ms对应于160个short
    NSBufSize = frameSize*sizeof(short);
    
    temp = (short*)malloc(frameSize *sizeof(short));
    pInData = (float*)malloc(frameSize * sizeof(float));
    pOutData = (float*)malloc(frameSize * sizeof(float));
    return  YES;
}

-(void)setSample:(int)sample Channel:(int)channel
{
    if (_sample != sample || _channel != channel)
    {
        printf("set denoise sampel:%d\n", sample);
        [self destoryDenoise];
        [self initWithSample:sample Channel:channel];
    }
}

-(int)DenoiseData:(void *)pcmData DataLen:(int)len OutData:(void*)outData
{
    if (!handle)
    {
        [self initWithSample:16000 Channel:1];
    }
    char *pOut = outData;
    int outLen = 0;
    
    int remainDataLen = len + leaveLen;
    while (remainDataLen >= NSBufSize)
    {
        memset(temp, 0, NSBufSize);
        if (leaveLen > 0)
        {
            memcpy(temp, leaveData, leaveLen);
        }
        
        memcpy(temp+leaveLen, pcmData, (NSBufSize-leaveLen));
        leaveLen = 0;
        
        for(int i = 0; i < frameSize; i++)
        {
            pInData[i] = (float)temp[i];
        }
        
        WebRtcNs_AnalyzeCore((NoiseSuppressionC*)handle,pInData);
        
        WebRtcNs_Process(handle,&pInData,1,&pOutData);
        
        for(int i = 0; i < frameSize; i++)
        {
            temp[i] = (short)pOutData[i];
        }
        
        memcpy(pOut, temp, NSBufSize);
        pOut += NSBufSize;
        remainDataLen -= NSBufSize;
        outLen += NSBufSize;
    }
    
    leaveLen = remainDataLen;
    
    if (leaveLen > 0)
    {
        memset(leaveData, 0, LEAVE_SIZE);
        memcpy(leaveData, pcmData+(len - leaveLen), leaveLen);
    }
    
    
    return outLen;
}

-(void)destoryDenoise
{
    WebRtcNs_Free(handle);
    handle = NULL;
    if (temp)
    {
        free(temp);
        temp = NULL;
    }
    if(pInData)
    {
        free(pInData);
        pInData = NULL;
    }
    if(pOutData)
    {
        free(pOutData);
        pOutData = NULL;
    }
}

@end
