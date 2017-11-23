//
//  FMMediaRamdomKeyAPI.h
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/23.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMMediaRamdomKeyAPI : JYBaseRequest

@property (nonatomic) NSString * photoHash;

+ (instancetype)apiWithHash:(NSString *)hash;

@end
