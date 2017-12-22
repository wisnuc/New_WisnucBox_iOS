//
//  WBStationTicketsAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationTicketsAPI.h"

@implementation WBStationTicketsAPI
+ (instancetype)apiWithRequestMethodString:(NSString *)requestMethodString Type:(NSString *)type{
    WBStationTicketsAPI *api = [WBStationTicketsAPI new];
    api.requestMethodString  = requestMethodString;
    api.type = type;
    return api;
    
}
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    if ([_requestMethodString isEqualToString:@"GET"]) {
        return JYRequestMethodGet;
    }else if ([_requestMethodString isEqualToString:@"POST"]){
       return JYRequestMethodPost;
    }else{
        return JYRequestMethodGet;
    }
}
/// 请求的URL
- (NSString *)requestUrl{
    if ([_requestMethodString isEqualToString:@"GET"]) {
        return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"station/tickets" base64EncodedString]] : @"station/tickets";
    }else if ([_requestMethodString isEqualToString:@"POST"]){
        return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl]: @"station/tickets";
    }else{
        return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"station/tickets" base64EncodedString]] : @"station/tickets";
    }
}

- (id)requestArgument{
    NSDictionary *dic;
    
    if (_type) {
        if (WB_UserService.currentUser.isCloudLogin) {
            
            dic = @{
                    @"resource":[@"station/tickets" base64EncodedString],
                    @"type":_type,
                    @"method": @"POST"
                    };
            
        }else{
            dic = @{
                    @"type":_type
                    };
        }
    }
   
    return dic;
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}

@end
