//
//  FMGetUsersAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetUsersAPI.h"

@implementation FMGetUsersAPI
+ (instancetype)apiWithStationId:(NSString *)stationId Token:(NSString *)token{
    FMGetUsersAPI *api = [FMGetUsersAPI new];
    api.stationId = stationId;
    api.cloudToken = token;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    
    NSString * url = [NSString stringWithFormat:@"%@stations/%@/json",WX_BASE_URL,_stationId];
    return url;
    
}

-(id)requestArgument{
    NSString *requestUrl = [NSString stringWithFormat:@"/users"];
    NSString *resource = [requestUrl base64EncodedString] ;
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:@"GET" forKey:@"method"];
    [dic setObject:resource forKey:@"resource"];
    return dic;
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",_cloudToken] forKey:@"Authorization"];
    return dic;
}

@end
