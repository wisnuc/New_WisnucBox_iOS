//
//  WBStationTicketsAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"
/*
 * WISNUC API:GET TICKET(no param,requestMethodString is GET)
 */
@interface WBStationTicketsAPI : JYBaseRequest
@property (nonatomic) NSString *requestMethodString;
@property (nonatomic) NSString *type;
/*
 * WISNUC API:TICKET ACTION WITH TYPE
 * @param type    Action Type(bind,invite)
 */
+ (instancetype)apiWithRequestMethodString:(NSString *)requestMethodString Type:(NSString *)type;
@end
