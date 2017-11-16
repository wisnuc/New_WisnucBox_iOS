//
//  NetServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntriesModel.h"
#import "DriveModel.h"
#import "DirectoriesModel.h"

// error code
#define NO_USER_LOGIN 60001
#define NOT_Found Created_Dir 60002
#define UserHome_NOT_Found 60004

#define Current_User_Home @"Current_User_Home"
#define Current_Backup_Base_Entry @"Current_Backup_Base_Entry"
#define Current_Backup_Dir @"Current_Backup_Dir"

#define SaveToUserDefault(name, data) \
        [kUserDefaults setObject:data forKey:name]; \
        kUD_Synchronize \

#define GetUserDefaultForKey(key)  kUD_ObjectForKey(key)

//notify
#define NETWORK_REACHABILITY_CHANGE_NOTIFY @"NETWORK_REACHABILITY_CHANGE_NOTIFY"

@interface NetServices : NSObject <ServiceProtocol>

@property (nonatomic, assign) BOOL isCloud;

@property (nonatomic, copy) NSString *localUrl;

@property (nonatomic, copy) NSString *cloudUrl;

@property (nonatomic, readonly) AFNetworkReachabilityStatus status;

- (instancetype)initWithLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl;

- (void)getUserBackupDir:(void(^)(NSError *, NSString * entryUUID))callback;

- (void)getUserHome:(void(^)(NSError *, NSString * userHome))callback;

- (void)mkdirInDir:(NSString *)dirUUID andName:(NSString *)name completeBlock:(void(^)(NSError *, DirectoriesModel *))completeBlock;

- (void)getEntriesInUserBackupDir:(void(^)(NSError *, NSArray<EntriesModel *> *entries))callback;

- (id <SDWebImageOperation>)getHighWebImageWithHash:(NSString *)hash completeBlock:(void(^)(NSError *, UIImage *))callback;

- (id <SDWebImageOperation>)getThumbnailWithHash:(NSString *)hash complete:(void(^)(NSError *, UIImage *))callback;

@end
