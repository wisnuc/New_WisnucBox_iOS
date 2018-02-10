//
//  MQTTClientManager.h
//  MQTTClite
//
//  Created by wisnuc-imac on 2018/2/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTClientManagerDelegate.h"

@interface MQTTClientManager : NSObject

/**
 单例
 
 @return self
 */
+(MQTTClientManager *)shareInstance;

/**
 MQTT登陆，订阅单个主题
 
 @param ip 服务器ip
 @param port 服务器端口
 @param userName 用户名
 @param password 密码
 @param topic 订阅的主题，可以订阅的主题与账户是相关联的，例：@"mqtt/test"
 */
-(void)loginWithIp:(NSString *)ip port:(UInt16)port userName:(NSString *)userName password:(NSString *)password topic:(NSString *)topic;

/**
 MQTT登陆，订阅多个主题
 
 @param ip 服务器ip
 @param port 服务器端口
 @param userName 用户名
 @param password 密码
 @param topics 订阅的主题，可以订阅的主题与账户是相关联的，例：@{@"mqtt/test":@"mqtt/test",@"mqtt/test1":@"mqtt/test1"}
 */
-(void)loginWithIp:(NSString *)ip port:(UInt16)port userName:(NSString *)userName password:(NSString *)password topics:(NSDictionary *)topics;



/**
 断开连接，清空数据
 */
-(void)close;

/**
 注册代理
 
 @param obj 需要实现代理的对象
 */
-(void)registerDelegate:(id)obj;


/**
 解除代理
 
 @param obj 需要接触代理的对象
 */
-(void)unRegisterDelegate:(id)obj;

+(void)destroyAll;
@end
