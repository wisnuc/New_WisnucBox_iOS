//
//  WBStationBootAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationBootAPI.h"

@implementation WBStationBootAPI
+ (instancetype)apiWithState:(NSString *)state Mode:(NSString *)mode{
    WBStationBootAPI * api = [WBStationBootAPI new];
    api.state = state;
    api.mode = mode;
    return api;
}

+ (instancetype)apiWithPath:(NSString *)path RequestMethod:(NSString *)mothod{
    WBStationBootAPI * api = [WBStationBootAPI new];
    api.path = path;
    api.mothod = mothod;
    return api;
}

- (JYRequestMethod)requestMethod{
    JYRequestMethod method;
    if ([_mothod isEqualToString:@"GET"]) {
        method = JYRequestMethodGet;
    }else{
        method = JYRequestMethodPatch;
    }
    return method;
}


/// 请求的URL
- (NSString *)requestUrl{
    if (_path) {
        return [NSString stringWithFormat:@"%@boot",_path];
    }else{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=PATCH", kCloudAddr, kCloudCommonJsonUrl, [@"boot" base64EncodedString]] : @"boot";
    }
}

- (id)requestArgument{
    NSDictionary *dic;
    if (_mode && _state) {
        dic = @{
                @"state" : _state,
                @"mode"  : _mode
                };
    }else if(!_mode && _state){
        dic = @{
                @"state" : _state,
                };
    }
    return dic;
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic;
    if (!_path) {
     dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    }
    return dic;
}
@end
