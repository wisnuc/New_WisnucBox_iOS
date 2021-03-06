//
//  WBTweetAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBTweetAPI.h"

@implementation WBTweetAPI
+ (instancetype)apiWithBoxuuid:(NSString *)boxuuid{
    WBTweetAPI *api = [WBTweetAPI new];
    api.uuid = boxuuid;
    return api;
}

+ (instancetype)apiWithBoxuuid:(NSString *)boxuuid First:(NSNumber *)first Last:(NSNumber *)last Count:(NSNumber *)count{
    WBTweetAPI *api = [WBTweetAPI new];
    api.uuid = boxuuid;
    api.first = first;
    api.last = last;
    api.count = count;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

- (id)requestArgument{
    
    NSDictionary *dic;
    if (_first) {
        dic = @{
                @"first":_first,
                @"last":_last,
                @"count":_count,
                @"metadata":@"true"
                };
        return dic;
    }
    dic = @{
            @"metadata":@"true"
            };
    return dic;
}

/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [[NSString stringWithFormat:@"boxes/%@/tweets",_uuid] base64EncodedString]] : [NSString stringWithFormat:@"boxes/%@/tweets",_uuid];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
