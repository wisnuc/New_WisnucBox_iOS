//
//  FMUpdateUserAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FMUpdateUserAPI.h"

@implementation FMUpdateUserAPI

- (JYRequestMethod)requestMethod{
    return WB_UserService.currentUser.isCloudLogin ? JYRequestMethodPost : JYRequestMethodPatch;
}
/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : [NSString stringWithFormat:@"users/%@", WB_UserService.currentUser.uuid];
}

-(id)requestArgument{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:_userName forKey:@"username"];
    return WB_UserService.currentUser.isCloudLogin ? ({
        [dic setObject:[[NSString stringWithFormat:@"users/%@", WB_UserService.currentUser.uuid] base64EncodedString] forKey:kCloudBodyResource];
        [dic setObject:@"PATCH" forKey:kCloudBodyMethod];
        dic;
    }) : dic;
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
