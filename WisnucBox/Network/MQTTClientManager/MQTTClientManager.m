//
//  MQTTClientManager.m
//  MQTTClite
//
//  Created by wisnuc-imac on 2018/2/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//


#import "MQTTClientManager.h"
#import "MQTTClientManagerDelegate.h"
#import <UIKit/UIDevice.h>
#import "MQTTStatus.h"

@interface MQTTClientManager ()<MQTTSessionDelegate>
@property(nonatomic, weak)      id<MQTTClientManagerDelegate> delegate;//代理
@property(nonatomic, strong)    MQTTSession *mqttSession;
@property(nonatomic, strong)    MQTTCFSocketTransport *transport;//连接服务器属性
@property(nonatomic, strong)    NSString *ip;//服务器ip地址
@property(nonatomic)            UInt16 port;//服务器ip地址
@property(nonatomic, strong)    NSString *userName;//用户名
@property(nonatomic, strong)    NSString *password;//密码
@property(nonatomic, strong)    NSString *topic;//单个主题订阅
@property(nonatomic, strong)    NSDictionary *topics;//多个主题订阅
@property(nonatomic, strong)    MQTTStatus *mqttStatus;//连接服务器状态
@property(nonatomic) NSInteger m;
@end

@implementation MQTTClientManager

#pragma mark 懒加载
-(MQTTSession *)mqttSession{
    if (!_mqttSession) {
        /*app包名+|iOS|+设备信息作为连接id确保唯一性*/
        NSString *clientID = [NSString stringWithFormat:@"client_ios_%@",WB_UserService.currentUser.guid];
        NSLog(@"-----------------MQTT连接的ClientID-----------------%@",clientID);
        _mqttSession=[[MQTTSession alloc] initWithClientId:clientID];
    }
    return _mqttSession;
}

-(MQTTCFSocketTransport *)transport{
    if (!_transport) {
        _transport=[[MQTTCFSocketTransport alloc] init];
    }
    return _transport;
}
-(MQTTStatus *)mqttStatus{
    if (!_mqttStatus) {
        _mqttStatus=[[MQTTStatus alloc] init];
    }
    return _mqttStatus;
}
#pragma mark 对外方法
/**
 单例
 
 @return self
 */
