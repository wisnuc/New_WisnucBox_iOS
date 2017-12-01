
//
//  WBTicketsUserAPI.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBTicketsUserAPI.h"

@implementation WBTicketsUserAPI

+ (instancetype)apiWithTicketId:(NSString *)ticketId WithToken:(NSString *)token{
    WBTicketsUserAPI *api = [WBTicketsUserAPI new];
    api.ticketId = ticketId;
    api.token = token;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@c/v1/tickets/%@/users",kCloudAddr,_ticketId];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:_token forKey:@"Authorization"];
    return dic;
}

@end
