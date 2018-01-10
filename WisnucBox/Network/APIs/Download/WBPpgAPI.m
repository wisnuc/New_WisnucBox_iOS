//
//  WBPpgAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBPpgAPI.h"

@implementation WBPpgAPI

+ (instancetype)apiWithDirUUID:(NSString *)dirUUID PpgURL:(NSString *)ppgURL{
    WBPpgAPI *api = [WBPpgAPI new];
    api.ppgURL = ppgURL;
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
                @"ppgURL" :_ppgURL,
                @"resource" : [@"download/ppg1" base64EncodedString],
                @"method" : @"POST"
                };
        
    }else{
    dic = @{
            @"dirUUID" :_dirUUID,
            @"ppgURL" :_ppgURL
            };
    }
    return dic;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : @"download/ppg1";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
