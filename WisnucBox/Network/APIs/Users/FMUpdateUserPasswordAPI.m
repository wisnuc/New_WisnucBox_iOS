//
//  FMUpdateUserPasswordAPI.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FMUpdateUserPasswordAPI.h"

@implementation FMUpdateUserPasswordAPI

- (JYRequestMethod)requestMethod{
    return WB_UserService.currentUser.isCloudLogin ? JYRequestMethodPost : JYRequestMethodPut;
}

/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : [NSString stringWithFormat:@"users/%@/password", WB_UserService.currentUser.uuid];
}

-(id)requestArgument{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:_nPwd forKey:@"password"];
    return WB_UserService.currentUser.isCloudLogin ? ({
        [dic setObject:[[NSString stringWithFormat:@"users/%@/password", WB_UserService.currentUser.uuid] base64EncodedString] forKey:kCloudBodyResource];
        [dic setObject:@"PUT" forKey:kCloudBodyMethod];
        dic;
    }) : dic;
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic;
    if(WB_UserService.currentUser.isCloudLogin) {
        dic = [NSMutableDictionary dictionaryWithObject: WB_UserService.currentUser.cloudToken forKey:@"Authorization"];
    }else {
        NSString * UUID = [NSString stringWithFormat:@"%@:%@",WB_UserService.currentUser.uuid,_oldPwd];
        NSString * Basic = [UUID base64EncodedString];
        dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"Basic %@",Basic] forKey:@"Authorization"];
    }
    return dic;
}

@end
