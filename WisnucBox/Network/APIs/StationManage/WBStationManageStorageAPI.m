//
//  WBStationManageStorageAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageStorageAPI.h"

@implementation WBStationManageStorageAPI

+(instancetype)apiWithURLPath:(NSString *)path{
    WBStationManageStorageAPI *api = [WBStationManageStorageAPI new];
    api.path = path;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    if (!_path) {
       return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"storage" base64EncodedString]] : @"storage";
    }else{
        return [NSString stringWithFormat:@"%@storage",_path];
    }
   
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic;
    if (!_path) {
     dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    }
    return dic;
}
@end
