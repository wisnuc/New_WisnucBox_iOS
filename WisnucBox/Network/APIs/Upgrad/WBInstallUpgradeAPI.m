//
//  WBInstallUpgradeAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInstallUpgradeAPI.h"

@implementation WBInstallUpgradeAPI
+ (instancetype)apiWithURLPath:(NSString *)urlPath  RequestMethod:(NSString *)method TagName:(NSString *)tagName{
    WBInstallUpgradeAPI *api = [WBInstallUpgradeAPI new];
    api.urlPath = urlPath;
    api.tagName = tagName;
    api.method = method;
    return api;
}

+ (instancetype)apiWithURLPath:(NSString *)urlPath  RequestMethod:(NSString *)method State:(NSString *)state{
    WBInstallUpgradeAPI *api = [WBInstallUpgradeAPI new];
    api.urlPath = urlPath;
    api.state = state;
    api.method = method;
    return api;
}

- (JYRequestMethod)requestMethod{
    if ([_method isEqualToString:@"PUT"]) {
        return JYRequestMethodPut;
    }else if ([_method isEqualToString:@"PATCH"]){
        return JYRequestMethodPatch;
    }else{
          return JYRequestMethodPut;
    }
   
}

- (id)requestArgument{
    NSDictionary *dic;
    if (_tagName) {
        dic = @{
        @"tagName":_tagName
        };
    }else if (_state){
        dic = @{
                @"state":_state
                };
    }
    return dic;
}


/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"http://%@:3001/v1/app",_urlPath];
}

@end
