//
//  FMGetJWTAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetJWTAPI.h"
#import "Base64.h"

@implementation FMGetJWTAPI
+ (instancetype)apiWithBaseUrl:(NSString *)url UUID:(NSString *)uuid Password:(NSString *)password{
    FMGetJWTAPI *api = [FMGetJWTAPI new];
    api.url = url;
    api.uuid = uuid;
    api.passWord = password;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    if (_url.length >0) {
      return [NSString stringWithFormat:@"%@token",_url];
    }else{
      return @"token";
    }
}
-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSString * UUID;
     if (_uuid && _uuid.length >0) {
         UUID = [NSString stringWithFormat:@"%@:%@",_uuid,_passWord];
     }else{
         UUID = [NSString stringWithFormat:@"%@:%@",_model.uuid,_passWord];
     }
  
    NSString * Basic = [UUID base64EncodedString];
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"Basic %@",Basic] forKey:@"Authorization"];
    return dic;
}
@end
