//
//  WBBoxUserAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/2/8.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBBoxUserAPI : JYBaseRequest
@property (nonatomic) NSString *guid;
+ (instancetype)userApiWithGuid:(NSString *)guid;
@end
