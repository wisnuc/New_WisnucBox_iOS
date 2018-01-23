//
//  WBHttpDownloadAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/22.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBHttpDownloadAPI.h"

@implementation WBHttpDownloadAPI
+ (instancetype)apiWithDirUUID:(NSString *)dirUUID DownloadURL:(NSString *)downloadURL{
    WBHttpDownloadAPI *api = [WBHttpDownloadAPI new];
    api.downloadURL = downloadURL;
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
                @"url" :_downloadURL,
                @"resource" : [@"download/http" base64EncodedString],
                @"method" : @"POST"
                };
        
    }else{
        dic = @{
                @"dirUUID" :_dirUUID,
                @"url" :_downloadURL
                };
    }
    NSLog(@"%@",dic);
    return dic;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : @"download/http";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
