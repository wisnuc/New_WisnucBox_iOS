//
//  FMGetJWTAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"
#import "UserModel.h"

@interface FMGetJWTAPI : JYBaseRequest<JYRequestDelegate>

@property (nonatomic) UserModel * model;
@property (nonatomic) NSString * passWord;
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSString *url;

+ (instancetype)apiWithBaseUrl:(NSString *)url UUID:(NSString *)uuid Password:(NSString *)password;

@end
