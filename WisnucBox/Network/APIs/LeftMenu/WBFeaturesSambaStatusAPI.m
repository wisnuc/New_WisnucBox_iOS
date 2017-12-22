//
//  WBFeaturesSambaStatusAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBFeaturesSambaStatusAPI.h"

@implementation WBFeaturesSambaStatusAPI

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"features/samba/status" base64EncodedString]] : @"features/samba/status";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic;
    if (WB_UserService.currentUser.isCloudLogin) {
        dic = [NSMutableDictionary dictionaryWithObject:WB_UserService.currentUser.cloudToken forKey:@"Authorization"];
    }
    
    return dic;
}
@end
