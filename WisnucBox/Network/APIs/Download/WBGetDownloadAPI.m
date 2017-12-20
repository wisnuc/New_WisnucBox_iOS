//
//  WBGetDownloadAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBGetDownloadAPI.h"

@implementation WBGetDownloadAPI
+ (instancetype)apiWithType:(NSString *)type TorrentId:(NSString *)torrentId{
    WBGetDownloadAPI *api = [WBGetDownloadAPI new];
    api.type = type;
    api.torrentId = torrentId;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

- (id)requestArgument{
    NSDictionary * dic;
    if (_type) {
        dic = @{
                @"type" :_type,
                @"torrentId" :_torrentId
                };
    }
   
    return dic;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"download" base64EncodedString]] : @"download";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end