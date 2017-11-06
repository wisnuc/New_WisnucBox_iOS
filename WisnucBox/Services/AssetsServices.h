//
//  AssetsServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBLocalAsset+CoreDataClass.h"

#define ASSETS_UPDATE_NOTIFY @"ASSETS_UPDATE_NOTIFY"

@class JYAsset;
@interface AssetsServices : NSObject <ServiceProtocol>

@property (nonatomic, copy, readonly) NSArray<JYAsset *> * allAssets;

- (void)saveAsset:(WBLocalAsset *)asset;

- (WBLocalAsset *)getAssetWithLocalId:(NSString *)localId;

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

- (void)stop;

- (void)destroy;

@end

@interface WBUploadModel : NSObject

@property (nonatomic) JYAsset * asset;

@property (nonatomic, copy) void(^callback)(NSError * , id);

+ (instancetype)initWithAsset:(JYAsset *)asset;

- (void)startWithCompleteBlock:(void(^)(NSError * , id))callback;

@end
