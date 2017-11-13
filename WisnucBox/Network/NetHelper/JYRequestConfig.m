//
//  JYRequestConfig.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYRequestConfig.h"

@implementation JYRequestConfig

+ (instancetype)sharedConfig{
    static JYRequestConfig  * config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc]init];
    });
    return config;
}

-(instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

-(void)setBaseURL:(NSString *)baseURL{
    _baseURL = baseURL;
}

@end
