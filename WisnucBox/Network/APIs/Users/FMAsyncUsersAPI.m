//
//  FMAsyncUsersAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAsyncUsersAPI.h"
#import "Base64.h"

@implementation FMAsyncUsersAPI

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return  WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"users" base64EncodedString]] : @"users";
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}

@end
