//
//  FMGetUsersAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMGetUsersAPI : JYBaseRequest<JYRequestDelegate>
@property (nonatomic,strong)NSString *stationId;
@property (nonatomic,strong)NSString *cloudToken;
/*
 * WISNUC API:  GET ALL USERS FOR CLOUD LOGIN
 * @param stationId      Station ID
 * @param token          Token
 */
+ (instancetype)apiWithStationId:(NSString *)stationId Token:(NSString *)token;

@end
