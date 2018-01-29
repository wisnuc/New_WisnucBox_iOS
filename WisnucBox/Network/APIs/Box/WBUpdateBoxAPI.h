//
//  WBUpdateBoxAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/29.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBUpdateBoxAPI : JYBaseRequest
@property (nonatomic)NSArray *users;
@property (nonatomic)NSString *boxName;
@property (nonatomic)NSString *op;
@property (nonatomic)NSString *boxuuid;
+ (instancetype)updateApiWithBoxuuid:(NSString *)boxuuid Users:(NSArray *)users Option:(NSString *)op;
@end
