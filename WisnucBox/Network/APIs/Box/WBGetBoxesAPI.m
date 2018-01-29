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
    }
    return dic;
}

/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [@"boxes" base64EncodedString]] : @"boxes";
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
