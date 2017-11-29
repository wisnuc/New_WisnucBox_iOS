//
//  FMUpdateUserPasswordAPI.h
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMUpdateUserPasswordAPI : JYBaseRequest

@property (nonatomic) NSDictionary * param;

@property (nonatomic) NSString *oldPwd;

@property (nonatomic) NSString *nPwd;

@end
