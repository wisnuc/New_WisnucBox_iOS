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
#define ASSETS_AUTH_CHANGE_NOTIFY @"ASSETS_AUTH_CHANGE_NOTIFY"
#define ASSETS_NET_CHANGE_NOTIFY @"ASSETS_NET_CHANGE_NOTIFY"

@class JYAsset;
@interface AssetsServices : NSObject <ServiceProtocol>

@property (nonatomic, copy, readonly) NSArray<JYAsset *> *allAssets;

@property (nonatomic, copy) void(^AssetChangeBlock)(NSArray<JYAsset *> *removeObjs, NSArray<JYAsset *> *insertObjs);

@property (nonatomic, readonly) BOOL userAuth;

@property (nonatomic, copy) NSArray<WBAsset *> *allNetAssets;

- (void)getNetAssets:(void(^)(NSError *, NSArray *))callback;

- (WBLocalAsset *)getAssetWithLocalId:(NSString *)localId;

- (NSArray<WBLocalAsset *> *)getAllHashedAsset;

- (void)saveAssetWithLocalId:(NSString *)localId digest:(NSString *)digest;

@end

