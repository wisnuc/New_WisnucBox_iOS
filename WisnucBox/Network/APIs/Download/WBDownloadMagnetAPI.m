//
//  WBDownloadMagnetAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBDownloadMagnetAPI.h"

@implementation WBDownloadMagnetAPI

+ (instancetype)apiWithDirUUID:(NSString *)dirUUID MagnetURL:(NSString *)magnetURL{
    WBDownloadMagnetAPI *api = [WBDownloadMagnetAPI new];
    api.magnetURL = magnetURL;
    api.dirUUID = dirUUID;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}

- (id)requestArgument{
    NSDictionary * dic;
    if (WB_UserService.currentUser.isCloudLogin) {
        dic = @{
                @"dirUUID" :_dirUUID,
                @"magnetURL" :_magnetURL,
                @"resource" : [@"download/magnet" base64EncodedString],
                @"method" : @"POST"
                };
        
    }else{
    dic = @{
            @"dirUUID" :_dirUUID,
            @"magnetURL" :_magnetURL
            };
    }
    return dic;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : @"download/magnet";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
