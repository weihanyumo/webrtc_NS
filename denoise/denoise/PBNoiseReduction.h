//
//  PBNoiseReduction.h
//  PBNoiseReduction
//
//  Created by duhaodong on 16/9/20.
//  Copyright © 2016年 duhaodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBNoiseReduction : NSObject

@property(nonatomic, assign) int channel;
@property(nonatomic, assign) int sample;

-(void)setSample:(int)sample Channel:(int)channel;
-(int)DenoiseData:(void *)pcmData DataLen:(int)len OutData:(void*)outData;


@end
