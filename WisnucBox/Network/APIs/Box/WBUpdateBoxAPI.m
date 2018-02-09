//
//  WBUpdateBoxAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/29.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBUpdateBoxAPI.h"

@implementation WBUpdateBoxAPI
+ (instancetype)updateApiWithBoxuuid:(NSString *)boxuuid Users:(NSArray *)users Option:(NSString *)op {
    WBUpdateBoxAPI *api = [WBUpdateBoxAPI new];
    api.users = users;
    api.op = op;
    api.boxuuid = boxuuid;
    return api;
}

+ (instancetype)updateApiWithBoxName:(NSString *)boxName Boxuuid:(NSString *)boxuuid {
    WBUpdateBoxAPI *api = [WBUpdateBoxAPI new];
    api.boxName = boxName;
    api.boxuuid = boxuuid;
    return api;
}

- (JYRequestMethod)requestMethod{
    if (WB_UserService.currentUser.cloudToken) {
        return JYRequestMethodPost;
    }
    return JYRequestMethodPatch;
}

- (id)requestArgument{
    if (_boxName) {
        if (WB_UserService.currentUser.cloudToken) {
            NSDictionary *dic;
            dic = @{
                    @"name":_boxName,
                    @"resource" : [[NSString stringWithFormat:@"boxes/%@",_boxuuid] base64EncodedString],
                    @"method" : @"PATCH"
                    };
            return dic;
        }
        NSDictionary *dic = @{
                              @"name":_boxName
                              };
        return dic;
    }
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutableDic setObject:_users forKey:@"value"];
    [mutableDic setObject:_op forKey:@"op"];
   
    NSLog(@"%@",mutableDic);
    NSData *josnData = [NSJSONSerialization dataWithJSONObject:mutableDic options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableDictionary *dicx = [NSJSONSerialization JSONObjectWithData:josnData options:NSJSONReadingMutableLeaves error:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:dicx forKey:@"users"];
    if (WB_UserService.currentUser.isCloudLogin) {
        [dic setObject:@"PATCH" forKey:@"method"];
        [dic setObject:[[NSString stringWithFormat:@"boxes/%@",_boxuuid] base64EncodedString] forKey:@"resource"];
    }
    return dic;
}

/// 请求的URL
- (NSString *)requestUrl{
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonJsonUrl] : [NSString stringWithFormat:@"boxes/%@",_boxuuid];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}
@end
