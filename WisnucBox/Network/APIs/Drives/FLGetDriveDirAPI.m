//
//  FLGetDriveDirAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FLGetDriveDirAPI.h"
#import "Base64.h"

@implementation FLGetDriveDirAPI

+ (instancetype)apiWithDrive:(NSString *)driveUUID dir:(NSString *)dirUUID {
    FLGetDriveDirAPI * api = [FLGetDriveDirAPI new];
    api.driveUUID = driveUUID;
    api.dirUUID = dirUUID;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    NSString *resource = [NSString stringWithFormat:@"drives/%@/dirs/%@", _driveUUID, _dirUUID];
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [resource base64EncodedString]] : resource;
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 20;
}


@end
