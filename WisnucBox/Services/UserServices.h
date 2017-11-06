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

@property (nonatomic, copy) WBUser *  currentUser; // current login user

@property (nonatomic, assign, readonly) BOOL isUserLogin; // if someone login , this property be true, else false

@property (nonatomic, copy) NSString *  defaultToken; //  Token for login user

- (WBUser *)getUserWithUUID:(NSString * )uuid;

- (void)saveUser:(WBUser *)user;

- (void)deleteUserWithUserId:(NSString  *)uuid;

- (void)logoutUser;

- (NSArray<WBUser *> *)getAllLoginUser;
@end
