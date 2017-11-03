//
//  UserServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

// userdefault key for login user uuid
#define WBCURRENTUSER_UUID @"WBCURRENTUSER_UUID"

@class WBUser;

@interface UserServices : NSObject<ServiceProtocol>

@property (nonatomic, strong) WBUser * currentUserUUID; // current login user 

@property (nonatomic, assign) BOOL isUserLogin; // if someone login , this property should be true, else false

@property (nonatomic, strong) NSString * defaultToken; //  Token for login user

@end
