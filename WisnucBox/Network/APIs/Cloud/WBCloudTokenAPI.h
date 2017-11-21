//
//  WBCloudTokenAPI.h
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBCloudTokenAPI : JYBaseRequest

@property (nonatomic) NSString *code;

+ (instancetype)apiWithCode:(NSString *)code;

@end