static id instance;
static dispatch_once_t onceToken;
+(MQTTClientManager *)shareInstance{

    dispatch_once(&onceToken, ^{
        instance=[[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _m = 0;
        [self.mqttSession addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)dealloc{
    [self.mqttSession close];
    [self.mqttSession removeObserver:self forKeyPath:@"status"];
}

+ (void)destroyAll{
    onceToken = 0;
    instance = nil;
}

/**
 MQTT登陆，订阅单个主题
 
 @param ip 服务器ip
 @param port 服务器端口
 @param userName 用户名
 @param password 密码
 @param topic 订阅的主题，可以订阅的主题与账户是相关联的，例：@"mqtt/test"
 */
-(void)loginWithIp:(NSString *)ip port:(UInt16)port userName:(NSString *)userName password:(NSString *)password topic:(NSString *)topic{
    self.topic=topic;
    [self loginWithIp:ip port:port userName:userName password:password];
}

/**
 MQTT登陆，订阅多个主题
 
 @param ip 服务器ip
 @param port 服务器端口
 @param userName 用户名
 @param password 密码
 @param topics 订阅的主题，可以订阅的主题与账户是相关联的，例：@{@"mqtt/test":@"mqtt/test",@"mqtt/test1":@"mqtt/test1"}
 */
-(void)loginWithIp:(NSString *)ip port:(UInt16)port userName:(NSString *)userName password:(NSString *)password topics:(NSDictionary *)topics{
    self.topics=topics;
    [self loginWithIp:ip port:port userName:userName password:password];
}
-(void)loginWithIp:(NSString *)ip port:(UInt16)port userName:(NSString *)userName password:(NSString *)password {
    self.ip=ip;
    self.port=port;
    self.userName=userName;
    self.password=password;
    
    [self loginMQTT];
    NSLog(@"%@",ip);
}
/*实际登陆处理*/
-(void)loginMQTT{
    /*设置ip和端口号*/
    self.transport.host=_ip;
    self.transport.port=_port;
    
    /*设置MQTT账号和密码*/
    self.mqttSession.transport=self.transport;//给MQTTSession对象设置基本信息
    self.mqttSession.delegate=self;//设置代理
    if (_userName.length!=0 &&_password.length!=0) {
        [self.mqttSession setUserName:_userName];
        [self.mqttSession setPassword:_password];
    }

    self.mqttSession.keepAliveInterval = 3;
    self.mqttSession.cleanSessionFlag = YES;
    [self.mqttSession setReceiveMaximum:@(5*1000)];
    
    //会话链接并设置超时时间
    [self.mqttSession connectAndWaitTimeout:1000];
}
/**
 断开连接，清空数据
 */
-(void)close{
    [_mqttSession close];
    _delegate=nil;//代理
    _mqttSession=nil;
    _transport=nil;//连接服务器属性
    _ip=nil;//服务器ip地址
    _port=0;//服务器ip地址
    _userName=nil;//用户名
    _password=nil;//密码
    _topic=nil;//单个主题订阅
    _topics=nil;//多个主题订阅
}

/**
 注册代理
 
 @param obj 需要实现代理的对象
 */
-(void)registerDelegate:(id)obj{
    self.delegate=obj;
}


/**
 解除代理
 
 @param obj 需要接触代理的对象
 */
-(void)unRegisterDelegate:(id)obj{
    self.delegate=nil;
}

#pragma mark MQTTClientManagerDelegate
/*连接成功回调*/
-(void)connected:(MQTTSession *)session{
    NSLog(@"-----------------MQTT成功建立连接-----------------");
    if (_topic) {
        NSLog(@"-----------------MQTT订阅单个主题-----------------");
        [self.mqttSession subscribeTopic:_topic];
    }else if(_topics){
        NSLog(@"-----------------MQTT订阅多个个主题-----------------");
        [self.mqttSession subscribeToTopics:_topics];
    }
}
/*连接状态回调*/
-(void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    NSDictionary *events = @{
                             @(MQTTSessionEventConnected): @"connected",
                             @(MQTTSessionEventConnectionRefused): @"connection refused",
                             @(MQTTSessionEventConnectionClosed): @"connection closed",
                             @(MQTTSessionEventConnectionError): @"connection error",
                             @(MQTTSessionEventProtocolError): @"protocoll error",
                             @(MQTTSessionEventConnectionClosedByBroker): @"connection closed by broker"
                             };
    [self.mqttStatus setStatusCode:eventCode];
    [self.mqttStatus setStatusInfo:[events objectForKey:@(eventCode)]];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didMQTTReceiveServerStatus:)]) {
        [self.delegate didMQTTReceiveServerStatus:self.mqttStatus];
    }
    NSLog(@"-----------------MQTT连接状态%@-----------------",[events objectForKey:@(eventCode)]);
    NSLog(@"MQTT连接状态错误%@",error);
}
/*收到消息*/
-(void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid{
    NSString *jsonStr=[NSString stringWithUTF8String:data.bytes];
    NSLog(@"-----------------MQTT收到消息主题：%@内容：%@",topic,jsonStr);
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(messageTopic:data:)]) {
        [self.delegate messageTopic:topic data:dic];
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(messageTopic:jsonStr:)]) {
        [self.delegate messageTopic:topic jsonStr:jsonStr];
    }
}

- (void)connectionError:(MQTTSession *)session error:(NSError *)error{
    NSLog(@"MQTT连接状态错误%@",error);
    if (self.mqttSession.status == MQTTSessionStatusError || self.mqttSession.status == MQTTSessionStatusClosed ||self.mqttSession.status == MQTTSessionStatusDisconnecting) {
        [self.mqttSession connect];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    _m ++;
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//    if (_m<=10) {
//        if (self.mqttSession.status == 4) {
//            [self.mqttSession connect];
//        }
//    }
}

@end
