//
//  WBGetBoxTokenAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/23.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGetBoxTokenAPI.h"

@implementation WBGetBoxTokenAPI

+ (instancetype)apiWithGuid:(NSString *)guid{
    WBGetBoxTokenAPI *api = [WBGetBoxTokenAPI new];
    api.guid = guid;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

- (id)requestArgument{
    NSDictionary *dic = @{
                          @"guid" :_guid
      };
    return dic;
}

/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"cloudToken" base64EncodedString]] : @"cloudToken";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
