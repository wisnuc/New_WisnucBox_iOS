//
//  WBTorrentDownloadActionAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBTorrentDownloadActionAPI.h"

@implementation WBTorrentDownloadActionAPI
+ (instancetype)apiWithTorrentId:(NSString *)torrentId Option:(NSString *)op{
    WBTorrentDownloadActionAPI *api = [WBTorrentDownloadActionAPI new];
    api.torrentId = torrentId;
    api.op = op;
    return api;
}

- (JYRequestMethod)requestMethod{
    if (WB_UserService.currentUser.isCloudLogin) {
       return JYRequestMethodPost;
    }else{
    return JYRequestMethodPatch;
    }
}

- (id)requestArgument{
    NSDictionary * dic;
    if (WB_UserService.currentUser.isCloudLogin) {
        dic = @{
                @"resource": [[NSString stringWithFormat:@"download/%@",_torrentId] base64EncodedString],
                @"method": @"PATCH",
                @"op" :_op,
                };
    }else{
        dic = @{
                @"op" :_op,
                };
    }
   
    return dic;
}


/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : [NSString stringWithFormat:@"download/%@",_torrentId];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
