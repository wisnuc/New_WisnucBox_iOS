//
//  WBGetVersionAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/11.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGetVersionAPI.h"

@implementation WBGetVersionAPI

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}



/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"download/version" base64EncodedString]] : @"download/version";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
