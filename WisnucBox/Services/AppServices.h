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

@end

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

- (void)startWithLocalAssets:(NSArray<JYAsset *> *)localAssets andNetAssets:(NSArray<JYAsset *> *)netAssets;

- (void)startUploadWithUrl:(NSURL *)url AndToken:(NSString *)token;

- (void)setNetAssets:(NSArray<JYAsset *> *)netAssets;

- (void)stop;

- (void)destroy;

- (void)addTask:(JYAsset *)asset;

- (void)addTasks:(NSArray<JYAsset *> *)assets;

- (void)removeTaskWithLocalId:(NSString *)assetId;

- (void)removeTasks:(NSArray<NSString *> *)assetIds;

@end

@interface WBUploadModel : NSObject

@property (nonatomic) JYAsset * asset;

@property (nonatomic, copy) void(^callback)(NSError * , id);

+ (instancetype)initWithAsset:(JYAsset *)asset;

- (void)startWithCompleteBlock:(void(^)(NSError * , id))callback;

// must call callback EABORT
- (void)cancel;

@end
