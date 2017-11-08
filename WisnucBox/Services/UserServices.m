//
//  UserServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "UserServices.h"
#import "WBUser+CoreDataClass.h"

@interface UserServices ()

@property (readwrite) BOOL isUserLogin;

@end

@implementation UserServices

- (void)abort {
    
}

- (instancetype)init {
    if(self = [super init]) {
        [self loadData];
    }
    return self;
}

// load Latest User Configuation
- (void)loadData {
    if(kUD_ObjectForKey(WBCURRENTUSER_UUID)) {
        self.currentUser = [self getUserWithUUID:WBCURRENTUSER_UUID];
        if(!self.currentUser) {
            self.isUserLogin = false;
            [kUserDefaults removeObjectForKey:WBCURRENTUSER_UUID];
            kUD_Synchronize;
            return ;
        }
        self.isUserLogin = true;
        self.defaultToken = self.currentUser.localToken;
    }else{
        self.currentUser = nil;
        self.isUserLogin = false;
        self.defaultToken = nil;
    }
}

- (WBUser *)getUserWithUUID:(NSString *)uuid {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    WBUser * user = [WBUser MR_findFirstWithPredicate:predicate];
    return user;
}

- (void)logoutUser {
    _defaultToken = nil;
    _isUserLogin = false;
    _currentUser = nil;
    [kUserDefaults removeObjectForKey:WBCURRENTUSER_UUID];
    kUD_Synchronize;
}

- (void)setCurrentUser:(WBUser *)currentUser {
    if(!currentUser)
       return [self logoutUser];
    self.defaultToken = currentUser.localToken;
    self.isUserLogin = true;
    _currentUser = currentUser;
    [kUserDefaults setObject:currentUser.uuid forKey:WBCURRENTUSER_UUID];
    kUD_Synchronize;
}

- (WBUser *)saveUser:(WBUser *)user {
    WBUser * newUser = [self getUserWithUUID:user.uuid];
    if(!newUser)
        newUser = [WBUser MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    newUser.uuid = user.uuid;
    newUser.userName = user.userName;
    newUser.localToken = user.localToken;
    newUser.cloudToken = user.cloudToken;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    if(newUser.uuid == self.currentUser.uuid)
        self.currentUser = newUser;
    return newUser;
}

- (void)deleteUserWithUserId:(NSString  *)uuid {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    NSArray<WBUser *> *users = [WBUser MR_findAllWithPredicate:predicate];
    for (WBUser *user in users) {
        [user MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (NSArray<WBUser *> *)getAllLoginUser {
    return [WBUser MR_findAll];
}

- (void)synchronizedCurrentUser {
    [self saveUser:self.currentUser];
}

@end
