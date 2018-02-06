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
#define NO_CLOUD_TOKEN 60005

#define Current_User_Home @"Current_User_Home"
#define Current_Backup_Base_Entry @"Current_Backup_Base_Entry"
#define Current_Backup_Dir @"Current_Backup_Dir"

#define SaveToUserDefault(name, data) \
        [kUserDefaults setObject:data forKey:name]; \
        kUD_Synchronize \

#define GetUserDefaultForKey(key)  kUD_ObjectForKey(key)

//notify
#define NETWORK_REACHABILITY_CHANGE_NOTIFY @"NETWORK_REACHABILITY_CHANGE_NOTIFY"
#define NETWORK_CHECKOUT_TO_LAN_NOTIFY @"NETWORK_CHECKOUT_TO_LAN_NOTIFY"

@interface NetServices : NSObject <ServiceProtocol>

@property (nonatomic, assign) BOOL isCloud;

@property (nonatomic, copy) NSString *localUrl;

@property (nonatomic, copy) NSString *cloudUrl;

@property (nonatomic, readonly) AFNetworkReachabilityStatus status;

- (void)updateIsCloud:(BOOL)isCloud andLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl;

- (void)testForLANIP:(NSString *)LANIP commplete:(void(^)(BOOL success))callback;

- (void)checkForLANIP:(NSString *)LANIP commplete:(void(^)(BOOL success))callback;

- (void)testAndCheckoutIfSuccessComplete:(void(^)(void))callback;

- (void)testAndCheckoutCloudIfSuccessComplete:(void(^)(void))callback;

- (instancetype)initWithLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl;

- (void)getLocalTokenWithCloud:(void(^)(NSError *, NSString * token))callback;

- (void)getBoxesTokenWithGuid:(NSString *)guid comlete:(void(^)(NSError *, NSString * token))callback;

- (void)getUserBackupDirName:(NSString *)name BackupDir:(void(^)(NSError *, NSString * entryUUID))callback;

- (void)getUserHome:(void(^)(NSError *, NSString * userHome))callback;

- (void)mkdirInDir:(NSString *)dirUUID andName:(NSString *)name completeBlock:(void(^)(NSError *, DirectoriesModel *))completeBlock;

- (void)getEntriesInUserBackupDir:(void(^)(NSError *, NSArray<EntriesModel *> *entries))callback;

- (SDWebImageDownloadToken *)getHighWebImageWithHash:(NSString *)hash completeBlock:(void(^)(NSError *, UIImage *))callback;

- (SDWebImageDownloadToken *)getThumbnailWithHash:(NSString *)hash complete:(void(^)(NSError *, UIImage *))callback;
- (void)getDirUUIDWithDirName:(NSString *)name BaseDir:(void(^)(NSError *, NSString * dirUUID))callback;
- (SDWebImageDownloadToken *)getTweeetThumbnailImageWithHash:(NSString *)hash BoxUUID:(NSString *)boxUUID complete:(void(^)(NSError *, UIImage *))callback;
- (SDWebImageDownloadToken *)getTweeethighQualityImageWithHash:(NSString *)hash BoxUUID:(NSString *)boxUUID complete:(void(^)(NSError *, UIImage *))callback;
@end
