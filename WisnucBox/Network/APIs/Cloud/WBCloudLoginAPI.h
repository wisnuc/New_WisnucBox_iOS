//
//  WBCloudLoginAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBCloudLoginAPI : JYBaseRequest
@property (nonatomic)NSString *code;
+ (instancetype)apiWithCode:(NSString *)code;
@end
