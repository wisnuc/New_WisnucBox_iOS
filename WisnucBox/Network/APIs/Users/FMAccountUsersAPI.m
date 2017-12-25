//
//  FMAccountUsersAPI.m
//  FruitMix
//
//  Created by wisnuc on 2017/7/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMAccountUsersAPI.h"
#import "Base64.h"

@implementation FMAccountUsersAPI
+ (instancetype)apiWithRequestMethod:(NSString *)method Disabled:(BOOL)disabled UUID:(NSString *)uuid{
    FMAccountUsersAPI *api = [FMAccountUsersAPI new];
    api.method = method;
    api.disabled = [NSNumber numberWithBool:disabled];
    api.uuid = uuid;
    NSLog(@"%@",api.disabled);
    return api;
}

+ (instancetype)apiWithRequestMethod:(NSString *)method IsAdmin:(BOOL)isAdmin UUID:(NSString *)uuid{
    FMAccountUsersAPI *api = [FMAccountUsersAPI new];
    api.method = method;
    api.isAdmin = [NSNumber numberWithBool:isAdmin];
    api.uuid = uuid;
    NSLog(@"%@",api.disabled);
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    JYRequestMethod method = JYRequestMethodGet;
    if (_method && [_method isEqualToString:@"PATCH"]) {
        method = JYRequestMethodPatch;
    }
    return method;
}

- (id)requestArgument{
    NSDictionary *param;
    NSLog(@"%@",_disabled);
    
    if (_disabled) {
        param = @{
                  @"disabled":_disabled
                  };
    }
    
    if (_isAdmin) {
        param = @{
                  @"isAdmin":_isAdmin
                  };
    }
    return param;
}

/// 请求的URL
- (NSString *)requestUrl{
    NSString * resouce;
    if (_uuid.length>0) {
      resouce  = [NSString stringWithFormat:@"users/%@", _uuid];
    }else{
       resouce = [NSString stringWithFormat:@"users/%@", WB_UserService.currentUser.uuid];
    }
   
    return WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET", kCloudAddr, kCloudCommonJsonUrl, [resouce base64EncodedString]] : resouce;
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}

@end
