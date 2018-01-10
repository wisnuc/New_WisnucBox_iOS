//
//  WBPpgDownloadSwitchAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBPpgDownloadSwitchAPI.h"

@implementation WBPpgDownloadSwitchAPI

+ (instancetype)apiWithRequestMethod:(NSString *)method Option:(NSString *)option{
    WBPpgDownloadSwitchAPI *api = [WBPpgDownloadSwitchAPI new];
    api.method = method;
    api.option = option;
    return api;
}

- (JYRequestMethod)requestMethod{
    if ([_method isEqualToString:@"PATCH"]) {
        if (WB_UserService.currentUser.isCloudLogin) {
          return JYRequestMethodPost;
        }else{
        return JYRequestMethodPatch;
        }
    }else{
    return JYRequestMethodGet;
    }
}

- (id)requestArgument{
    NSDictionary *dic;
    if (_option) {
        if (WB_UserService.currentUser.isCloudLogin) {
            dic = @{
                    @"op":_option,
                    @"resource" :  [@"download/switch" base64EncodedString],
                    @"method" : @"PATCH"
                    };
        }else{
        dic = @{
                @"op":_option
                };
        }
    }
    NSLog(@"%@",dic);
    return dic;
    
}


/// 请求的URL
- (NSString *)requestUrl{
    if ([_method isEqualToString:@"PATCH"]) {
         return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : @"download/switch";
    }else{
          return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"download/switch" base64EncodedString]] : @"download/switch";
    }
   
}

- (NSDictionary *)requestHeaderFieldValueDictionary{

   NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    
    return dic;
}
@end
