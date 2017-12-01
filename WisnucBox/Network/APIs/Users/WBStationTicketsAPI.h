//
//  WBStationTicketsAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBStationTicketsAPI : JYBaseRequest
@property (nonatomic) NSString *requestMethodString;
@property (nonatomic) NSString *type;

+ (instancetype)apiWithRequestMethodString:(NSString *)requestMethodString Type:(NSString *)type;
@end
