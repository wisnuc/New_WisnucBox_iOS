//
//  WBStationManageTimeDateModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageTimeDateModel.h"

@implementation WBStationManageTimeDateModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"localTime": @"Local time",
             @"wbNTPSynchronized": @"NTP synchronized",
             @"wbNetworkTimeOn": @"Network time on",
             @"wbRTCInLocalTZ": @"RTC in local TZ",
             @"wbRTCTime": @"RTC time",
             @"timeZone": @"Time zone",
             @"universalTime": @"Universal time"
             };
}

@end
