//
//  WBCloudJsonAPI.h
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBCloudJsonAPI : JYBaseRequest

@property (nonatomic) id body;

+ (instancetype)apiWithBody:(id)args;

@end
