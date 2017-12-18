//
//  WBStorageVolumesAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStorageVolumesAPI.h"

@implementation WBStorageVolumesAPI
+(instancetype)apiWithURLPath:(NSString *)path Target:(NSArray *)target Mode:(NSString *)mode{
    WBStorageVolumesAPI *api = [WBStorageVolumesAPI new];
    api.path = path;
    api.target = target;
    api.mode = mode;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
  return [NSString stringWithFormat:@"%@storage/volumes",_path];
}

- (id)requestArgument{
    NSDictionary *dic = @{
        @"target":_target,
        @"mode":_mode
    };
    return dic;
}
@end
