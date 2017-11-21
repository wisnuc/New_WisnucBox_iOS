//
//  FMCreateUserAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/8.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCreateUserAPI.h"
#import "Base64.h"

@implementation FMCreateUserAPI

- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : @"users";
}

-(id)requestArgument{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:_param];
    return WB_UserService.currentUser.isCloudLogin ? ({
        [dic setObject:[@"users" base64EncodedString] forKey:@"resource"];
        [dic setObject:@"POST" forKey:@"method"];
        dic;
    }) : self.param;
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}

@end
