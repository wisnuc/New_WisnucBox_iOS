//
//  FLDrivesAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FLDrivesAPI.h"

@implementation FLDrivesAPI

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=L2RyaXZlcw==&method=GET",kCloudAddr, kCloudCommonJsonUrl] : @"drives";
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 20;
}

@end
