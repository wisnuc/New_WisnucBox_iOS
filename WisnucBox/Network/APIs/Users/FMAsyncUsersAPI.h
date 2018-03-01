//
//  FMAsyncUsersAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/7/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"
/*
 * WISNUC API:GET ALL USERS(no param)
 */
@interface FMAsyncUsersAPI : JYBaseRequest
@property (nonatomic)NSString *userName;
@property (nonatomic)NSString *password;
@property (nonatomic)NSString *path;
/*
 * WISNUC API:CREAT A USER(initialization)
 * @param path        URL
 * @param userName    UserName
 * @param Password    Password
 */
+(instancetype)apiWithURLPath:(NSString *)path UserName:(NSString *)userName Password:(NSString *)password;
@end
