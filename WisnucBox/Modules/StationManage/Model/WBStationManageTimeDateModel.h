//
//  WBStationManageTimeDateModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"

@interface WBStationManageTimeDateModel : WBBaseModel
@property (nonatomic,copy) NSString *localTime;
@property (nonatomic,copy) NSNumber *wbNTPSynchronized;
@property (nonatomic,copy) NSNumber *wbNetworkTimeOn;
@property (nonatomic,copy) NSNumber *wbRTCInLocalTZ;
@property (nonatomic,copy) NSString *wbRTCTime;
@property (nonatomic,copy) NSString *timeZone;
@property (nonatomic,copy) NSString *universalTime;
//timedate['Local time'],
//timedate['Universal time'],
//timedate['RTC time'],
//timedate['Time zone'],
//timedate['NTP synchronized'],
//timedate['Network time on']
@end
