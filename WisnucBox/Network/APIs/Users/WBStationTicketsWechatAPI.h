//
//  WBStationTicketsWechatAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBStationTicketsWechatAPI : JYBaseRequest
@property (nonatomic) NSString *ticketId;
@property (nonatomic) NSString *guid;
@property (nonatomic) NSNumber *isBind;
/*
 * WISNUC API:CONFIRM TO BIND WECHAT ACTION
 * @param guid      GUID
 * @param isBind    Bind or not
 */
+ (instancetype)apiWithTicketId:(NSString *)ticketId Guid:(NSString *)guid Isbind:(BOOL)isBind;
@end
