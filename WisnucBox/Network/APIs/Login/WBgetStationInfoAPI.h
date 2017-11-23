//
//  WBgetStationInfoAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/23.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBgetStationInfoAPI : JYBaseRequest
@property (nonatomic) NSString *servicePath;
+(instancetype)apiWithServicePath:(NSString *)servicePath;
@end
