//
//  WBGetBoxesAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/23.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBGetBoxesAPI.h"

@implementation WBGetBoxesAPI
+ (instancetype)creatApiWithUsers:(NSArray *)users BoxName:(NSString *)boxName{
    WBGetBoxesAPI *api = [WBGetBoxesAPI new];
    api.users = users;
    api.boxName = boxName;
    return api;
}


- (JYRequestMethod)requestMethod{
    if (_users && _users.count>0) {
        return JYRequestMethodPost;
    }
    return JYRequestMethodGet;
}

- (id)requestArgument{
    NSDictionary *dic;
    if (_users && _users.count>0) {
        if (!_boxName) {
            _boxName = @"";
        }
        dic = @{
                @"users":_users,
                @"name":_boxName
                };
        if (WB_UserService.currentUser.cloudToken) {
            dic = @{
                    @"resource" : [@"boxes" base64EncodedString],
                    @"method" : @"POST",
                    @"users":_users,
                    @"name":_boxName
                    };
        }
    }
    return dic;
}

/// 请求的URL
- (NSString *)requestUrl{
    if (_users && _users.count>0) {
        return  WB_UserService.currentUser.cloudToken ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : @"boxes";
    }
    return WB_UserService.currentUser.cloudToken ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonBoxesUrl] : @"boxes";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.cloudToken ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
