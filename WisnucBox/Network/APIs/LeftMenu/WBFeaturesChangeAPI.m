//
//  WBFeaturesChangeAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBFeaturesChangeAPI.h"

@implementation WBFeaturesChangeAPI
+ (instancetype)apiWithType:(NSString *)type Action:(NSString *)action{
    WBFeaturesChangeAPI *api = [WBFeaturesChangeAPI new];
    api.action = action;
    api.type = type;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [[NSString stringWithFormat:@"features/%@/%@",_type,_action] base64EncodedString]] :[NSString stringWithFormat:@"features/%@/%@",_type,_action];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic;
    if (WB_UserService.currentUser.isCloudLogin) {
        dic = [NSMutableDictionary dictionaryWithObject:WB_UserService.currentUser.cloudToken forKey:@"Authorization"];
    }
    return dic;
}
@end
