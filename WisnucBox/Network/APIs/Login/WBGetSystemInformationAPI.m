//
//  WBGetSystemInformationAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/23.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBGetSystemInformationAPI.h"

@implementation WBGetSystemInformationAPI
+ (instancetype)apiWithServicePath:(NSString *)servicePath{
    WBGetSystemInformationAPI * api = [WBGetSystemInformationAPI new];
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
    return [NSString stringWithFormat:@"%@control/system",_servicePath];
}
@end
