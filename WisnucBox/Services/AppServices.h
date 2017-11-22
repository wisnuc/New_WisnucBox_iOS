//
//  AppServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBServices.h"
#import "UserServices.h"
#import "AssetsServices.h"
#import "FilesServices.h"
#import "NetServices.h"
#import "FMLoginViewController.h"

#define WB_AppServices  [AppServices sharedService]
#define WB_AssetService [WB_AppServices assetServices]
#define WB_UserService  [WB_AppServices userServices]
#define WB_FileService  [WB_AppServices fileServices]
#define WB_NetService   [WB_AppServices netServices]
#define WB_PhotoUploadManager [WB_AppServices photoUploadManager]

#define UserBackUpConfigChangeNotify @"UserBackUpConfigChangeNotify"
#define UserInfoChangedNotify @"UserInfoChangedNotify"
#define WBBackupCountChangeNotify @"BackupCountChangeNotify"

@class WBUploadManager;
@interface AppServices : NSObject <ServiceProtocol>

@property (nonatomic, strong) DBServices * dbServices;

@property (nonatomic, strong) UserServices * userServices;

@property (nonatomic, strong) AssetsServices * assetServices;

@property (nonatomic, strong) FilesServices * fileServices;

@property (nonatomic, strong) NetServices * netServices;

@property (nonatomic, strong) WBUploadManager * photoUploadManager;

+ (instancetype)sharedService;

- (void)bootStrap;

- (void)rebulid;

- (void)startUploadAssets:(void(^)(void))complete;

- (void)loginWithBasic:(NSString *)basic userUUID:(NSString *)uuid name:(NSString *)userName addr:(NSString *)addr isWechat:(BOOL)isWechat completeBlock:(void(^)(NSError *error, WBUser *user))callback;

// wechat login with wechat code
- (void)wechatLoginWithUserModel:(CloudModelForUser *)cloudUserModel Token:(NSString *)cloudToken AvatarUrl:(NSString *)avatarUrl addr:(NSString *)addr completeBlock:(void(^)(NSError *error, WBUser *user))callback;

- (void)updateCurrentUserInfoWithCompleteBlock:(void(^)(NSError *, BOOL success))callback;

- (void)requestForBackupPhotos:(void(^)(BOOL shouldUpload))callback;
@end

#define HashCalculateFinishedNotify @"HashCalculateFinishedNotify"
#define WBUploadManagerDestroyedNotify @"WBUploadManagerDestroyedNotify"

@class WBUploadModel;
@interface WBUploadManager : NSObject

@property (nonatomic, readonly) NSMutableArray<JYAsset *> *hashwaitingQueue;

@property (nonatomic, readonly) NSMutableArray<JYAsset *> *hashWorkingQueue;

@property (nonatomic, readonly) NSMutableArray<JYAsset *> *hashFailQueue;

@property (nonatomic, readonly) NSMutableArray<JYAsset *> *uploadPaddingQueue;

@property (nonatomic, readonly) NSMutableArray<WBUploadModel *> *uploadingQueue;

@property (nonatomic, readonly) NSMutableArray<WBUploadModel *> *uploadedQueue;

@property (nonatomic, readonly) NSMutableArray<WBUploadModel *> *uploadErrorQueue;

@property (nonatomic) NSInteger hashLimitCount; // default 2

@property (nonatomic) NSInteger uploadLimitCount; // default 1

@property (nonatomic) BOOL shouldUpload; // default NO

- (void)getAllCount:(void(^)(NSInteger allCount))callback;

- (void)startWithLocalAssets:(NSArray<JYAsset *> *)localAssets andNetAssets:(NSArray<EntriesModel *> *)netAssets;

- (void)startUpload;

- (void)setNetAssets:(NSArray<EntriesModel *> *)netAssets;

- (void)stop;

- (void)destroy;

- (void)addTask:(JYAsset *)asset;

- (void)addTasks:(NSArray<JYAsset *> *)assets;

- (void)removeTask:(JYAsset *)rmAsset;

- (void)removeTasks:(NSArray<JYAsset *> *)assets;

@end

// error code
#define WBUploadDirNotFound   10011
#define WBUploadFileExist     10012

@interface WBUploadModel : NSObject

@property (nonatomic) JYAsset * asset;

@property (nonatomic) NSError * error;

@property (nonatomic) BOOL isRemoved;

@property (nonatomic, copy) void(^callback)(NSError * , id);

+ (instancetype)initWithAsset:(JYAsset *)asset;

- (void)startWithCompleteBlock:(void(^)(NSError * , id))callback;

// must call callback EABORT
- (void)cancel;

@end
