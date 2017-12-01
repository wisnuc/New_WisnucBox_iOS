//
//  WBStationTicketsWechatAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationTicketsWechatAPI.h"

@implementation WBStationTicketsWechatAPI

+ (instancetype)apiWithTicketId:(NSString *)ticketId Guid:(NSString *)guid Isbind:(BOOL)isBind{
    WBStationTicketsWechatAPI *api = [WBStationTicketsWechatAPI new];
    api.ticketId = ticketId;
    api.guid = guid;
    NSNumber *guidNumber = [NSNumber numberWithBool:isBind];
    api.isBind = guidNumber;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"station/tickets/wechat/%@",_ticketId] ;
}
- (id)requestArgument{
    NSDictionary *dic = @{
                          @"type":@"bind",
                          @"guid":_guid,
                          @"state":_isBind
                          };
    return dic;
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:(WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken]) forKey:@"Authorization"];
    return dic;
}

@end
