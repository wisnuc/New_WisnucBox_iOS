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
/*
 * WISNUC API:GET MEDIA RANDOM KEY
 * @param hash   Photo Hash
 */
+ (instancetype)apiWithHash:(NSString *)hash;

@end
