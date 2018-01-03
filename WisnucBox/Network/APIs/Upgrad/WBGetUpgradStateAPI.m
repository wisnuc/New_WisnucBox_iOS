//
//  WBGetUpgradStateAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBGetUpgradStateAPI.h"

@implementation WBGetUpgradStateAPI
+ (instancetype)apiWithURLPath:(NSString *)urlPath{
    WBGetUpgradStateAPI *api = [WBGetUpgradStateAPI new];
    api.urlPath = urlPath;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}



/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"http://%@:3001/v1",_urlPath];
}

@end
