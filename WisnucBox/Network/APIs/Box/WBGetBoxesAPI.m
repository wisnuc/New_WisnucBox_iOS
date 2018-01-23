//
//  WBGetBoxesAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/23.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGetBoxesAPI.h"

@implementation WBGetBoxesAPI

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}



/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"boxes" base64EncodedString]] : @"boxes";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
