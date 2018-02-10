//
//  MQTTStatus.h
//  MQTTClite
//
//  Created by wisnuc-imac on 2018/2/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//


#import <Foundation/Foundation.h>
@interface MQTTStatus : NSObject
//状态
@property(nonatomic,assign) MQTTSessionEvent statusCode;
//状态信息
@property(nonatomic,copy)  NSString *statusInfo;
@end
