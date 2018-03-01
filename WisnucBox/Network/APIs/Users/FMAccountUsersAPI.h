//
//  FMAccountUsersAPI.h
//  FruitMix
//
//  Created by wisnuc on 2017/7/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"
/*
 * WISNUC API:GET A USER INFO (no param)
 */
@interface FMAccountUsersAPI : JYBaseRequest
@property (nonatomic) NSString *method;
@property (nonatomic) NSNumber *disabled;
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSNumber *isAdmin;

/*
 * WISNUC API:CHANGE A USER ACCOUNT STATUS ACTION
 * @param disabled   User Account Status(ture,false)
 * @param uuid       User UUID
 */
+ (instancetype)apiWithRequestMethod:(NSString *)method Disabled:(BOOL)disabled UUID:(NSString *)uuid;

/*
 * WISNUC API:CHANGE A USER ACCOUNT ROLE ACTION
 * @param isAdmin    User is administration or not(ture,false)
 * @param uuid       User UUID
 */
+ (instancetype)apiWithRequestMethod:(NSString *)method IsAdmin:(BOOL)isAdmin UUID:(NSString *)uuid;
@end
