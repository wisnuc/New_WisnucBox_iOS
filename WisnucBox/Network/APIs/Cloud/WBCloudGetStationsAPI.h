//
//  WBCloudGetStationsAPI.h
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBCloudGetStationsAPI : JYBaseRequest

@property (nonatomic) NSString * guid;
@property (nonatomic) NSString * cloudToken;

+ (instancetype)apiWithGuid:(NSString *)guid andToken:(NSString *)token;

@end
