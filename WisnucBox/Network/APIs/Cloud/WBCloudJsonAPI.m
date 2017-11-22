//
//  WBCloudJsonAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBCloudJsonAPI.h"

@implementation WBCloudJsonAPI

+ (instancetype)apiWithBody:(id)args {
    WBCloudJsonAPI * api = [WBCloudJsonAPI new];
    api.body = args;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}

- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@%@",kCloudAddr, kCloudCommonJsonUrl];
}

- (id)requestArgument {
    return _body;
}


- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject: WB_UserService.currentUser.cloudToken forKey:@"Authorization"];
    return dic;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 20;
}

@end
