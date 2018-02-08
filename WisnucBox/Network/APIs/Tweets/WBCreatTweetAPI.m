//
//  WBCreatTweetAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/30.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBCreatTweetAPI.h"

@implementation WBCreatTweetAPI
+ (instancetype)apiWithBoxuuid:(NSString *)boxuuid{
    WBCreatTweetAPI *api = [WBCreatTweetAPI new];
    api.boxuuid = boxuuid;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}

- (id)requestArgument{
    NSDictionary *dic;
    if (WB_UserService.currentUser.isCloudLogin) {
        dic = @{
                @"metadata":@"true",
                @"resource" : [[NSString stringWithFormat:@"boxes/%@/tweets",_boxuuid] base64EncodedString],
                @"method" : @"POST"
                };
    }else{
    dic = @{
            @"metadata":@"true"
            };
    }
    return dic;
}

/// 请求的URL 
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [[NSString stringWithFormat:@"boxes/%@/tweets",_boxuuid] base64EncodedString]] : [NSString stringWithFormat:@"boxes/%@/tweets",_boxuuid];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
