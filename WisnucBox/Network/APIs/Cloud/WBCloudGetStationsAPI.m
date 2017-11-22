//
//  WBCloudGetStationsAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBCloudGetStationsAPI.h"

@implementation WBCloudGetStationsAPI

+ (instancetype)apiWithGuid:(NSString *)guid andToken:(NSString *)token {
    WBCloudGetStationsAPI *api = [WBCloudGetStationsAPI new];
    api.guid = guid;
    api.cloudToken = token;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@users/%@/stations",WX_BASE_URL,_guid];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",_cloudToken] forKey:@"Authorization"];
    return dic;
}
@end
