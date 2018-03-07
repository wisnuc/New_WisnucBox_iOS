//
//  WBBoxUserAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/2/8.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBBoxUserAPI.h"

@implementation WBBoxUserAPI
+ (instancetype)userApiWithGuid:(NSString *)guid{
    WBBoxUserAPI *api = [WBBoxUserAPI new];
    api.guid = guid;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

- (id)requestArgument{
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutableDic setObject:_guid forKey:@"id"];
    return mutableDic;
}

/// 请求的URL
- (NSString *)requestUrl{
    
    return [NSString stringWithFormat:@"%@users/%@/interestingPerson", WX_BASE_URL,_guid];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.cloudToken ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@ %@",WB_BoxService.boxToken,WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
