//
//  FMAccountUsersAPI.h
//  FruitMix
//
//  Created by wisnuc on 2017/7/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMAccountUsersAPI : JYBaseRequest
@property (nonatomic) NSString *method;
@property (nonatomic) NSNumber *disabled;
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSNumber *isAdmin;
+ (instancetype)apiWithRequestMethod:(NSString *)method Disabled:(BOOL)disabled UUID:(NSString *)uuid;
+ (instancetype)apiWithRequestMethod:(NSString *)method IsAdmin:(BOOL)isAdmin UUID:(NSString *)uuid;
@end
