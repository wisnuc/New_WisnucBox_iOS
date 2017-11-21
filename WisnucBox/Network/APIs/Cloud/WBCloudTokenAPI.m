//
//  WBCloudTokenAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBCloudTokenAPI.h"

@implementation WBCloudTokenAPI

+ (instancetype)apiWithCode:(NSString *)code {
    WBCloudTokenAPI * api = [WBCloudTokenAPI new];
    api.code = code;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@c/v1/token?code=%@&platform=mobile",kCloudAddr, _code];
}

- (NSTimeInterval)requestTimeoutInterval {
    return 20;
}

@end
