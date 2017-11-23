//
//  WBgetStationInfoAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/23.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBgetStationInfoAPI.h"

@implementation WBgetStationInfoAPI
+ (instancetype)apiWithServicePath:(NSString *)servicePath{
    WBgetStationInfoAPI * api = [WBgetStationInfoAPI new];
    api.servicePath = servicePath;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

- (NSString *)baseUrl{
    return _servicePath;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@station/info",_servicePath];
}

@end
