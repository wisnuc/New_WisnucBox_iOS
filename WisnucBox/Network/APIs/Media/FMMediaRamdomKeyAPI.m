//
//  FMMediaRamdomKeyAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/23.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FMMediaRamdomKeyAPI.h"

@implementation FMMediaRamdomKeyAPI

+ (instancetype)apiWithHash:(NSString *)hash {
    FMMediaRamdomKeyAPI * api =  [FMMediaRamdomKeyAPI new];
    api.photoHash = hash;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET&alt=random", kCloudAddr, kCloudCommonJsonUrl, [[NSString stringWithFormat:@"media/%@", _photoHash] base64EncodedString]] : [NSString stringWithFormat:@"media/%@?alt=random", _photoHash];
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
-(NSTimeInterval)requestTimeoutInterval{
    return 200;
}
@end
