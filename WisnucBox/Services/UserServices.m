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

- (void)dealloc {
    NSLog(@"UserServices delloc");
}

- (instancetype)init {
    if(self = [super init]) {
        [self loadData];
    }
    return self;
}

- (NSString *)defaultToken {
    return self.currentUser ? (self.currentUser.isCloudLogin ? self.currentUser.cloudToken : self.currentUser.localToken) : nil;
}

// load Latest User Configuation
- (void)loadData {
    NSLog(@"%@",kUD_ObjectForKey(WBCURRENTUSER_UUID));
    if(kUD_ObjectForKey(WBCURRENTUSER_UUID)) {
        self.currentUser = [self getUserWithUUID:kUD_ObjectForKey(WBCURRENTUSER_UUID)];
        if(!self.currentUser) {
            self.isUserLogin = false;
            [kUserDefaults removeObjectForKey:WBCURRENTUSER_UUID];
            kUD_Synchronize;
            return ;
        }
        self.isUserLogin = true;
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

    [kUserDefaults removeObjectForKey:kminiDLNASwich];
    [kUserDefaults removeObjectForKey:kSambaSwich];
//    [kUserDefaults removeObjectForKey:kBTSwich];
    kUD_Synchronize;
}

- (void)setCurrentUser:(WBUser *)currentUser {
    if(!currentUser || !currentUser.uuid || IsNilString(currentUser.uuid))
       return [self logoutUser];
    self.defaultToken = currentUser.localToken;
    self.isUserLogin = true;
    _currentUser = currentUser;
    [kUserDefaults setObject:currentUser.uuid forKey:WBCURRENTUSER_UUID];
    kUD_Synchronize;
}

- (WBUser *)createUserWithUserUUID:(NSString *)uuid {
    return [WBUser MR_findFirstOrCreateByAttribute:@"uuid" withValue:uuid inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (WBUser *)saveUser:(WBUser *)user {
    if(!user) return nil;
    if(!user.uuid || IsNilString(user.uuid)) {
        [user MR_deleteEntity];
        return nil;
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    if(user.uuid == self.currentUser.uuid)
        self.currentUser = user;
    return user;
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

@implementation UserSession



@end
