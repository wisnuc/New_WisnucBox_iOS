//
//  FMAccountUsersAPI.m
//  FruitMix
//
//  Created by wisnuc on 2017/7/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMAccountUsersAPI.h"

@implementation FMAccountUsersAPI
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

/// 请求的URL
- (NSString *)requestUrl{
    return  [NSString stringWithFormat:@"users/%@", WB_UserService.currentUser.uuid];
//    return  @"account";
}


-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken] forKey:@"Authorization"];
    return dic;
}
@end
