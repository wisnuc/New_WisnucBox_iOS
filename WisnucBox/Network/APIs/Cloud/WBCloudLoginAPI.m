//
//  WBCloudLoginAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBCloudLoginAPI.h"

@implementation WBCloudLoginAPI
+ (instancetype)apiWithCode:(NSString *)code{
    WBCloudLoginAPI * api = [WBCloudLoginAPI new];
    api.code = code;
    //    api.basic = basic;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL

//- (NSString *)baseUrl{
//    return WX_BASE_URL;
//}

- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@token",WX_BASE_URL];
}


- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}

- (id)requestArgument{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:_code forKey:@"code"];
    [dic setObject:@"mobile" forKey:@"platform"];
    return dic;
}

-(NSTimeInterval)requestTimeoutInterval{
    return 20;
}
@end
