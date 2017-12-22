//
//  WBTorrentDownloadSwitchAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBTorrentDownloadSwitchAPI.h"

@implementation WBTorrentDownloadSwitchAPI

+ (instancetype)apiWithRequestMethod:(NSString *)method Option:(NSString *)option{
    WBTorrentDownloadSwitchAPI *api = [WBTorrentDownloadSwitchAPI new];
    api.method = method;
    api.option = option;
    return api;
}

- (JYRequestMethod)requestMethod{
    if ([_method isEqualToString:@"PATCH"]) {
        return JYRequestMethodPatch;
    }else{
    return JYRequestMethodGet;
    }
}

- (id)requestArgument{
    NSDictionary *dic;
    if (_option) {
        dic = @{
                @"op":_option
                };
    }
    return dic;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"download/switch" base64EncodedString]] : @"download/switch";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic;
    if (WB_UserService.currentUser.isCloudLogin) {
       dic = [NSMutableDictionary dictionaryWithObject:WB_UserService.currentUser.cloudToken forKey:@"Authorization"];
    }
    
    return dic;
}
@end
