//
//  WBCloudLocalTokenAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBCloudLocalTokenAPI.h"

@implementation WBCloudLocalTokenAPI

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@%@?resource=%@&method=GET",kCloudAddr, kCloudCommonJsonUrl, [@"token" base64EncodedString]];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject: WB_UserService.currentUser.cloudToken forKey:@"Authorization"];
    return dic;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 20;
}

@end
