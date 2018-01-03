//
//  WBUpgradeDownloadAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBUpgradeDownloadAPI.h"

@implementation WBUpgradeDownloadAPI
+ (instancetype)apiWithURLPath:(NSString *)urlPath  State:(NSString *)state TagName:(NSString *)tagName{
    WBUpgradeDownloadAPI *api = [WBUpgradeDownloadAPI new];
    api.urlPath = urlPath;
    api.tagName = tagName;
    api.state = state;
    return api;
}


- (JYRequestMethod)requestMethod{
    return JYRequestMethodPatch;
    
}

- (id)requestArgument{
    NSDictionary *dic =@{
                         @"state":_state
                         };
    return dic;
}


/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"http://%@:3001/v1/releases/%@",_urlPath,_tagName];
}

@end
