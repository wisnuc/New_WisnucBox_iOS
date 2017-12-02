//
//  TicketUserModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "TicketUserModel.h"
@implementation TicketStationModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"ticketId": @"id",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"users" : [TicketUserModel class],
             };
}
@end


@implementation TicketUserModel


@end
