//
//  WBFeaturesDlnaStatusAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBFeaturesDlnaStatusAPI.h"

@implementation WBFeaturesDlnaStatusAPI

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"features/dlna/status" base64EncodedString]] : @"features/dlna/status";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic;
    if (WB_UserService.currentUser.isCloudLogin) {
        dic = [NSMutableDictionary dictionaryWithObject:WB_UserService.currentUser.cloudToken forKey:@"Authorization"];
    }
    
    return dic;
}
@end
