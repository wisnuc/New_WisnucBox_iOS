//
//  WBGetOneBoxAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/30.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGetOneBoxAPI.h"

@implementation WBGetOneBoxAPI

+ (instancetype)getBoxApiWithBoxuuid:(NSString *)boxuuid{
    WBGetOneBoxAPI *api = [WBGetOneBoxAPI new];
    api.boxuuid = boxuuid;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [[NSString stringWithFormat:@"boxes/%@",_boxuuid] base64EncodedString]] : [NSString stringWithFormat:@"boxes/%@",_boxuuid];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
