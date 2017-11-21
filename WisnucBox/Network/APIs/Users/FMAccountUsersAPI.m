//
//  FMAccountUsersAPI.m
//  FruitMix
//
//  Created by wisnuc on 2017/7/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMAccountUsersAPI.h"
#import "Base64.h"

@implementation FMAccountUsersAPI
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

/// 请求的URL
- (NSString *)requestUrl{
    NSString * resouce = [NSString stringWithFormat:@"users/%@", WB_UserService.currentUser.uuid];
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [resouce base64EncodedString]] : resouce;
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}

@end
