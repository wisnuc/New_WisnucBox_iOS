//
//  WBGetOneBoxAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/30.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBGetOneBoxAPI : JYBaseRequest
@property (nonatomic)NSString *boxuuid;
+ (instancetype)getBoxApiWithBoxuuid:(NSString *)boxuuid;
@end
